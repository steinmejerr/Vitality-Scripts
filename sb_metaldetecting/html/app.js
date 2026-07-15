const app = document.getElementById('app');
const inventoryList = document.getElementById('inventory-list');
let inventory = [];

const post = (name, data = {}) => fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
}).then(r => r.json());

function switchTab(name) {
    document.querySelectorAll('.tab').forEach(el => el.classList.toggle('active', el.dataset.tab === name));
    document.querySelectorAll('.view').forEach(el => el.classList.toggle('active', el.id === name));
}

function renderInventory() {
    const items = inventory.filter(item => item.count > 0);
    if (!items.length) {
        inventoryList.innerHTML = '<div class="empty">Du har ingen fund at sælge.</div>';
        return;
    }

    inventoryList.innerHTML = items.map(item => `
        <div class="item-row">
            <div>
                <div class="item-name">${item.label}</div>
                <div class="item-meta">${item.count} stk. · $${item.price} pr. stk.</div>
            </div>
            <div class="item-value">$${item.count * item.price}</div>
            <button data-sell="${item.key}">Sælg</button>
        </div>
    `).join('');

    document.querySelectorAll('[data-sell]').forEach(button => {
        button.addEventListener('click', async () => {
            const result = await post('sellItem', { item: button.dataset.sell });
            if (result.success) {
                const item = inventory.find(entry => entry.key === button.dataset.sell);
                if (item) item.count = 0;
                renderInventory();
            }
        });
    });
}

window.addEventListener('message', event => {
    const data = event.data || {};
    if (data.action === 'open') {
        app.classList.remove('hidden');
        document.getElementById('detector-label').textContent = data.detector.label;
        document.getElementById('detector-price').textContent = `$${data.detector.price}`;
        const buy = document.getElementById('buy-detector');
        buy.disabled = data.detector.owned;
        buy.textContent = data.detector.owned ? 'Allerede købt' : 'Køb metaldetektor';
        inventory = data.inventory || [];
        renderInventory();
        switchTab(data.defaultTab || 'shop');
    }
    if (data.action === 'close') app.classList.add('hidden');
});

document.getElementById('close').addEventListener('click', () => post('close'));
document.querySelectorAll('.tab').forEach(tab => tab.addEventListener('click', () => switchTab(tab.dataset.tab)));
document.getElementById('buy-detector').addEventListener('click', async event => {
    const result = await post('buyDetector');
    if (result.success) {
        event.currentTarget.disabled = true;
        event.currentTarget.textContent = 'Allerede købt';
    }
});
document.getElementById('sell-all').addEventListener('click', async () => {
    const result = await post('sellAll');
    if (result.success) {
        inventory.forEach(item => item.count = 0);
        renderInventory();
    }
});
document.addEventListener('keydown', event => {
    if (event.key === 'Escape') post('close');
});
