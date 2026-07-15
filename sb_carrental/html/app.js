const app = document.getElementById('app');
const list = document.getElementById('vehicle-list');
const title = document.getElementById('location-title');
const count = document.getElementById('vehicle-count');
const message = document.getElementById('message');
const closeButton = document.getElementById('close-button');
const paymentButtons = [...document.querySelectorAll('.payment')];

let vehicles = [];
let currency = 'kr.';
let paymentMethod = 'bank';
let busy = false;

const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'sb_carrental';

function post(endpoint, data = {}) {
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    }).then(response => response.json());
}

function escapeHtml(value) {
    return String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
}

function formatPrice(value) {
    return `${Number(value || 0).toLocaleString('da-DK')} ${currency}`;
}

function showMessage(text) {
    if (!text) {
        message.classList.add('hidden');
        message.textContent = '';
        return;
    }
    message.textContent = text;
    message.classList.remove('hidden');
}

function render() {
    count.textContent = `${vehicles.length} køretøjer`;
    list.innerHTML = vehicles.map(vehicle => `
        <article class="vehicle-card">
            <div class="vehicle-visual">▰</div>
            <span class="vehicle-category">${escapeHtml(vehicle.category || 'Køretøj')}</span>
            <div class="vehicle-name">${escapeHtml(vehicle.label)}</div>
            <div class="vehicle-model">${escapeHtml(vehicle.model)}</div>
            <div class="card-footer">
                <span class="price">${formatPrice(vehicle.price)}</span>
                <button class="rent-button" data-model="${escapeHtml(vehicle.model)}" ${busy ? 'disabled' : ''}>Lej</button>
            </div>
        </article>
    `).join('');

    list.querySelectorAll('.rent-button').forEach(button => {
        button.addEventListener('click', async () => {
            if (busy) return;
            busy = true;
            showMessage('');
            render();
            try {
                const result = await post('rent', { model: button.dataset.model, paymentMethod });
                if (!result?.success) showMessage(result?.message || 'Køretøjet kunne ikke lejes.');
            } catch {
                showMessage('Der opstod en fejl under udlejningen.');
            } finally {
                busy = false;
                render();
            }
        });
    });
}

paymentButtons.forEach(button => {
    button.addEventListener('click', () => {
        paymentMethod = button.dataset.payment;
        paymentButtons.forEach(item => item.classList.toggle('active', item === button));
    });
});

closeButton.addEventListener('click', () => post('close'));
document.addEventListener('keydown', event => {
    if (event.key === 'Escape') post('close');
});

window.addEventListener('message', event => {
    const data = event.data || {};
    if (data.action === 'open') {
        vehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
        currency = data.currency || 'kr.';
        title.textContent = data.label || 'Biludlejning';
        paymentMethod = 'bank';
        paymentButtons.forEach(button => button.classList.toggle('active', button.dataset.payment === paymentMethod));
        showMessage('');
        app.classList.remove('hidden');
        render();
    }
    if (data.action === 'close') {
        app.classList.add('hidden');
    }
});
