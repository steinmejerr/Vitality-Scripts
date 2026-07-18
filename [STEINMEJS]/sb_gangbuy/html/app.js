const app = document.getElementById('app');
const content = document.getElementById('content');
const profile = document.getElementById('profile');
let state = null;
let activeTab = 'overview';
let timer;

const post = async (endpoint, data = {}) => {
    const response = await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(data)
    });
    return response.json();
};

const money = value => new Intl.NumberFormat('da-DK').format(value || 0);
const escapeHtml = value => String(value ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#039;','"':'&quot;'}[c]));
const remaining = unix => Math.max(0, Number(unix || 0) - Math.floor(Date.now() / 1000));
const clock = seconds => `${String(Math.floor(seconds / 60)).padStart(2,'0')}:${String(seconds % 60).padStart(2,'0')}`;

function renderProfile() {
    const p = state.player;
    const next = p.nextLevelXp;
    const previous = p.level > 1 ? 0 : 0;
    const percent = next ? Math.min(100, Math.round((p.xp / next) * 100)) : 100;
    profile.innerHTML = `
        <div class="profile-card"><span>Identitet</span><strong>${escapeHtml(p.name)} · ${escapeHtml(p.gang)}</strong></div>
        <div class="profile-card"><span>Banderang</span><strong>${escapeHtml(p.gradeLabel)} · Grade ${p.grade}</strong></div>
        <div class="profile-card"><span>Progression</span><strong>Level ${p.level} · ${money(p.xp)} XP</strong><div class="progress"><i style="width:${percent}%"></i></div></div>`;
}

function card(item, kind) {
    const isProduct = kind === 'product';
    const buttonText = item.unlocked ? (isProduct ? 'Bestil varen' : 'Start mission') : `Kræver level ${item.requiredLevel} / grade ${item.requiredGrade}`;
    return `<article class="card ${item.unlocked ? '' : 'locked'}">
        <div class="card-icon"><i class="${escapeHtml(item.icon || 'fa-solid fa-box')}"></i></div>
        <h3>${escapeHtml(item.label)}</h3><p>${escapeHtml(item.description)}</p>
        <div class="meta"><span>Level ${item.requiredLevel}</span><span>Grade ${item.requiredGrade}</span>${isProduct ? `<span>${item.deliveryMin}-${item.deliveryMax} min.</span>` : `<span>+${money(item.xp)} XP</span>`}</div>
        <div class="price">${isProduct ? `$${money(item.price)}` : `$${money(item.money)} belønning`}</div>
        <button class="primary action" data-kind="${kind}" data-id="${escapeHtml(item.id)}" ${item.unlocked ? '' : 'disabled'}>${buttonText}</button>
    </article>`;
}

function renderOverview() {
    const p = state.player;
    const orderText = state.activeOrder ? (state.activeOrder.status === 'ready' ? 'Klar til afhentning' : `Klar om ${clock(remaining(state.activeOrder.readyAt))}`) : 'Ingen aktiv';
    const missionText = state.activeMission ? (state.activeMission.status === 'ready' ? 'GPS modtaget' : `Klar om ${clock(remaining(state.activeMission.readyAt))}`) : 'Ingen aktiv';
    content.innerHTML = `<div class="hero-grid">
        <div class="hero"><span class="eyebrow">DIN POSITION</span><h2>Bevis dit værd for forbindelsen</h2><p>Gennemfør opgaver for at optjene XP. Højere level og banderang låser op for bedre varer, større belønninger og mere værdifulde leveringer.</p></div>
        <div class="stat-stack"><div class="stat"><span>Fuldførte missioner</span><strong>${p.completedMissions}</strong></div><div class="stat"><span>Næste level</span><strong>${p.nextLevelXp ? `${money(p.nextLevelXp - p.xp)} XP` : 'Maksimum'}</strong></div></div>
    </div><div class="grid" style="margin-top:14px"><div class="card"><h3>Aktiv mission</h3><p>${missionText}</p><button class="secondary switch" data-tab="missions">Se missioner</button></div><div class="card"><h3>Aktiv levering</h3><p>${orderText}</p><button class="secondary switch" data-tab="delivery">Se levering</button></div><div class="card"><h3>Tilgængelige varer</h3><p>${state.products.filter(x=>x.unlocked).length} af ${state.products.length} varer er låst op.</p><button class="secondary switch" data-tab="shop">Åbn markedet</button></div></div>`;
}

function renderMissions() {
    content.innerHTML = `<div class="section-head"><div><h2>Missioner</h2><p>Gennemfør opgaver og opbyg dit ry.</p></div><span class="pill">Cooldown: ${state.missionCooldown ? clock(state.missionCooldown) : 'Klar'}</span></div>${state.activeMission ? `<div class="delivery"><div><h3>${escapeHtml(state.activeMission.label)}</h3><p>${state.activeMission.status === 'ready' ? 'GPS-positionen er klar.' : `Kontakten gør pakken klar · ${clock(remaining(state.activeMission.readyAt))}`}</p></div></div>` : `<div class="grid">${state.missions.map(x=>card(x,'mission')).join('')}</div>`}`;
}

function renderShop() {
    content.innerHTML = `<div class="section-head"><div><h2>Diskrete varer</h2><p>Betaling sker nu. GPS sendes, når leveringen er klar.</p></div><span class="pill">Én aktiv ordre ad gangen</span></div><div class="grid">${state.products.map(x=>card(x,'product')).join('')}</div>`;
}

function renderDelivery() {
    const o = state.activeOrder;
    content.innerHTML = `<div class="section-head"><div><h2>Din levering</h2><p>Leveringen forsvinder, hvis den ikke afhentes i tide.</p></div></div>${!o ? '<div class="empty">Du har ingen aktiv levering.</div>' : `<div class="delivery"><div><h3>${escapeHtml(o.label)} · ${o.amount}x</h3><p>${o.status === 'ready' ? 'Leveringen er klar. GPS-positionen er sendt.' : `Forventet klar om ${clock(remaining(o.readyAt))}`}</p></div>${o.status === 'ready' && o.coords ? '<button class="primary gps">Marker GPS</button>' : ''}</div>`}`;
}

function render() {
    renderProfile();
    document.querySelectorAll('.tab').forEach(btn => btn.classList.toggle('active', btn.dataset.tab === activeTab));
    ({overview:renderOverview, missions:renderMissions, shop:renderShop, delivery:renderDelivery}[activeTab] || renderOverview)();
    bindActions();
}

function bindActions() {
    document.querySelectorAll('.switch').forEach(b => b.onclick = () => { activeTab = b.dataset.tab; render(); });
    document.querySelectorAll('.action').forEach(b => b.onclick = async () => {
        b.disabled = true;
        const endpoint = b.dataset.kind === 'product' ? 'buyProduct' : 'startMission';
        const result = await post(endpoint, { id: b.dataset.id });
        if (result.success) await refresh(); else b.disabled = false;
    });
    const gps = document.querySelector('.gps');
    if (gps && state.activeOrder?.coords) gps.onclick = () => post('setGps', { coords: state.activeOrder.coords });
}

async function refresh() {
    const fresh = await post('refresh');
    if (fresh?.allowed) { state = fresh; render(); }
}

window.addEventListener('message', e => {
    const msg = e.data;
    if (msg.action === 'open') { state = msg.data; activeTab = 'overview'; app.classList.remove('hidden'); render(); clearInterval(timer); timer = setInterval(render, 1000); }
    if (msg.action === 'close') { app.classList.add('hidden'); clearInterval(timer); }
    if (msg.action === 'orderReady') { if (state) { state.activeOrder = msg.order; render(); } }
    if (msg.action === 'missionReady') { if (state) { state.activeMission = msg.mission; render(); } }
    if (msg.action === 'refreshRequested') refresh();
});

document.getElementById('close').onclick = () => post('close');
document.querySelectorAll('.tab').forEach(btn => btn.onclick = () => { activeTab = btn.dataset.tab; render(); });
document.addEventListener('keydown', e => { if (e.key === 'Escape') post('close'); });
