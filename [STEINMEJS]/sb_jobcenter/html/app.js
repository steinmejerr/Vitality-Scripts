const app = document.getElementById('app');
const windowEl = document.querySelector('.window');
const jobsEl = document.getElementById('jobs');
const categoriesEl = document.getElementById('categories');
const markersEl = document.getElementById('markers');
const searchEl = document.getElementById('search');
const mapViewport = document.getElementById('interactive-map');
const mapCanvas = document.getElementById('map-canvas');
const mapActions = document.getElementById('map-actions');
const adminToolbar = document.getElementById('admin-toolbar');
const adminEditor = document.getElementById('admin-editor');
const adminBackButton = document.getElementById('admin-back-to-list');
const adminCalibrateButton = document.getElementById('admin-calibrate-marker');

const adminFields = {
  id: document.getElementById('admin-id'),
  job: document.getElementById('admin-job'),
  grade: document.getElementById('admin-grade'),
  label: document.getElementById('admin-label'),
  category: document.getElementById('admin-category'),
  salary: document.getElementById('admin-salary'),
  icon: document.getElementById('admin-icon'),
  color: document.getElementById('admin-color'),
  sortOrder: document.getElementById('admin-sort'),
  description: document.getElementById('admin-description'),
  requirements: document.getElementById('admin-requirements')
};

const adminFormTitle = document.getElementById('admin-form-title');
const adminLocationDisplay = document.getElementById('admin-location-display');
const adminMapDisplay = document.getElementById('admin-map-display');
const emptyStateEl = document.getElementById('empty-state');
const jobDetailsEl = document.getElementById('job-details');

let state = {
  jobs: [],
  selected: null,
  category: 'Alle',
  search: '',
  currentJob: 'unemployed',
  calibrationJob: null,
  admin: false,
  adminDraft: null
};

let mapState = {
  scale: 1,
  x: 0,
  y: 0,
  dragging: false,
  moved: false,
  pointerId: null,
  startX: 0,
  startY: 0,
  originX: 0,
  originY: 0,
  minScale: 1,
  maxScale: 4.5
};

const post = (name, data = {}) => fetch(`https://${GetParentResourceName()}/${name}`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
}).then(async (r) => {
  try { return await r.json(); } catch { return true; }
});

const escapeHtml = (v = '') => String(v).replace(/[&<>"']/g, (m) => ({
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#039;'
}[m]));

const adminDefaults = () => ({
  oldId: null,
  id: '',
  job: '',
  grade: 0,
  label: '',
  category: 'Service',
  salary: 'Ikke angivet',
  icon: 'fa-solid fa-briefcase',
  color: '#35df75',
  description: '',
  requirements: [],
  sortOrder: 0,
  location: null,
  map: null
});

const formatVec3 = (l) => l ? `${Number(l.x).toFixed(2)}, ${Number(l.y).toFixed(2)}, ${Number(l.z).toFixed(2)}` : 'Ikke sat endnu';
const formatMap = (m) => m ? `${Number(m.x).toFixed(2)}%, ${Number(m.y).toFixed(2)}%` : 'Automatisk beregning';

function renderCategories() {
  const cats = ['Alle', ...new Set(state.jobs.map(j => j.category))];
  categoriesEl.innerHTML = cats.map(c => `<button class="category ${state.category === c ? 'active' : ''}" data-cat="${escapeHtml(c)}">${escapeHtml(c)}</button>`).join('');
  categoriesEl.querySelectorAll('.category').forEach(b => {
    b.onclick = () => {
      state.category = b.dataset.cat;
      renderCategories();
      renderJobs();
    };
  });
}

function renderMarkers() {
  markersEl.innerHTML = state.jobs.map(j => `
    <button class="marker ${state.selected?.id === j.id ? 'active' : ''}" data-id="${escapeHtml(j.id)}"
      style="left:${j.map.x}%;top:${j.map.y}%;${state.selected?.id === j.id ? `background:${j.color}` : ''}" title="${escapeHtml(j.label)}">
      <i class="${escapeHtml(j.icon)}"></i><span>${escapeHtml(j.label)}</span>
    </button>
  `).join('');

  markersEl.querySelectorAll('.marker').forEach(marker => {
    marker.addEventListener('pointerdown', e => e.stopPropagation());
    marker.addEventListener('click', e => {
      e.stopPropagation();
      selectJob(marker.dataset.id, true);
    });
  });

  updateMarkerScale();
}

function renderJobs() {
  const q = state.search.toLowerCase();
  const list = state.jobs.filter(j =>
    (state.category === 'Alle' || j.category === state.category) &&
    (!q || j.label.toLowerCase().includes(q) || j.description.toLowerCase().includes(q) || j.job.toLowerCase().includes(q))
  );

  jobsEl.innerHTML = list.map(j => `
    <article class="job-card ${state.selected?.id === j.id ? 'active' : ''}" data-id="${escapeHtml(j.id)}">
      <div class="job-card-icon" style="color:${j.color};background:${j.color}18"><i class="${escapeHtml(j.icon)}"></i></div>
      <div>
        <h3>${escapeHtml(j.label)}</h3>
        <p>${escapeHtml(state.admin ? `${j.job} · Grade ${j.grade}` : `${j.category} · ${j.salary}`)}</p>
      </div>
      <i class="fa-solid fa-chevron-right"></i>
    </article>
  `).join('') || '<p style="color:#92a098;font-size:13px">Ingen jobs fundet.</p>';

  jobsEl.querySelectorAll('.job-card').forEach(card => {
    card.onclick = () => selectJob(card.dataset.id);
  });
}

function populateJobDetails() {
  const j = state.selected;
  if (!j) return;

  emptyStateEl.classList.add('hidden');
  jobDetailsEl.classList.remove('hidden');
  adminEditor.classList.add('hidden');
  mapActions.classList.remove('hidden');
  adminCalibrateButton.classList.add('hidden');

  document.getElementById('map-title').textContent = j.label;
  document.getElementById('detail-title').textContent = j.label;
  document.getElementById('detail-category').textContent = j.category.toUpperCase();
  document.getElementById('detail-description').textContent = j.description;
  document.getElementById('detail-salary').textContent = j.salary;

  const icon = document.getElementById('detail-icon');
  icon.innerHTML = `<i class="${j.icon}"></i>`;
  icon.style.color = j.color;
  icon.style.background = `${j.color}18`;

  document.getElementById('requirements').innerHTML = (j.requirements || []).map(r => `
    <span class="requirement"><i class="fa-solid fa-check"></i>${escapeHtml(r)}</span>
  `).join('');

  const button = document.getElementById('select-job');
  button.innerHTML = state.currentJob === j.job
    ? '<i class="fa-solid fa-briefcase"></i>Du har allerede dette job'
    : '<i class="fa-solid fa-check"></i>Vælg dette job';
  button.disabled = state.currentJob === j.job;
  button.style.opacity = button.disabled ? '.55' : '1';
}

function applyAdminDraftToForm() {
  const d = state.adminDraft || adminDefaults();
  adminFormTitle.textContent = (d.oldId || d.id) ? `Rediger ${d.label || d.id}` : 'Opret job';
  adminFields.id.value = d.id || '';
  adminFields.job.value = d.job || '';
  adminFields.grade.value = d.grade ?? 0;
  adminFields.label.value = d.label || '';
  adminFields.category.value = d.category || 'Service';
  adminFields.salary.value = d.salary || 'Ikke angivet';
  adminFields.icon.value = d.icon || 'fa-solid fa-briefcase';
  adminFields.color.value = d.color || '#35df75';
  adminFields.sortOrder.value = d.sortOrder ?? 0;
  adminFields.description.value = d.description || '';
  adminFields.requirements.value = (d.requirements || []).join('\n');
  adminLocationDisplay.textContent = formatVec3(d.location);
  adminMapDisplay.textContent = formatMap(d.map);
  document.getElementById('admin-delete').disabled = !(d.oldId || d.id);
  adminCalibrateButton.classList.toggle('hidden', !(d.oldId || d.id));
}

function beginNewAdminJob() {
  state.selected = null;
  state.adminDraft = adminDefaults();
  emptyStateEl.classList.add('hidden');
  jobDetailsEl.classList.add('hidden');
  adminEditor.classList.remove('hidden');
  mapActions.classList.remove('hidden');
  document.getElementById('map-title').textContent = 'Nyt job';
  applyAdminDraftToForm();
  renderJobs();
  renderMarkers();
}

function populateAdminFromSelected() {
  if (!state.selected) {
    beginNewAdminJob();
    return;
  }

  const j = state.selected;
  state.adminDraft = {
    oldId: j.id,
    id: j.id,
    job: j.job,
    grade: j.grade,
    label: j.label,
    category: j.category,
    salary: j.salary,
    icon: j.icon,
    color: j.color,
    description: j.description,
    requirements: [...(j.requirements || [])],
    sortOrder: j.sortOrder || 0,
    location: j.location,
    map: j.mapOverride || j.map
  };

  emptyStateEl.classList.add('hidden');
  jobDetailsEl.classList.add('hidden');
  adminEditor.classList.remove('hidden');
  mapActions.classList.remove('hidden');
  document.getElementById('map-title').textContent = j.label;
  applyAdminDraftToForm();
}

function selectJob(id, focusMap = false) {
  state.selected = state.jobs.find(j => j.id === id);
  if (!state.selected) return;

  if (state.admin) populateAdminFromSelected();
  else populateJobDetails();

  renderJobs();
  renderMarkers();
  if (focusMap) focusSelectedJob();
}

function clamp(value, min, max) { return Math.min(max, Math.max(min, value)); }

function updateMapMinScale() {
  const viewport = mapViewport.getBoundingClientRect();
  const baseWidth = mapCanvas.offsetWidth || viewport.width;
  const baseHeight = mapCanvas.offsetHeight || viewport.height;
  const minScaleX = viewport.width / baseWidth;
  const minScaleY = viewport.height / baseHeight;
  mapState.minScale = Math.max(1, minScaleX, minScaleY);
  if (mapState.scale < mapState.minScale) mapState.scale = mapState.minScale;
}

function updateMarkerScale() {
  const markerScale = Math.pow(mapState.scale, -1.35);
  markersEl.style.setProperty('--marker-scale', markerScale.toFixed(4));
}

function applyMapTransform(animated = false) {
  mapCanvas.classList.toggle('animated', animated);
  mapCanvas.style.transform = `translate(calc(-50% + ${mapState.x}px), calc(-50% + ${mapState.y}px)) scale(${mapState.scale})`;
  updateMarkerScale();
  if (animated) setTimeout(() => mapCanvas.classList.remove('animated'), 280);
}

function getMapBounds() {
  const viewport = mapViewport.getBoundingClientRect();
  const canvasWidth = mapCanvas.offsetWidth * mapState.scale;
  const canvasHeight = mapCanvas.offsetHeight * mapState.scale;
  return {
    x: Math.max(0, (canvasWidth - viewport.width) / 2),
    y: Math.max(0, (canvasHeight - viewport.height) / 2)
  };
}

function clampMapPosition() {
  const bounds = getMapBounds();
  mapState.x = clamp(mapState.x, -bounds.x, bounds.x);
  mapState.y = clamp(mapState.y, -bounds.y, bounds.y);
}

function resetMap(animated = false) {
  updateMapMinScale();
  mapState.scale = mapState.minScale;
  mapState.x = 0;
  mapState.y = 0;
  applyMapTransform(animated);
}

function setMapZoom(nextScale, clientX, clientY) {
  updateMapMinScale();
  const previous = mapState.scale;
  const scale = clamp(nextScale, mapState.minScale, mapState.maxScale);
  if (scale === previous) return;

  const rect = mapViewport.getBoundingClientRect();
  const px = (clientX ?? (rect.left + rect.width / 2)) - (rect.left + rect.width / 2);
  const py = (clientY ?? (rect.top + rect.height / 2)) - (rect.top + rect.height / 2);
  const ratio = scale / previous;
  mapState.x = px - (px - mapState.x) * ratio;
  mapState.y = py - (py - mapState.y) * ratio;
  mapState.scale = scale;
  clampMapPosition();
  applyMapTransform();
}

function focusSelectedJob() {
  if (!state.selected) return;
  updateMapMinScale();
  mapState.scale = Math.max(1.7, mapState.minScale);
  const canvasWidth = mapCanvas.offsetWidth * mapState.scale;
  const canvasHeight = mapCanvas.offsetHeight * mapState.scale;
  mapState.x = (50 - state.selected.map.x) / 100 * canvasWidth;
  mapState.y = (50 - state.selected.map.y) / 100 * canvasHeight;
  clampMapPosition();
  applyMapTransform(true);
}

mapViewport.addEventListener('wheel', (e) => {
  e.preventDefault();
  setMapZoom(mapState.scale + (e.deltaY < 0 ? .22 : -.22), e.clientX, e.clientY);
}, { passive: false });

function setCalibrationMode(jobId) {
  const job = state.jobs.find(j => j.id === jobId);
  if (!job) return;
  state.calibrationJob = job;
  document.getElementById('map-calibration').classList.remove('hidden');
  selectJob(jobId, true);
}

function stopCalibration() {
  state.calibrationJob = null;
  document.getElementById('map-calibration').classList.add('hidden');
}

function calibrateAtPointer(e) {
  if (!state.calibrationJob || mapState.moved) return false;

  const rect = mapCanvas.getBoundingClientRect();
  const x = clamp(((e.clientX - rect.left) / rect.width) * 100, 0, 100);
  const y = clamp(((e.clientY - rect.top) / rect.height) * 100, 0, 100);

  const job = state.calibrationJob;
  job.map = { x, y };
  job.mapOverride = { x, y };
  if (state.adminDraft && (state.adminDraft.id === job.id || state.adminDraft.oldId === job.id)) {
    state.adminDraft.map = { x, y };
  }
  state.selected = job;
  renderMarkers();
  applyAdminDraftToForm();
  post('saveMapOverride', { id: job.id, x, y });
  stopCalibration();
  return true;
}

mapViewport.addEventListener('pointerdown', (e) => {
  if (e.button !== 0) return;
  mapState.dragging = true;
  mapState.moved = false;
  mapState.pointerId = e.pointerId;
  mapState.startX = e.clientX;
  mapState.startY = e.clientY;
  mapState.originX = mapState.x;
  mapState.originY = mapState.y;
  mapViewport.setPointerCapture(e.pointerId);
  mapViewport.classList.add('dragging');
});

mapViewport.addEventListener('pointermove', (e) => {
  if (!mapState.dragging || e.pointerId !== mapState.pointerId) return;
  const dx = e.clientX - mapState.startX;
  const dy = e.clientY - mapState.startY;
  if (Math.abs(dx) > 2 || Math.abs(dy) > 2) mapState.moved = true;
  mapState.x = mapState.originX + dx;
  mapState.y = mapState.originY + dy;
  clampMapPosition();
  applyMapTransform();
});

function endMapDrag(e) {
  if (e.pointerId !== mapState.pointerId) return;
  mapState.dragging = false;
  mapState.pointerId = null;
  mapViewport.classList.remove('dragging');
  try { mapViewport.releasePointerCapture(e.pointerId); } catch {}
}

mapViewport.addEventListener('pointerup', (e) => {
  const wasCalibrationClick = calibrateAtPointer(e);
  endMapDrag(e);
  if (wasCalibrationClick) e.stopPropagation();
});

mapViewport.addEventListener('pointercancel', endMapDrag);

document.getElementById('map-zoom-in').onclick = (e) => { e.stopPropagation(); setMapZoom(mapState.scale + .3); };
document.getElementById('map-zoom-out').onclick = (e) => { e.stopPropagation(); setMapZoom(mapState.scale - .3); };
document.getElementById('map-reset').onclick = (e) => { e.stopPropagation(); resetMap(true); };
document.getElementById('cancel-calibration').onclick = (e) => { e.stopPropagation(); stopCalibration(); };
window.addEventListener('resize', () => { updateMapMinScale(); clampMapPosition(); applyMapTransform(); });

function readAdminForm() {
  const reqs = adminFields.requirements.value.split(/\r?\n/).map(v => v.trim()).filter(Boolean);
  return {
    oldId: state.adminDraft?.oldId || null,
    id: adminFields.id.value.trim(),
    job: adminFields.job.value.trim(),
    grade: Number(adminFields.grade.value || 0),
    label: adminFields.label.value.trim(),
    category: adminFields.category.value.trim() || 'Service',
    salary: adminFields.salary.value.trim() || 'Ikke angivet',
    icon: adminFields.icon.value.trim() || 'fa-solid fa-briefcase',
    color: adminFields.color.value || '#35df75',
    description: adminFields.description.value.trim(),
    requirements: reqs,
    sortOrder: Number(adminFields.sortOrder.value || 0),
    location: state.adminDraft?.location || null,
    map: state.adminDraft?.map || null
  };
}

function updateJobsAndSelection(jobs, selectId) {
  state.jobs = (jobs || []).sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0) || a.label.localeCompare(b.label));
  renderCategories();
  renderJobs();
  renderMarkers();
  if (selectId) selectJob(selectId, true);
}

function open(data) {
  state = {
    jobs: (data.jobs || []),
    selected: null,
    category: 'Alle',
    search: '',
    currentJob: data.currentJob || 'unemployed',
    calibrationJob: null,
    admin: !!data.admin,
    adminDraft: null
  };

  searchEl.value = '';
  windowEl.classList.toggle('admin-mode', state.admin);
  adminToolbar.classList.toggle('hidden', !state.admin);
  adminBackButton.classList.toggle('hidden', !state.admin);
  adminEditor.classList.add('hidden');
  emptyStateEl.classList.remove('hidden');
  jobDetailsEl.classList.add('hidden');
  mapActions.classList.add('hidden');
  adminCalibrateButton.classList.add('hidden');
  document.getElementById('map-title').textContent = state.admin ? 'Joboversigt' : 'Vælg et job';

  app.classList.remove('hidden');
  resetMap();
  renderCategories();
  renderJobs();
  renderMarkers();

  if (state.admin) beginNewAdminJob();
}

function close() {
  stopCalibration();
  app.classList.add('hidden');
  post('close');
}

window.addEventListener('message', (e) => {
  if (e.data.action === 'open') open(e.data);
  if (e.data.action === 'close') { stopCalibration(); app.classList.add('hidden'); }
  if (e.data.action === 'previewJob' && e.data.id) selectJob(e.data.id, true);
  if (e.data.action === 'calibrateJob' && e.data.id) setCalibrationMode(e.data.id);
});

document.getElementById('close').onclick = close;
searchEl.oninput = (e) => { state.search = e.target.value; renderJobs(); };
document.getElementById('waypoint').onclick = () => state.selected && post('setWaypoint', { id: state.selected.id });
document.getElementById('select-job').onclick = () => state.selected && state.currentJob !== state.selected.job && post('selectJob', { id: state.selected.id });
adminBackButton.onclick = beginNewAdminJob;
document.getElementById('admin-new-job').onclick = beginNewAdminJob;

document.getElementById('admin-use-position').onclick = async () => {
  const res = await post('adminGetCurrentPosition');
  if (res?.success) {
    state.adminDraft = readAdminForm();
    state.adminDraft.location = res.location;
    if (!state.adminDraft.map) state.adminDraft.map = res.map;
    applyAdminDraftToForm();
  }
};

document.getElementById('admin-save').onclick = async () => {
  const payload = readAdminForm();
  if (!payload.location) {
    const res = await post('adminGetCurrentPosition');
    if (res?.success) {
      payload.location = res.location;
      if (!payload.map) payload.map = res.map;
    }
  }

  const res = await post('adminSaveJob', payload);
  if (res?.success) {
    if (res.job) {
      const saved = {
        ...res.job,
        map: res.job.mapOverride || payload.map || res.job.map || { x: 50, y: 50 },
        sortOrder: res.job.sortOrder ?? payload.sortOrder ?? 0
      };
      state.adminDraft = null;
      updateJobsAndSelection(state.jobs.filter(j => j.id !== saved.id).concat([saved]), saved.id);
    }
  }
};

document.getElementById('admin-delete').onclick = async () => {
  const current = readAdminForm();
  const id = current.oldId || current.id;
  if (!id) return;
  if (!window.confirm('Slet dette job?')) return;
  const res = await post('adminDeleteJob', { id });
  if (res?.success) {
    state.jobs = state.jobs.filter(j => j.id !== id);
    renderCategories();
    renderJobs();
    renderMarkers();
    beginNewAdminJob();
  }
};

adminCalibrateButton.onclick = async () => {
  const current = readAdminForm();
  const id = current.oldId || current.id;
  if (!id) return;
  await post('adminStartCalibration', { id });
};

Object.values(adminFields).forEach(field => field.addEventListener('input', () => {
  if (!state.admin) return;
  state.adminDraft = { ...readAdminForm() };
  applyAdminDraftToForm();
}));

document.addEventListener('keyup', (e) => {
  if (e.key === 'Escape') close();
});
