(() => {
  const notifyRoot = document.createElement('div');
  notifyRoot.id = 'vitality-notify-root';
  document.body.appendChild(notifyRoot);

  const progressRoot = document.createElement('div');
  progressRoot.id = 'vitality-progress-root';
  document.body.appendChild(progressRoot);

  const settingsRoot = document.createElement('div');
  settingsRoot.id = 'vitality-notify-settings-root';
  document.body.appendChild(settingsRoot);

  const notifyStacks = new Map();
  const notifications = new Map();
  let activeProgress = null;

  const labels = {
    success: 'Gennemført',
    error: 'Fejl',
    warning: 'Advarsel',
    info: 'Information',
    inform: 'Information'
  };

  const validPositions = ['top', 'top-right', 'top-left', 'bottom', 'bottom-right', 'bottom-left', 'center-right', 'center-left'];

  const getNotifyStack = (position) => {
    const value = validPositions.includes(position) ? position : 'bottom';
    if (notifyStacks.has(value)) return notifyStacks.get(value);
    const stack = document.createElement('div');
    stack.className = `v-notify-stack v-pos-${value}`;
    notifyRoot.appendChild(stack);
    notifyStacks.set(value, stack);
    return stack;
  };

  const removeNotification = (entry) => {
    if (!entry || entry.removing) return;
    entry.removing = true;
    clearTimeout(entry.timer);
    entry.element.classList.add('v-leaving');
    setTimeout(() => {
      entry.element.remove();
      if (entry.id) notifications.delete(entry.id);
    }, 220);
  };

  const showNotification = (data) => {
    if (!data || (!data.title && !data.description)) return;

    const id = data.id != null ? String(data.id) : null;
    if (id && notifications.has(id)) removeNotification(notifications.get(id));

    const type = ['success', 'error', 'warning', 'info', 'inform'].includes(data.type) ? data.type : 'info';
    const duration = Math.max(750, Number(data.duration) || 3500);
    const element = document.createElement('div');
    element.className = `v-notify v-notify-${type}`;
    element.style.setProperty('--duration', `${duration}ms`);

    const head = document.createElement('div');
    head.className = 'v-notify-head';

    const kicker = document.createElement('div');
    kicker.className = 'v-notify-kicker';
    kicker.textContent = labels[type];

    const time = document.createElement('div');
    time.className = 'v-notify-time';
    time.textContent = `${Math.ceil(duration / 1000)} sek.`;

    head.append(kicker, time);
    element.appendChild(head);

    if (data.title) {
      const title = document.createElement('div');
      title.className = 'v-notify-title';
      title.textContent = String(data.title);
      element.appendChild(title);
    }

    if (data.description) {
      const description = document.createElement('div');
      description.className = 'v-notify-description';
      description.textContent = String(data.description);
      element.appendChild(description);
    }

    if (data.showDuration !== false) {
      const progress = document.createElement('div');
      progress.className = 'v-notify-progress';
      element.appendChild(progress);
    }

    if (data.style && typeof data.style === 'object') Object.assign(element.style, data.style);

    const entry = { id, element, timer: null, removing: false };
    getNotifyStack(data.position).appendChild(element);
    entry.timer = setTimeout(() => removeNotification(entry), duration);
    if (id) notifications.set(id, entry);
  };

  const postComplete = () => {
    try {
      const request = new XMLHttpRequest();
      request.open('POST', `https://${GetParentResourceName()}/progressComplete`, true);
      request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
      request.send('{}');
    } catch (_) {}
  };

  const removeProgress = (complete) => {
    if (!activeProgress) return;
    const entry = activeProgress;
    activeProgress = null;
    cancelAnimationFrame(entry.frame);
    entry.element.classList.add('v-leaving');
    setTimeout(() => entry.element.remove(), 220);
    if (complete) postComplete();
  };

  const addCancelHint = (card, canCancel, extraClass) => {
    if (!canCancel) return;
    const hint = document.createElement('div');
    hint.className = `v-progress-cancel${extraClass ? ` ${extraClass}` : ''}`;
    const key = document.createElement('span');
    key.className = 'v-key';
    key.textContent = 'X';
    hint.append(key, document.createTextNode('Tryk for at afslutte handlingen'));
    card.appendChild(hint);
  };

  const createBar = (data) => {
    const wrap = document.createElement('div');
    wrap.className = 'v-progress-wrap';
    if (data.position === 'middle') wrap.classList.add('v-middle');

    const card = document.createElement('div');
    card.className = 'v-progress-card';

    const kicker = document.createElement('div');
    kicker.className = 'v-progress-kicker';
    kicker.textContent = '';

    const top = document.createElement('div');
    top.className = 'v-progress-topline';

    const label = document.createElement('div');
    label.className = 'v-progress-label';
    label.textContent = data.label ? String(data.label) : 'Arbejder...';

    const value = document.createElement('div');
    value.className = 'v-progress-value';
    value.textContent = '0%';

    const track = document.createElement('div');
    track.className = 'v-progress-track';

    const fill = document.createElement('div');
    fill.className = 'v-progress-fill';

    top.append(label, value);
    track.appendChild(fill);
    card.append(kicker, top, track);
    addCancelHint(card, data.canCancel);
    wrap.appendChild(card);
    progressRoot.appendChild(wrap);

    return { element: wrap, value, fill, variant: 'bar' };
  };

  const createCircle = (data) => {
    const wrap = document.createElement('div');
    wrap.className = 'v-progress-wrap v-circle-wrap';
    if (data.position === 'middle') wrap.classList.add('v-middle');

    const card = document.createElement('div');
    card.className = 'v-progress-card v-circle-card';

    const kicker = document.createElement('div');
    kicker.className = 'v-progress-kicker';
    kicker.textContent = '';

    const label = document.createElement('div');
    label.className = 'v-circle-label';
    label.textContent = data.label ? String(data.label) : 'Arbejder...';

    const shell = document.createElement('div');
    shell.className = 'v-circle-shell';

    const svgNS = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(svgNS, 'svg');
    svg.setAttribute('viewBox', '0 0 120 120');
    svg.classList.add('v-circle-svg');

    const track = document.createElementNS(svgNS, 'circle');
    track.setAttribute('cx', '60');
    track.setAttribute('cy', '60');
    track.setAttribute('r', '48');
    track.setAttribute('class', 'v-circle-track');

    const ring = document.createElementNS(svgNS, 'circle');
    ring.setAttribute('cx', '60');
    ring.setAttribute('cy', '60');
    ring.setAttribute('r', '48');
    ring.setAttribute('class', 'v-circle-ring');

    const value = document.createElement('div');
    value.className = 'v-circle-value';
    value.textContent = '0%';

    svg.append(track, ring);
    shell.append(svg, value);
    card.append(kicker, label, shell);
    addCancelHint(card, data.canCancel, "v-circle-cancel");
    wrap.appendChild(card);
    progressRoot.appendChild(wrap);

    const circumference = 2 * Math.PI * 48;
    ring.style.strokeDasharray = `${circumference}`;
    ring.style.strokeDashoffset = `${circumference}`;

    return { element: wrap, value, ring, circumference, variant: 'circle' };
  };

  const showProgress = (data) => {
    removeProgress(false);
    const duration = Math.max(100, Number(data.duration) || 1000);
    const ui = data.variant === 'circle' ? createCircle(data) : createBar(data);
    const entry = { ...ui, frame: 0 };
    activeProgress = entry;
    const started = performance.now();

    const tick = (now) => {
      if (activeProgress !== entry) return;
      const ratio = Math.min(1, (now - started) / duration);
      entry.value.textContent = `${Math.floor(ratio * 100)}%`;

      if (entry.variant === 'circle') {
        entry.ring.style.strokeDashoffset = `${entry.circumference * (1 - ratio)}`;
      } else {
        entry.fill.style.width = `${ratio * 100}%`;
      }

      if (ratio >= 1) {
        entry.value.textContent = '100%';
        removeProgress(true);
        return;
      }

      entry.frame = requestAnimationFrame(tick);
    };

    entry.frame = requestAnimationFrame(tick);
  };

  let notifySettingsSoundEnabled = true;

  const postNui = (name, data = {}) => {
    try {
      return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
      });
    } catch (_) {}
  };

  const closeNotifySettings = () => {
    settingsRoot.classList.remove('v-open');
    settingsRoot.innerHTML = '';
  };

  const renderNotifySettings = (soundEnabled) => {
    notifySettingsSoundEnabled = soundEnabled === true;
    settingsRoot.innerHTML = '';

    const backdrop = document.createElement('div');
    backdrop.className = 'v-settings-backdrop';

    const panel = document.createElement('div');
    panel.className = 'v-settings-panel';

    const eyebrow = document.createElement('div');
    eyebrow.className = 'v-settings-eyebrow';
    eyebrow.textContent = 'Indstillinger';

    const title = document.createElement('div');
    title.className = 'v-settings-title';
    title.textContent = 'Notifikationer';

    const subtitle = document.createElement('div');
    subtitle.className = 'v-settings-subtitle';
    subtitle.textContent = 'Vælg om notifikationer skal afspille en lyd.';

    const row = document.createElement('div');
    row.className = 'v-settings-row';

    const text = document.createElement('div');
    const rowTitle = document.createElement('div');
    rowTitle.className = 'v-settings-row-title';
    rowTitle.textContent = 'Notify-lyd';
    const rowDescription = document.createElement('div');
    rowDescription.className = 'v-settings-row-description';
    rowDescription.textContent = 'Afspil en kort lyd, når en ny besked vises.';
    text.append(rowTitle, rowDescription);

    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = `v-settings-switch${notifySettingsSoundEnabled ? ' v-active' : ''}`;
    toggle.setAttribute('aria-label', 'Slå notify-lyd til eller fra');
    toggle.addEventListener('click', () => {
      notifySettingsSoundEnabled = !notifySettingsSoundEnabled;
      toggle.classList.toggle('v-active', notifySettingsSoundEnabled);
    });

    row.append(text, toggle);

    const actions = document.createElement('div');
    actions.className = 'v-settings-actions';

    const cancel = document.createElement('button');
    cancel.type = 'button';
    cancel.className = 'v-settings-button';
    cancel.textContent = 'Annuller';
    cancel.addEventListener('click', () => postNui('vitalityNotifySettingsClose'));

    const save = document.createElement('button');
    save.type = 'button';
    save.className = 'v-settings-button v-primary';
    save.textContent = 'Gem';
    save.addEventListener('click', () => postNui('vitalityNotifySettingsSave', {
      soundEnabled: notifySettingsSoundEnabled
    }));

    actions.append(cancel, save);
    panel.append(eyebrow, title, subtitle, row, actions);
    settingsRoot.append(backdrop, panel);
    settingsRoot.classList.add('v-open');
  };

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && settingsRoot.classList.contains('v-open')) {
      postNui('vitalityNotifySettingsClose');
    }
  });

  window.addEventListener('message', (event) => {
    const message = event.data;
    if (message?.action === 'vitalityNotify') showNotification(message.data || {});
    if (message?.action === 'vitalityProgress') showProgress(message.data || {});
    if (message?.action === 'vitalityProgressCancel') removeProgress(false);
    if (message?.action === 'vitalityNotifySettingsOpen') renderNotifySettings(message.soundEnabled);
    if (message?.action === 'vitalityNotifySettingsClose') closeNotifySettings();
  });
})();
