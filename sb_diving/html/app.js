const app = document.getElementById('app');
const content = document.getElementById('content');
const tabs = [...document.querySelectorAll('.tabs button')];
const closeButton = document.getElementById('close');
const oxygenHud = document.getElementById('oxygen-hud');
const oxygenFill = document.getElementById('oxygen-fill');
const oxygenTime = document.getElementById('oxygen-time');
const oxygenState = document.getElementById('oxygen-state');
const missionHud = document.getElementById('mission-hud');
const missionHudTitle = document.getElementById('mission-hud-title');
const missionHudRemaining = document.getElementById('mission-hud-remaining');
const missionHudProgressText = document.getElementById('mission-hud-progress-text');
const missionHudPercent = document.getElementById('mission-hud-percent');
const missionProgressFill = document.getElementById('mission-progress-fill');
const missionGuideList = document.getElementById('mission-guide-list');


let state = { view: 'shop', data: null };
let cooldownTimer = null;
let serverClockOffsetMs = 0;

const post = async (event, payload = {}) => {
    const response = await fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    });
    return response.json();
};

const money = value => new Intl.NumberFormat('da-DK').format(Number(value || 0));
const escapeHtml = value => String(value ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));


function syncServerClock() {
    const serverNow = Number(state.data?.missionCooldown?.serverNow || 0);
    if (serverNow > 0) serverClockOffsetMs = (serverNow * 1000) - Date.now();
}

function getCooldownRemaining() {
    const expiresAt = Number(state.data?.missionCooldown?.expiresAt || 0);
    if (expiresAt <= 0) return 0;
    const nowSeconds = Math.floor((Date.now() + serverClockOffsetMs) / 1000);
    return Math.max(0, expiresAt - nowSeconds);
}

function formatCountdown(totalSeconds) {
    const seconds = Math.max(0, Math.floor(Number(totalSeconds) || 0));
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return [hours, minutes, secs].map(value => String(value).padStart(2, '0')).join(':');
}

function stopCooldownTimer() {
    if (cooldownTimer) {
        clearInterval(cooldownTimer);
        cooldownTimer = null;
    }
}

function startCooldownTimer() {
    stopCooldownTimer();
    if (state.view !== 'missions' || getCooldownRemaining() <= 0) return;

    cooldownTimer = setInterval(() => {
        if (state.view !== 'missions') {
            stopCooldownTimer();
            return;
        }

        const remaining = getCooldownRemaining();
        document.querySelectorAll('.start-mission').forEach(button => {
            if (remaining > 0) {
                button.disabled = true;
                button.textContent = `Cooldown · ${formatCountdown(remaining)}`;
            } else {
                button.disabled = Boolean(state.data?.activeMission || !state.data?.hasGear);
                button.textContent = 'Start mission';
            }
        });

        const cooldownBox = document.getElementById('mission-cooldown-box');
        if (cooldownBox) {
            if (remaining > 0) {
                cooldownBox.classList.remove('hidden');
                cooldownBox.querySelector('strong').textContent = formatCountdown(remaining);
            } else {
                cooldownBox.classList.add('hidden');
                state.data.missionCooldown.expiresAt = 0;
                stopCooldownTimer();
            }
        }
    }, 1000);
}

function setView(view) {
    state.view = view;
    tabs.forEach(tab => tab.classList.toggle('active', tab.dataset.view === view));
    render();
}

function renderHero(title, text, status = '') {
    return `<div class="hero"><div><h2>${escapeHtml(title)}</h2><p>${escapeHtml(text)}</p></div>${status ? `<span class="status-pill ${status.includes('klar') ? 'ready' : ''}">${escapeHtml(status)}</span>` : ''}</div>`;
}

function renderShop() {
    const d = state.data;
    const cards = d.shop.items.map(item => `
        <article class="card">
            <div class="card-top"><div class="card-icon">🤿</div></div>
            <div class="card-body">
                <h3>${escapeHtml(item.label)}</h3>
                <p>${escapeHtml(item.description)}</p>
                <div class="price">${money(item.price)} kr.</div>
                <button class="primary buy" data-item="${escapeHtml(item.name)}" ${d.hasGear ? 'disabled' : ''}>${d.hasGear ? 'Allerede købt' : 'Køb udstyr'}</button>
                <button class="secondary toggle-gear" ${!d.hasGear ? 'disabled' : ''}>Aktivér / deaktivér udstyr</button>
            </div>
        </article>`).join('');

    content.innerHTML = renderHero('Dykkerbutik', 'Køb udstyr, før du tager ud på mission.', d.hasGear ? 'Udstyr klar' : 'Udstyr mangler') + `<div class="grid">${cards}</div>`;

    content.querySelectorAll('.buy').forEach(btn => btn.onclick = async () => {
        btn.disabled = true;
        const result = await post('buyItem', { item: btn.dataset.item });
        if (result.success) {
            state.data.hasGear = true;
            renderShop();
        } else btn.disabled = false;
    });
    content.querySelectorAll('.toggle-gear').forEach(btn => btn.onclick = () => post('toggleGear'));
}

function renderMissions() {
    const d = state.data;
    const cooldownRemaining = getCooldownRemaining();
    let active = '';
    if (d.activeMission) {
        active = `<div class="mission-active"><div><strong>Aktiv mission: ${escapeHtml(d.activeMission.label)}</strong><small>${d.activeMission.completed}/${d.activeMission.required} fundsteder undersøgt</small></div><button class="danger cancel-mission">Annullér mission</button></div>`;
    }

    const cooldownBox = `
        <div id="mission-cooldown-box" class="mission-cooldown ${cooldownRemaining > 0 ? '' : 'hidden'}">
            <div>
                <span>Ny mission tilgængelig om</span>
                <strong>${formatCountdown(cooldownRemaining)}</strong>
            </div>
            <small>Cooldownen starter, når en mission er gennemført.</small>
        </div>`;

    const cards = d.missions.map(mission => {
        const unavailable = Boolean(d.activeMission || !d.hasGear || cooldownRemaining > 0);
        const buttonText = cooldownRemaining > 0
            ? `Cooldown · ${formatCountdown(cooldownRemaining)}`
            : 'Start mission';

        return `
        <article class="card">
            <div class="card-top"><div class="card-icon">🌊</div></div>
            <div class="card-body">
                <h3>${escapeHtml(mission.label)}</h3>
                <p>${escapeHtml(mission.description)}</p>
                <div class="meta"><span>${escapeHtml(mission.difficulty)}</span><span>${mission.duration} min.</span><span>${mission.requiredSearches} fund</span></div>
                <div class="price">Bonus: ${money(mission.rewardBonus)} kr.</div>
                <button class="primary start-mission" data-id="${escapeHtml(mission.id)}" ${unavailable ? 'disabled' : ''}>${buttonText}</button>
                <div class="meta"><span>Depositum: ${money(mission.deposit)} kr.</span></div>
            </div>
        </article>`;
    }).join('');

    content.innerHTML = renderHero('Dykkermissioner', 'Vælg en opgave og bjærg fund fra havbunden.', d.hasGear ? 'Udstyr klar' : 'Udstyr mangler') + cooldownBox + active + `<div class="grid">${cards}</div>`;

    content.querySelectorAll('.start-mission').forEach(btn => btn.onclick = async () => {
        if (getCooldownRemaining() > 0) return;
        btn.disabled = true;
        await post('startMission', { missionId: btn.dataset.id });
    });
    const cancel = content.querySelector('.cancel-mission');
    if (cancel) cancel.onclick = () => post('cancelMission');

    startCooldownTimer();
}

function renderSell() {
    const finds = state.data.finds;
    const owned = finds.filter(item => item.count > 0);
    const rows = owned.map(item => `
        <div class="sell-row">
            <div class="sell-name"><strong>${escapeHtml(item.label)}</strong><span>${item.count} stk. · ${money(item.price)} kr. pr. stk.</span></div>
            <input type="number" min="1" max="${item.count}" value="${item.count}" data-input="${escapeHtml(item.name)}">
            <strong>${money(item.count * item.price)} kr.</strong>
            <button class="primary sell-one" data-item="${escapeHtml(item.name)}">Sælg</button>
        </div>`).join('');

    content.innerHTML = renderHero('Sælg dykkerfund', 'Sælg de genstande, du har bjærget under vandet.', `${owned.reduce((a,b) => a + b.count, 0)} fund`) + (rows ? `<div class="sell-list">${rows}</div><div class="sell-total"><button class="primary sell-all">Sælg alle fund</button></div>` : '<div class="empty">Du har ingen dykkerfund at sælge.</div>');

    content.querySelectorAll('.sell-one').forEach(btn => btn.onclick = async () => {
        const input = content.querySelector(`[data-input="${btn.dataset.item}"]`);
        const result = await post('sellItem', { item: btn.dataset.item, amount: Number(input.value) });
        if (result.success && result.data) { state.data = result.data; renderSell(); }
    });
    const all = content.querySelector('.sell-all');
    if (all) all.onclick = async () => {
        const result = await post('sellAll');
        if (result.success && result.data) { state.data = result.data; renderSell(); }
    };
}

function render() {
    if (!state.data) return;
    if (state.view !== 'missions') stopCooldownTimer();
    if (state.view === 'shop') renderShop();
    else if (state.view === 'missions') renderMissions();
    else renderSell();
}

tabs.forEach(tab => tab.onclick = () => setView(tab.dataset.view));
closeButton.onclick = () => post('close');
window.addEventListener('keydown', event => { if (event.key === 'Escape') post('close'); });


function updateMissionHud(message) {
    const visible = Boolean(message.visible);
    missionHud.classList.toggle('hidden', !visible);

    if (!visible) return;

    const completed = Math.max(0, Number(message.completed || 0));
    const required = Math.max(0, Number(message.required || 0));
    const remaining = Math.max(0, required - completed);
    const percent = required > 0 ? Math.round((completed / required) * 100) : 0;

    missionHudTitle.textContent = message.label || 'Dykkermission';
    missionHudRemaining.textContent = String(remaining);
    missionHudProgressText.textContent = `${completed} / ${required} kister`;
    missionHudPercent.textContent = `${percent}%`;
    missionProgressFill.style.width = `${Math.min(100, Math.max(0, percent))}%`;

    const guide = Array.isArray(message.guide) ? message.guide : [];
    missionGuideList.innerHTML = guide
        .map(step => `<li>${escapeHtml(step)}</li>`)
        .join('');
}

window.addEventListener('message', event => {
    const msg = event.data || {};
    if (msg.action === 'open') {
        state.data = msg.data;
        syncServerClock();
        app.classList.remove('hidden');
        setView(msg.view || 'shop');
    } else if (msg.action === 'close') {
        app.classList.add('hidden');
        stopCooldownTimer();
        state.data = null;
    } else if (msg.action === 'missionProgress') {
        if (state.data?.activeMission) {
            state.data.activeMission.completed = msg.completed;
            state.data.activeMission.required = msg.required;
        }
        updateMissionHud({
            visible: msg.visible !== false,
            label: msg.label,
            completed: msg.completed,
            required: msg.required,
            guide: msg.guide
        });
    } else if (msg.action === 'missionHud') {
        updateMissionHud(msg);
    } else if (msg.action === 'oxygen') {
        oxygenHud.classList.toggle('hidden', !msg.visible);

        if (msg.visible) {
            const remaining = Math.max(0, Number(msg.remaining || 0));
            const minutes = Math.floor(remaining / 60);
            const seconds = Math.floor(remaining % 60);
            oxygenTime.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            oxygenFill.style.width = `${Math.max(0, Math.min(100, Number(msg.percent || 0)))}%`;
            oxygenState.textContent = msg.underwater ? 'I brug under vand' : 'Iltforbrug sat på pause';
        }
    }
});
