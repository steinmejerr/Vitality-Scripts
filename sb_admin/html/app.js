document.documentElement.style.background = 'transparent';
document.body.style.background = 'transparent';

const menu = document.getElementById('admin-menu');
const menuList = document.getElementById('menu-list');
const itemCount = document.getElementById('item-count');

let items = [];
let selectedIndex = 1;

const icons = {
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
            item.disabled ? 'disabled' : ''
        ].filter(Boolean).join(' ');

        element.innerHTML = `
            <div class="item-icon">${icons[item.icon] || icons.shield}</div>
            <div class="item-copy">
                <div class="item-label">${escapeHtml(item.label || '')}</div>
                <div class="item-description">${escapeHtml(item.description || '')}</div>
            </div>
            <div class="item-arrow">${item.disabled ? '•' : '›'}</div>
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
