document.documentElement.style.background = 'transparent';
document.body.style.background = 'transparent';

const menu = document.getElementById('admin-menu');
const menuList = document.getElementById('menu-list');
const itemCount = document.getElementById('item-count');
const menuTitle = document.getElementById('menu-title');
const adminView = document.getElementById('admin-view');
const chatView = document.getElementById('chat-view');
const menuTab = document.getElementById('menu-tab');
const chatTab = document.getElementById('chat-tab');
const chatMessages = document.getElementById('chat-messages');
const chatInput = document.getElementById('chat-input');
const chatCounter = document.getElementById('chat-counter');

let items = [];
let selectedIndex = 1;
let windowStart = 1;
let activeTab = 'menu';
let chatItems = [];

// Antallet af menupunkter, der må være synlige på samme tid.
// Punkt 1-7 vises uden scrolling. Når punkt 8 vælges, flyttes vinduet én række.
const MAX_VISIBLE_ITEMS = 7;

const icons = {
    players: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M16 20v-1.5c0-2.2-1.8-4-4-4H7c-2.2 0-4 1.8-4 4V20"></path>
            <circle cx="9.5" cy="7.5" r="3.5"></circle>
            <path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path>
            <path d="M18 14.7c1.8.7 3 2.2 3 3.8V20"></path>
        </svg>
    `,
    announcement: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M4 10v4"></path>
            <path d="M7 9v6l9 4V5L7 9Z"></path>
            <path d="M9 15l1.5 5h3L12 16"></path>
            <path d="M19 8.5a5 5 0 0 1 0 7"></path>
        </svg>
    `,
    noclip: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M4 12h16M12 4v16"></path>
            <path d="m16 8 4 4-4 4M8 8l-4 4 4 4M8 8l4-4 4 4M8 16l4 4 4-4"></path>
        </svg>
    `,
    godmode: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 3 19 6v5c0 4.5-2.8 7.6-7 9.2C7.8 18.6 5 15.5 5 11V6l7-3Z"></path>
            <path d="M12 7v10M8.5 12h7"></path>
        </svg>
    `,
    invisibility: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z"></path>
            <circle cx="12" cy="12" r="3"></circle>
            <path d="M4 4l16 16"></path>
        </svg>
    `,
    playerids: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="12" cy="8" r="3.5"></circle>
            <path d="M5 20c.5-4 3-6 7-6s6.5 2 7 6"></path>
            <path d="M17.5 5.5h3v3M20.5 5.5l-4 4"></path>
        </svg>
    `,
    deletevehicle: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 8h14l1.5 5v5H19v2h-2v-2H7v2H5v-2H3.5v-5L5 8Z"></path>
            <path d="m7 8 1.5-4h7L17 8M6 13h2M16 13h2"></path>
            <path d="M4 4l16 16"></path>
        </svg>
    `,
    repairvehicle: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 8h14l1.5 5v5H19v2h-2v-2H7v2H5v-2H3.5v-5L5 8Z"></path>
            <path d="m7 8 1.5-4h7L17 8M6 13h2M16 13h2"></path>
            <path d="M18.5 3.5 21 6l-5.5 5.5-3-3L18 3l.5.5Z"></path>
        </svg>
    `,
    flipvehicle: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 9h14l1.5 4.5V18H19v2h-2v-2H7v2H5v-2H3.5v-4.5L5 9Z"></path>
            <path d="m7 9 1.5-4h7L17 9M6 14h2M16 14h2"></path>
            <path d="M4 6a8 8 0 0 1 14-2M18 4h-4M18 4v4"></path>
        </svg>
    `,
    spawnvehicle: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 9h14l1.5 4.5V18H19v2h-2v-2H7v2H5v-2H3.5v-4.5L5 9Z"></path>
            <path d="m7 9 1.5-4h7L17 9M6 14h2M16 14h2"></path>
            <path d="M12 11v6M9 14h6"></path>
        </svg>
    `,
    waypoint: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 21s7-5.2 7-12a7 7 0 1 0-14 0c0 6.8 7 12 7 12Z"></path>
            <circle cx="12" cy="9" r="2.5"></circle>
        </svg>
    `,
    coordinates: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="12" cy="12" r="3"></circle>
            <path d="M12 2v4M12 18v4M2 12h4M18 12h4"></path>
            <path d="M5 5l2.5 2.5M16.5 16.5 19 19M19 5l-2.5 2.5M7.5 16.5 5 19"></path>
        </svg>
    `,
    copycoordinates: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <rect x="8" y="8" width="11" height="11" rx="2"></rect>
            <path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"></path>
        </svg>
    `,
    return: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M9 7 4 12l5 5"></path>
            <path d="M4 12h10a6 6 0 0 1 6 6"></path>
        </svg>
    `,
    player: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="12" cy="8" r="4"></circle>
            <path d="M4.5 21c.5-4.1 3.2-6.5 7.5-6.5s7 2.4 7.5 6.5"></path>
        </svg>
    `,
    location: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 21s7-5.2 7-12a7 7 0 1 0-14 0c0 6.8 7 12 7 12Z"></path>
            <circle cx="12" cy="9" r="2.5"></circle>
        </svg>
    `,
    bring: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <circle cx="7" cy="7" r="3"></circle>
            <path d="M2.5 17.5c.4-3.1 2-5 4.5-5 1.3 0 2.4.5 3.2 1.4"></path>
            <path d="M13 8h8M17 4l4 4-4 4"></path>
            <path d="M13 17h8"></path>
        </svg>
    `,
    freeze: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 2v20M4.2 6.5l15.6 9M19.8 6.5l-15.6 9"></path>
            <path d="m12 2 2 2M12 2l-2 2M12 22l2-2M12 22l-2-2"></path>
            <path d="m4.2 6.5 2.7.2M4.2 6.5l1.1-2.5M19.8 17.5l-2.7-.2M19.8 17.5l-1.1 2.5"></path>
            <path d="m19.8 6.5-2.7.2M19.8 6.5 18.7 4M4.2 17.5l2.7-.2M4.2 17.5l1.1 2.5"></path>
        </svg>
    `,
    revive: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 3v18M3 12h18"></path>
            <circle cx="12" cy="12" r="9"></circle>
        </svg>
    `,
    spectate: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z"></path>
            <circle cx="12" cy="12" r="3"></circle>
        </svg>
    `,
    givevehicle: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 9h14l1.5 4.5V18H19v2h-2v-2H7v2H5v-2H3.5v-4.5L5 9Z"></path>
            <path d="m7 9 1.5-4h7L17 9M6 14h2M16 14h2"></path>
            <path d="M18 3v5M15.5 5.5h5"></path>
        </svg>
    `,
    inventory: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 8h14l1 12H4L5 8Z"></path>
            <path d="M8 8V6a4 4 0 0 1 8 0v2"></path>
            <path d="M9 12h6"></path>
        </svg>
    `,
    item: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z"></path>
            <path d="m4 7.5 8 4.5 8-4.5M12 12v9"></path>
        </svg>
    `,
    id: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <rect x="3" y="5" width="18" height="14" rx="2"></rect>
            <path d="M7 9h4M7 13h7M17 9h.01"></path>
        </svg>
    `,
    ping: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M5 12.5a10 10 0 0 1 14 0M8 16a6 6 0 0 1 8 0"></path>
            <circle cx="12" cy="19" r="1"></circle>
        </svg>
    `,
    job: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <rect x="3" y="7" width="18" height="13" rx="2"></rect>
            <path d="M8 7V5h8v2M3 12h18"></path>
        </svg>
    `,
    grade: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="m12 3 2.7 5.5 6.1.9-4.4 4.3 1 6.1-5.4-2.9-5.4 2.9 1-6.1-4.4-4.3 6.1-.9L12 3Z"></path>
        </svg>
    `,
    shield: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M12 3 19 6v5c0 4.5-2.8 7.6-7 9.2C7.8 18.6 5 15.5 5 11V6l7-3Z"></path>
            <path d="m9 12 2 2 4-4"></path>
        </svg>
    `
};

function clampWindowStart() {
    const total = items.length;
    const maxStart = Math.max(1, total - MAX_VISIBLE_ITEMS + 1);
    windowStart = Math.min(Math.max(windowStart, 1), maxStart);
}

function ensureSelectionVisible() {
    if (selectedIndex < windowStart) {
        windowStart = selectedIndex;
    } else if (selectedIndex > windowStart + MAX_VISIBLE_ITEMS - 1) {
        windowStart = selectedIndex - MAX_VISIBLE_ITEMS + 1;
    }

    clampWindowStart();
}

function resetScrollForMenu() {
    windowStart = 1;
    ensureSelectionVisible();
}

function renderItems() {
    menuList.innerHTML = '';

    ensureSelectionVisible();

    const firstArrayIndex = windowStart - 1;
    const visibleItems = items.slice(firstArrayIndex, firstArrayIndex + MAX_VISIBLE_ITEMS);

    visibleItems.forEach((item, visibleIndex) => {
        const element = document.createElement('div');
        const itemIndex = windowStart + visibleIndex;

        element.className = [
            'menu-item',
            itemIndex === selectedIndex ? 'selected' : '',
            item.disabled ? 'disabled' : '',
            item.readonly ? 'readonly' : ''
        ].filter(Boolean).join(' ');

        element.innerHTML = `
            <div class="item-icon">${icons[item.icon] || icons.shield}</div>
            <div class="item-copy">
                <div class="item-label">${escapeHtml(item.label || '')}</div>
                <div class="item-description">${escapeHtml(item.description || '')}</div>
            </div>
            <div class="item-arrow">${item.disabled || item.readonly ? '•' : '›'}</div>
        `;

        menuList.appendChild(element);
    });

    itemCount.textContent = items.length
        ? `${selectedIndex} / ${items.length}`
        : '0 / 0';
}

function escapeHtml(value) {
    return String(value)
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
}


async function copyToClipboard(text) {
    let success = false;

    try {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            await navigator.clipboard.writeText(text);
            success = true;
        }
    } catch (_) {
        success = false;
    }

    if (!success) {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.setAttribute('readonly', '');
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();

        try {
            success = document.execCommand('copy');
        } catch (_) {
            success = false;
        }

        textarea.remove();
    }

    fetch(`https://${GetParentResourceName()}/clipboardResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ success })
    }).catch(() => {});
}


function postNui(endpoint, payload = {}) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(payload)
    }).catch(() => {});
}

function setActiveTab(tab) {
    activeTab = tab === 'chat' ? 'chat' : 'menu';
    const isChat = activeTab === 'chat';

    adminView.classList.toggle('active', !isChat);
    chatView.classList.toggle('active', isChat);
    menuTab.classList.toggle('active', !isChat);
    chatTab.classList.toggle('active', isChat);

    if (isChat) {
        requestAnimationFrame(() => {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        });
    }
}

function formatChatTime(timestamp) {
    const date = new Date(Number(timestamp || 0) * 1000);
    if (Number.isNaN(date.getTime())) return '';

    return date.toLocaleTimeString('da-DK', {
        hour: '2-digit',
        minute: '2-digit'
    });
}

function renderChatMessages() {
    chatMessages.innerHTML = '';

    if (!chatItems.length) {
        chatMessages.innerHTML = '<div class="chat-empty">Der er endnu ingen beskeder.</div>';
        return;
    }

    chatItems.forEach((message) => {
        const element = document.createElement('article');
        element.className = 'chat-message';
        element.innerHTML = `
            <div class="chat-message-header">
                <span class="chat-sender">${escapeHtml(message.senderName || 'Admin')}</span>
                <span class="chat-group">${escapeHtml(message.group || 'admin')}</span>
                <span class="chat-time">${escapeHtml(formatChatTime(message.timestamp))}</span>
            </div>
            <div class="chat-text">${escapeHtml(message.message || '')}</div>
        `;
        chatMessages.appendChild(element);
    });

    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function setChatMessages(messages) {
    chatItems = Array.isArray(messages) ? messages : [];
    renderChatMessages();
}

function addChatMessage(message) {
    if (!message || typeof message !== 'object') return;

    chatItems.push(message);
    if (chatItems.length > 75) chatItems.shift();
    renderChatMessages();
}

function focusChatInput() {
    chatInput.disabled = false;
    chatInput.placeholder = 'Skriv en besked...';
    chatInput.focus();
    chatInput.select();
}

function releaseChatInput(clearInput = false) {
    if (clearInput) chatInput.value = '';
    chatInput.blur();
    chatInput.placeholder = 'Tryk Enter for at skrive...';
    chatCounter.textContent = `${chatInput.value.length} / ${chatInput.maxLength}`;
}

chatInput.addEventListener('input', () => {
    chatCounter.textContent = `${chatInput.value.length} / ${chatInput.maxLength}`;
});

chatInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        event.preventDefault();
        const message = chatInput.value.trim();

        if (!message) return;

        postNui('adminChatSubmit', { message });
        releaseChatInput(true);
    } else if (event.key === 'Escape') {
        event.preventDefault();
        postNui('adminChatCancel');
        releaseChatInput(false);
    } else if (event.key === 'Tab') {
        event.preventDefault();
        postNui('adminChatSwitchTab');
        releaseChatInput(false);
    }
});

window.addEventListener('message', (event) => {
    const data = event.data || {};

    switch (data.action) {
        case 'setMenu':
            items = Array.isArray(data.items) ? data.items : [];
            menuTitle.textContent = data.title || 'Adminmenu';
            selectedIndex = Number(data.selectedIndex) || 1;
            resetScrollForMenu();
            renderItems();

            if (Array.isArray(data.chatMessages)) {
                setChatMessages(data.chatMessages);
            }
            setActiveTab(data.activeTab || activeTab);

            menu.classList.toggle('visible', Boolean(data.visible));
            menu.setAttribute('aria-hidden', String(!data.visible));
            break;

        case 'select':
            selectedIndex = Number(data.selectedIndex) || 1;
            renderItems();
            break;

        case 'setActiveTab':
            setActiveTab(data.tab);
            break;

        case 'setChatMessages':
            setChatMessages(data.messages);
            break;

        case 'addChatMessage':
            addChatMessage(data.message);
            break;

        case 'focusChatInput':
            focusChatInput();
            break;

        case 'copyToClipboard':
            copyToClipboard(String(data.text || ''));
            break;

        case 'close':
            windowStart = 1;
            releaseChatInput(false);
            setActiveTab('menu');
            menu.classList.remove('visible');
            menu.setAttribute('aria-hidden', 'true');
            break;
    }
});
