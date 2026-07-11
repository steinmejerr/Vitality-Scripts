document.documentElement.style.background = 'transparent';
document.body.style.background = 'transparent';

const menu = document.getElementById('admin-menu');
const menuList = document.getElementById('menu-list');
const itemCount = document.getElementById('item-count');
const menuTitle = document.getElementById('menu-title');

let items = [];
let selectedIndex = 1;

const icons = {
    players: `
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M16 20v-1.5c0-2.2-1.8-4-4-4H7c-2.2 0-4 1.8-4 4V20"></path>
            <circle cx="9.5" cy="7.5" r="3.5"></circle>
            <path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path>
            <path d="M18 14.7c1.8.7 3 2.2 3 3.8V20"></path>
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

function renderItems() {
    menuList.innerHTML = '';

    items.forEach((item, index) => {
        const element = document.createElement('div');
        const itemIndex = index + 1;

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

window.addEventListener('message', (event) => {
    const data = event.data || {};

    switch (data.action) {
        case 'setMenu':
            items = Array.isArray(data.items) ? data.items : [];
            menuTitle.textContent = data.title || 'Adminmenu';
            selectedIndex = Number(data.selectedIndex) || 1;
            renderItems();

            menu.classList.toggle('visible', Boolean(data.visible));
            menu.setAttribute('aria-hidden', String(!data.visible));
            break;

        case 'select':
            selectedIndex = Number(data.selectedIndex) || 1;
            renderItems();
            break;

        case 'close':
            menu.classList.remove('visible');
            menu.setAttribute('aria-hidden', 'true');
            break;
    }
});
