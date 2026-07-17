const app = document.getElementById('app');
const content = document.getElementById('content');
const profile = document.getElementById('profile');
const missionHud = document.getElementById('mission-hud');
const missionHudTitle = document.getElementById('mission-hud-title');
const missionHudDescription = document.getElementById('mission-hud-description');
const missionHudRequirements = document.getElementById('mission-hud-requirements');

const miningClang = new Audio('sounds/mining_clang.wav');
miningClang.preload = 'auto';

function playMiningClang(volume) {
    const sound = miningClang.cloneNode();
    sound.volume = Math.max(0, Math.min(1, Number(volume ?? 0.18)));
    sound.play().catch(() => {});
}

let state = {
    tab: 'shop',
    data: null
};

const resource = () => typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'sb_mining';

const post = (name, data = {}) => fetch(`https://${resource()}/${name}`, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
}).then(response => response.json());

function money(value) {
    return `${Number(value || 0).toLocaleString('da-DK')} kr.`;
}

function setTab(tab) {
    state.tab = tab;
    document.querySelectorAll('nav button').forEach(button => {
        button.classList.toggle('active', button.dataset.tab === tab);
    });
    render();
}



function renderMissionHud(mission) {
    if (!mission || !Array.isArray(mission.requirements)) {
        missionHud.classList.add('hidden');
        return;
    }

    missionHudTitle.textContent = mission.label || 'Aktiv mission';
    missionHudDescription.textContent = mission.description || '';
    missionHudRequirements.innerHTML = mission.requirements.map(requirement => {
        const current = Math.max(0, Number(requirement.current || 0));
        const required = Math.max(0, Number(requirement.required || 0));
        const remaining = Math.max(0, required - current);
        const percentage = required > 0 ? Math.min(100, (current / required) * 100) : 100;
        const complete = remaining === 0;

        return `
            <div class="mission-requirement ${complete ? 'complete' : ''}">
                <div class="mission-requirement-row">
                    <span>${requirement.label}</span>
                    <strong>${current} / ${required}</strong>
                </div>
                <div class="mission-progress-track">
                    <div class="mission-progress-fill" style="width: ${percentage}%"></div>
                </div>
                <small>${complete ? 'Gennemført' : `${remaining} mangler`}</small>
            </div>
        `;
    }).join('');

    missionHud.classList.remove('hidden');
}

function renderProfile() {
    const player = state.data && state.data.profile
        ? state.data.profile
        : { level: 1, xp: 0, completed_missions: 0 };

    profile.innerHTML = `
        <span><strong>Level:</strong> ${player.level}</span>
        <span><strong>XP:</strong> ${player.xp}</span>
        <span><strong>Missioner:</strong> ${player.completed_missions}</span>
    `;
}

function renderShop() {
    const cards = Object.entries(state.data.pickaxes || {}).map(([key, pickaxe]) => {
        const locked = state.data.profile.level < pickaxe.requiredLevel;
        return `
            <article class="card">
                <h3>${pickaxe.label}</h3>
                <p>Hurtigere minedrift og højere holdbarhed.</p>
                <div class="meta">
                    <span>Level ${pickaxe.requiredLevel}</span>
                    <strong>${money(pickaxe.price)}</strong>
                </div>
                <button class="action" data-buy="${key}" ${locked ? 'disabled' : ''}>
                    ${locked ? 'Låst' : 'Køb hakke'}
                </button>
            </article>
        `;
    }).join('');

    content.innerHTML = `<div class="grid">${cards}</div>`;

    content.querySelectorAll('[data-buy]').forEach(button => {
        button.onclick = async () => {
            await post('buyPickaxe', { key: button.dataset.buy });
        };
    });
}

function renderMissions() {
    const active = state.data.activeMission;
    const activeHtml = active
        ? `<div class="mission-progress"><strong>${active.label}</strong><div>${active.mined} / ${active.rocks} sten</div></div>`
        : '';

    const cards = Object.entries(state.data.missions || {}).map(([key, mission]) => {
        const locked = state.data.profile.level < mission.requiredLevel;
        const disabled = locked || Boolean(active);
        const text = active ? 'Mission aktiv' : locked ? 'Låst' : 'Start mission';

        return `
            <article class="card">
                <h3>${mission.label}</h3>
                <p>${mission.description}</p>
                <div class="meta">
                    <span>Level ${mission.requiredLevel}</span>
                    <span>${mission.rocks} sten</span>
                </div>
                <div class="meta">
                    <span>${mission.multiplayer ? 'Multiplayer' : 'Solo'}</span>
                    <strong>${money(mission.moneyBonus)}</strong>
                </div>
                <input class="member-input" id="members-${key}" placeholder="Server-ID'er, fx 2, 7, 12">
                <button class="action" data-mission="${key}" ${disabled ? 'disabled' : ''}>${text}</button>
            </article>
        `;
    }).join('');

    content.innerHTML = `${activeHtml}<div class="grid">${cards}</div>`;

    content.querySelectorAll('[data-mission]').forEach(button => {
        button.onclick = async () => {
            const input = document.getElementById(`members-${button.dataset.mission}`);
            const raw = input ? input.value : '';
            const members = raw.split(',').map(value => Number(value.trim())).filter(Boolean);
            await post('startMission', {
                key: button.dataset.mission,
                members
            });
        };
    });
}

function renderSell() {
    const rows = Object.entries(state.data.ores || {}).map(([key, ore]) => {
        const amount = Number(state.data.inventory?.[key] || 0);
        return `
            <div class="sell-row">
                <div>
                    <strong>${ore.label}</strong>
                    <p>${amount} stk. · ${money(ore.sellPrice)} grundpris</p>
                </div>
                <input id="sell-${key}" type="number" min="1" max="${amount}" value="${Math.max(amount, 1)}">
                <button class="secondary" data-sell="${key}" ${amount < 1 ? 'disabled' : ''}>Sælg</button>
            </div>
        `;
    }).join('');

    content.innerHTML = `
        <button class="action" id="sell-all">Sælg alt</button>
        <div style="height: 12px"></div>
        ${rows}
    `;

    const sellAll = document.getElementById('sell-all');
    if (sellAll) {
        sellAll.onclick = () => post('sellAll');
    }

    content.querySelectorAll('[data-sell]').forEach(button => {
        button.onclick = () => {
            const input = document.getElementById(`sell-${button.dataset.sell}`);
            const amount = input ? Number(input.value) : 0;
            post('sellOre', {
                key: button.dataset.sell,
                amount
            });
        };
    });
}

function render() {
    if (!state.data) return;
    renderProfile();
    if (state.tab === 'shop') renderShop();
    if (state.tab === 'missions') renderMissions();
    if (state.tab === 'sell') renderSell();
}

window.addEventListener('message', event => {
    const data = event.data || {};

    if (data.action === 'open') {
        if (!data.data || !data.data.profile) return;
        state.data = data.data;
        state.tab = data.tab || 'shop';
        app.classList.remove('hidden');
        setTab(state.tab);
    }

    if (data.action === 'close') {
        app.classList.add('hidden');
    }

    if (data.action === 'playMiningSound') {
        playMiningClang(data.volume);
    }

    if (data.action === 'showMissionHud') {
        renderMissionHud(data.mission);
    }

    if (data.action === 'hideMissionHud') {
        missionHud.classList.add('hidden');
    }

    if (data.action === 'missionProgress' && state.data) {
        state.data.activeMission = data.mission;
        if (state.tab === 'missions') renderMissions();
    }
});

document.getElementById('close').onclick = () => post('close');
document.querySelectorAll('nav button').forEach(button => {
    button.onclick = () => setTab(button.dataset.tab);
});
document.addEventListener('keydown', event => {
    if (event.key === 'Escape') post('close');
});
