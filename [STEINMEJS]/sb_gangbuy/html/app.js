const app = document.getElementById('app');
const content = document.getElementById('content');
const profile = document.getElementById('profile');
const tabs = document.getElementById('tabs');
const title = document.getElementById('title');
const subtitle = document.getElementById('subtitle');
const eyebrow = document.getElementById('eyebrow');
let state = null;
let mode = 'player';
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

function setTabs(items) {
    tabs.innerHTML = items.map(x => `<button class="tab ${x.id === activeTab ? 'active' : ''}" data-tab="${x.id}"><i class="${x.icon}"></i> ${x.label}</button>`).join('');
    tabs.querySelectorAll('.tab').forEach(btn => btn.onclick = () => { activeTab = btn.dataset.tab; render(); });
}

function renderProfile() {
    const p = state.player;
    const percent = p.nextLevelXp ? Math.min(100, Math.round((p.xp / p.nextLevelXp) * 100)) : 100;
    profile.classList.remove('hidden');
    profile.innerHTML = `
        <div class="profile-card"><span>Spiller</span><strong>${escapeHtml(p.name)} · ${escapeHtml(p.gang)}</strong></div>
        <div class="profile-card"><span>Rang</span><strong>${escapeHtml(p.gradeLabel)} · Grade ${p.grade}</strong></div>
        <div class="profile-card"><span>Erfaring</span><strong>Level ${p.level} · ${money(p.xp)} XP</strong><div class="progress"><i style="width:${percent}%"></i></div></div>`;
}

function card(item, kind) {
    const isProduct = kind === 'product';
    const buttonText = item.unlocked ? (isProduct ? 'Bestil' : 'Tag opgaven') : `Level ${item.requiredLevel} · Grade ${item.requiredGrade}`;
    return `<article class="card ${item.unlocked ? '' : 'locked'}">
        <div class="card-icon"><i class="${escapeHtml(item.icon || 'fa-solid fa-box')}"></i></div>
        <h3>${escapeHtml(item.label)}</h3><p>${escapeHtml(item.description)}</p>
        <div class="meta"><span>Level ${item.requiredLevel}</span><span>Grade ${item.requiredGrade}</span>${isProduct ? `<span>${item.deliveryMin}-${item.deliveryMax} min.</span>` : `<span>+${money(item.xp)} XP</span>`}</div>
        ${isProduct ? `<div class="price black-money-price"><span>$${money(item.price)}</span><small><i class="fa-solid fa-sack-dollar"></i> Sorte penge</small></div>` : `<div class="price">$${money(item.money)}</div>`}
        <button class="primary action" data-kind="${kind}" data-id="${escapeHtml(item.id)}" ${item.unlocked ? '' : 'disabled'}>${buttonText}</button>
    </article>`;
}

function renderOverview() {
    const p = state.player;
    const orderText = state.activeOrder ? (state.activeOrder.status === 'ready' ? 'Klar til afhentning' : `Klar om ${clock(remaining(state.activeOrder.readyAt))}`) : 'Ingen';
    const missionText = state.activeMission ? (state.activeMission.status === 'returning' ? 'Aflever pakken hos kontakten' : state.activeMission.status === 'ready' ? 'GPS klar' : `Klar om ${clock(remaining(state.activeMission.readyAt))}`) : 'Ingen';
    content.innerHTML = `<div class="hero-grid">
        <div class="hero"><span class="eyebrow">STATUS</span><h2>Arbejd dig op</h2><p>Tag opgaver, tjen XP og lås op for flere varer.</p></div>
        <div class="stat-stack"><div class="stat"><span>Opgaver klaret</span><strong>${p.completedMissions}</strong></div><div class="stat"><span>Næste level</span><strong>${p.nextLevelXp ? `${money(p.nextLevelXp - p.xp)} XP` : 'Maksimum'}</strong></div></div>
    </div><div class="grid" style="margin-top:14px"><div class="card"><h3>Aktiv opgave</h3><p>${missionText}</p><button class="secondary switch" data-tab="missions">Se opgaver</button></div><div class="card"><h3>Aktiv ordre</h3><p>${orderText}</p><button class="secondary switch" data-tab="delivery">Se ordre</button></div><div class="card"><h3>Varer åbnet</h3><p>${state.products.filter(x=>x.unlocked).length} af ${state.products.length} varer åbne.</p><button class="secondary switch" data-tab="shop">Se varer</button></div></div>`;
}

function renderMissions() {
    content.innerHTML = `<div class="section-head"><div><h2>Opgaver</h2><p>Vælg en opgave fra kontakten.</p></div><span class="pill">Ny opgave: ${state.missionCooldown ? clock(state.missionCooldown) : 'Klar'}</span></div>${state.activeMission ? `<div class="delivery"><div><h3>${escapeHtml(state.activeMission.label)}</h3><p>${state.activeMission.status === 'returning' ? 'Du har hentet pakken. Aflever den tilbage hos kontakten.' : state.activeMission.status === 'ready' ? 'GPS er klar.' : `Pakken bliver gjort klar · ${clock(remaining(state.activeMission.readyAt))}`}</p></div></div>` : `<div class="grid">${state.missions.map(x=>card(x,'mission')).join('')}</div>`}`;
}

function renderShop() {
    content.innerHTML = `<div class="section-head"><div><h2>Varer</h2><p>Alle varer betales med sorte penge. GPS kommer, når ordren er klar.</p></div><span class="pill black-money-pill"><i class="fa-solid fa-sack-dollar"></i> Sorte penge</span></div><div class="grid">${state.products.map(x=>card(x,'product')).join('')}</div>`;
}

function renderDelivery() {
    const o = state.activeOrder;
    content.innerHTML = `<div class="section-head"><div><h2>Din ordre</h2><p>Hent ordren, før tiden løber ud.</p></div></div>${!o ? '<div class="empty">Du har ingen aktiv ordre.</div>' : `<div class="delivery"><div><h3>${escapeHtml(o.label)} · ${o.amount}x</h3><p>${o.status === 'ready' ? 'Ordren er klar. GPS er sendt.' : `Klar om ${clock(remaining(o.readyAt))}`}</p></div>${o.status === 'ready' && o.coords ? '<button class="primary gps">Sæt GPS</button>' : ''}</div>`}`;
}

function adminList(kind, items) {
    const singular = { gang:'bande', product:'vare', mission:'mission' }[kind];
    return `<div class="section-head"><div><h2>${{gang:'Bander',product:'Varer',mission:'Missioner'}[kind]}</h2><p>Tilføj, rediger eller slet.</p></div><button class="primary compact add-admin" data-kind="${kind}"><i class="fa-solid fa-plus"></i> Tilføj ${singular}</button></div>
    <div class="admin-list">${items.length ? items.map(item => `<div class="admin-row">
        <div class="admin-row-main"><strong>${escapeHtml(item.label)}</strong><span>${kind === 'gang' ? escapeHtml(item.jobName) + ` · Grade ${item.minimumGrade}` : escapeHtml(item.id)}</span></div>
        <div class="row-actions"><button class="secondary compact edit-admin" data-kind="${kind}" data-id="${escapeHtml(kind === 'gang' ? item.jobName : item.id)}"><i class="fa-solid fa-pen"></i> Rediger</button><button class="danger compact delete-admin" data-kind="${kind}" data-id="${escapeHtml(kind === 'gang' ? item.jobName : item.id)}"><i class="fa-solid fa-trash"></i> Slet</button></div>
    </div>`).join('') : '<div class="empty">Der er ikke oprettet noget endnu.</div>'}</div>`;
}

function adminFields(kind, item = {}) {
    const field = (name,label,type='text',value='',min='') => `<label><span>${label}</span><input name="${name}" type="${type}" value="${escapeHtml(value)}" ${min !== '' ? `min="${min}"` : ''}></label>`;
    const area = (name,label,value='') => `<label class="wide"><span>${label}</span><textarea name="${name}">${escapeHtml(value)}</textarea></label>`;
    if (kind === 'gang') return `${field('jobName','ESX-jobnavn','text',item.jobName||'')}${field('label','Navn','text',item.label||'')}${field('minimumGrade','Minimum grade','number',item.minimumGrade??0,0)}`;
    if (kind === 'product') return `${field('id','ID','text',item.id||'')}${field('label','Navn','text',item.label||'')}${area('description','Beskrivelse',item.description||'')}${field('item','Item-navn','text',item.item||'')}${field('amount','Antal','number',item.amount??1,1)}${field('price','Pris i sorte penge','number',item.price??0,0)}${field('requiredLevel','Krævet level','number',item.requiredLevel??1,1)}${field('requiredGrade','Krævet grade','number',item.requiredGrade??0,0)}${field('deliveryMin','Min. leveringstid i minutter','number',item.deliveryMin??1,0)}${field('deliveryMax','Maks. leveringstid i minutter','number',item.deliveryMax??1,0)}${field('icon','Font Awesome ikon','text',item.icon||'fa-solid fa-box')}`;
    return `${field('id','ID','text',item.id||'')}${field('label','Navn','text',item.label||'')}${area('description','Beskrivelse',item.description||'')}${field('requiredLevel','Krævet level','number',item.requiredLevel??1,1)}${field('requiredGrade','Krævet grade','number',item.requiredGrade??0,0)}${field('xp','XP-belønning','number',item.xp??0,0)}${field('money','Penge-belønning','number',item.money??0,0)}${field('waitMin','Min. ventetid i sekunder','number',item.waitMin??10,0)}${field('waitMax','Maks. ventetid i sekunder','number',item.waitMax??10,0)}${field('icon','Font Awesome ikon','text',item.icon||'fa-solid fa-box')}`;
}

function openAdminForm(kind, item) {
    const originalId = item ? (kind === 'gang' ? item.jobName : item.id) : '';
    content.innerHTML = `<div class="section-head"><div><h2>${item ? 'Rediger' : 'Tilføj'} ${{gang:'bande',product:'vare',mission:'mission'}[kind]}</h2><p>Ændringer bliver gemt med det samme.</p></div><button class="secondary compact back-admin"><i class="fa-solid fa-arrow-left"></i> Tilbage</button></div>
    <form id="admin-form" class="admin-form" data-kind="${kind}" data-original="${escapeHtml(originalId)}">${adminFields(kind,item)}<div class="form-actions"><button type="button" class="secondary cancel-admin">Annuller</button><button type="submit" class="primary">Gem</button></div></form>`;
    bindAdminForm();
}

function bindAdminForm() {
    const back = document.querySelector('.back-admin');
    const cancel = document.querySelector('.cancel-admin');
    if (back) back.onclick = () => render();
    if (cancel) cancel.onclick = () => render();
    const form = document.getElementById('admin-form');
    if (form) form.onsubmit = async e => {
        e.preventDefault();
        const data = Object.fromEntries(new FormData(form).entries());
        const result = await post('adminSave',{kind:form.dataset.kind,originalId:form.dataset.original || null,data});
        if (result.success && result.data) { state=result.data; render(); }
    };
}

function renderAdmin() {
    profile.classList.add('hidden');
    setTabs([
        {id:'gangs',label:'Bander',icon:'fa-solid fa-users'},
        {id:'products',label:'Varer',icon:'fa-solid fa-boxes-stacked'},
        {id:'adminmissions',label:'Missioner',icon:'fa-solid fa-list-check'}
    ]);
    if (activeTab === 'products') content.innerHTML = adminList('product',state.products||[]);
    else if (activeTab === 'adminmissions') content.innerHTML = adminList('mission',state.missions||[]);
    else content.innerHTML = adminList('gang',state.gangs||[]);
    bindAdminActions();
}


function openConfirm(titleText, messageText) {
    return new Promise(resolve => {
        const overlay = document.createElement('div');
        overlay.className = 'confirm-overlay';
        overlay.innerHTML = `
            <div class="confirm-box" role="dialog" aria-modal="true" aria-labelledby="confirm-title">
                <div class="confirm-icon"><i class="fa-solid fa-trash"></i></div>
                <h3 id="confirm-title">${escapeHtml(titleText)}</h3>
                <p>${escapeHtml(messageText)}</p>
                <div class="confirm-actions">
                    <button class="secondary compact confirm-cancel">Annuller</button>
                    <button class="danger compact confirm-delete">Slet</button>
                </div>
            </div>`;

        const finish = value => {
            document.removeEventListener('keydown', onKeyDown);
            overlay.remove();
            resolve(value);
        };
        const onKeyDown = event => {
            if (event.key === 'Escape') finish(false);
            if (event.key === 'Enter') finish(true);
        };

        overlay.querySelector('.confirm-cancel').onclick = () => finish(false);
        overlay.querySelector('.confirm-delete').onclick = () => finish(true);
        overlay.onclick = event => { if (event.target === overlay) finish(false); };
        document.addEventListener('keydown', onKeyDown);
        document.body.appendChild(overlay);
        overlay.querySelector('.confirm-delete').focus();
    });
}

function bindAdminActions() {
    document.querySelectorAll('.add-admin').forEach(b => b.onclick = () => openAdminForm(b.dataset.kind));
    document.querySelectorAll('.edit-admin').forEach(b => b.onclick = () => {
        const list = b.dataset.kind === 'gang' ? state.gangs : b.dataset.kind === 'product' ? state.products : state.missions;
        const item = list.find(x => (b.dataset.kind === 'gang' ? x.jobName : x.id) === b.dataset.id);
        if (item) openAdminForm(b.dataset.kind,item);
    });
    document.querySelectorAll('.delete-admin').forEach(b => b.onclick = async () => {
        const confirmed = await openConfirm('Slet element', 'Er du sikker på, at du vil slette den?');
        if (!confirmed) return;

        b.disabled = true;
        try {
            const result = await post('adminDelete', { kind: b.dataset.kind, id: b.dataset.id });
            if (result && result.success && result.data) {
                state = result.data;
                render();
            }
        } finally {
            if (document.body.contains(b)) b.disabled = false;
        }
    });
}

function renderPlayer() {
    setTabs([
        {id:'overview',label:'Overblik',icon:'fa-solid fa-chart-line'},
        {id:'missions',label:'Missioner',icon:'fa-solid fa-list-check'},
        {id:'shop',label:'Varer',icon:'fa-solid fa-boxes-stacked'},
        {id:'delivery',label:'Levering',icon:'fa-solid fa-truck-fast'}
    ]);
    renderProfile();
    ({overview:renderOverview, missions:renderMissions, shop:renderShop, delivery:renderDelivery}[activeTab] || renderOverview)();
    bindPlayerActions();
}

function render() {
    if (mode === 'admin') renderAdmin(); else renderPlayer();
}

function bindPlayerActions() {
    document.querySelectorAll('.switch').forEach(b => b.onclick = () => { activeTab=b.dataset.tab; render(); });
    document.querySelectorAll('.action').forEach(b => b.onclick = async () => {
        b.disabled=true;
        const endpoint=b.dataset.kind === 'product' ? 'buyProduct' : 'startMission';
        const result=await post(endpoint,{id:b.dataset.id});
        if (result.success) await refresh(); else b.disabled=false;
    });
    const gps=document.querySelector('.gps');
    if (gps && state.activeOrder?.coords) gps.onclick=()=>post('setGps',{coords:state.activeOrder.coords});
}

async function refresh() {
    const fresh=await post(mode === 'admin' ? 'adminRefresh' : 'refresh');
    if (fresh?.allowed) { state=fresh; render(); }
}

window.addEventListener('message', e => {
    const msg=e.data;
    if (msg.action === 'open') {
        mode='player'; state=msg.data; activeTab='overview'; eyebrow.textContent='HANDEL'; title.textContent='Kontakten'; subtitle.textContent='Køb varer med sorte penge og tag arbejde for kontakten.';
        app.classList.remove('hidden'); render(); clearInterval(timer); timer=setInterval(render,1000);
    }
    if (msg.action === 'openAdmin') {
        mode='admin'; state=msg.data; activeTab='gangs'; eyebrow.textContent='ADMINISTRATION'; title.textContent='Gangbuy Admin'; subtitle.textContent='Administrér bander, varer og missioner.';
        app.classList.remove('hidden'); clearInterval(timer); render();
    }
    if (msg.action === 'close') { app.classList.add('hidden'); clearInterval(timer); }
    if (msg.action === 'orderReady' && mode === 'player') { if (state) { state.activeOrder=msg.order; render(); } }
    if (msg.action === 'missionReady' && mode === 'player') { if (state) { state.activeMission=msg.mission; render(); } }
    if (msg.action === 'refreshRequested' && mode === 'player') refresh();
});

document.getElementById('close').onclick=()=>post('close');
document.addEventListener('keydown',e=>{if(e.key==='Escape')post('close');});
