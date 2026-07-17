const app = document.getElementById('app');
const list = document.getElementById('vehicle-list');
const title = document.getElementById('location-title');
const count = document.getElementById('vehicle-count');
const message = document.getElementById('message');
const closeButton = document.getElementById('close-button');
const paymentButtons = [...document.querySelectorAll('.payment')];
const durationSwitch = document.getElementById('duration-switch');

const papersModal = document.getElementById('papers-modal');
const papersClose = document.getElementById('papers-close');
const papersBack = document.getElementById('papers-back');
const papersSign = document.getElementById('papers-sign');
const papersStatus = document.getElementById('papers-status');

let vehicles = [];
let durations = [];
let currency = 'kr.';
let paymentMethod = 'bank';
let selectedDurationId = null;
let busy = false;
let pendingRental = null;
let papersReadOnly = false;

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

function getSelectedDuration() {
    return durations.find(duration => duration.id === selectedDurationId) || durations[0] || null;
}

function getRentalPrice(vehicle) {
    const duration = getSelectedDuration();
    return Math.ceil(Number(vehicle.price || 0) * Number(duration?.multiplier || 1));
}

function paymentLabel(method) {
    return method === 'cash' ? 'Kontant' : 'Bank';
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

function setText(id, value) {
    const element = document.getElementById(id);
    if (element) element.textContent = value ?? '—';
}

function openPapers(data, readOnly = false) {
    papersReadOnly = readOnly;
    pendingRental = readOnly ? null : data;

    setText('papers-company', data.company || title.textContent || 'SB Biludlejning');
    setText('papers-vehicle', data.label || data.vehicleLabel || data.model || '—');
    setText('papers-model', data.model || '—');
    setText('papers-plate', data.plate || 'Tildeles ved udlevering');
    setText('papers-duration', data.durationLabel || '—');
    setText('papers-payment', data.paymentLabel || paymentLabel(data.paymentMethod));
    setText('papers-price', formatPrice(data.price));
    setText('papers-start', data.startedAt || 'Ved underskrift');
    setText('papers-expiry', data.expiresAt || 'Beregnes ved udlevering');

    papersStatus.textContent = readOnly ? 'AKTIV LEJEAFTALE' : 'KLAR TIL UNDERSKRIFT';
    papersStatus.classList.toggle('active', readOnly);
    papersSign.classList.toggle('hidden', readOnly);
    papersBack.textContent = readOnly ? 'Luk papirer' : 'Tilbage';
    papersModal.classList.remove('hidden');
}

function closePapers() {
    papersModal.classList.add('hidden');
    pendingRental = null;
    papersReadOnly = false;
}

function renderDurations() {
    durationSwitch.innerHTML = durations.map(duration => `
        <button class="duration-button ${duration.id === selectedDurationId ? 'active' : ''}" data-duration="${escapeHtml(duration.id)}">
            ${escapeHtml(duration.label)}
        </button>
    `).join('');

    durationSwitch.querySelectorAll('.duration-button').forEach(button => {
        button.addEventListener('click', () => {
            selectedDurationId = button.dataset.duration;
            showMessage('');
            renderDurations();
            renderVehicles();
        });
    });
}

function renderVehicles() {
    const selectedDuration = getSelectedDuration();
    count.textContent = `${vehicles.length} køretøjer`;

    list.innerHTML = vehicles.map(vehicle => {
        const image = vehicle.image
            ? `<img src="${escapeHtml(vehicle.image)}" alt="${escapeHtml(vehicle.label)}" onerror="this.parentElement.classList.add('image-error'); this.remove();">`
            : '';

        return `
            <article class="vehicle-card">
                <div class="vehicle-visual">
                    ${image}
                    <span class="image-fallback">Billede mangler</span>
                </div>
                <span class="vehicle-category">${escapeHtml(vehicle.category || 'Køretøj')}</span>
                <div class="vehicle-name">${escapeHtml(vehicle.label)}</div>
                <div class="vehicle-model">${escapeHtml(vehicle.model)}</div>
                <div class="rental-summary">
                    <span>${escapeHtml(selectedDuration?.label || '')}</span>
                    <strong>${formatPrice(getRentalPrice(vehicle))}</strong>
                </div>
                <div class="card-footer">
                    <span class="base-price">Grundpris: ${formatPrice(vehicle.price)} / time</span>
                    <button class="rent-button" data-model="${escapeHtml(vehicle.model)}" ${busy ? 'disabled' : ''}>Se køretøjspapirer</button>
                </div>
            </article>
        `;
    }).join('');

    list.querySelectorAll('.rent-button').forEach(button => {
        button.addEventListener('click', () => {
            if (busy || !selectedDurationId) return;
            const vehicle = vehicles.find(item => item.model === button.dataset.model);
            const duration = getSelectedDuration();
            if (!vehicle || !duration) return;

            openPapers({
                label: vehicle.label,
                model: vehicle.model,
                durationLabel: duration.label,
                paymentMethod,
                paymentLabel: paymentLabel(paymentMethod),
                price: getRentalPrice(vehicle)
            });
        });
    });
}

paymentButtons.forEach(button => {
    button.addEventListener('click', () => {
        paymentMethod = button.dataset.payment;
        paymentButtons.forEach(item => item.classList.toggle('active', item === button));
    });
});

papersSign.addEventListener('click', async () => {
    if (busy || !pendingRental || !selectedDurationId) return;
    busy = true;
    papersSign.disabled = true;
    papersSign.textContent = 'Behandler aftale...';
    showMessage('');

    try {
        const result = await post('rent', {
            model: pendingRental.model,
            paymentMethod,
            durationId: selectedDurationId
        });
        if (!result?.success) {
            showMessage(result?.message || 'Køretøjet kunne ikke lejes.');
            closePapers();
        }
    } catch {
        showMessage('Der opstod en fejl under udlejningen.');
        closePapers();
    } finally {
        busy = false;
        papersSign.disabled = false;
        papersSign.textContent = 'Underskriv lejeaftale';
        renderVehicles();
    }
});

papersClose.addEventListener('click', closePapers);
papersBack.addEventListener('click', closePapers);
closeButton.addEventListener('click', () => post('close'));

document.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
        if (!papersModal.classList.contains('hidden')) closePapers();
        else post('close');
    }
});

window.addEventListener('message', event => {
    const data = event.data || {};
    if (data.action === 'open') {
        vehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
        durations = Array.isArray(data.durations) ? data.durations : [];
        currency = data.currency || 'kr.';
        title.textContent = data.label || 'Biludlejning';
        paymentMethod = 'bank';
        selectedDurationId = durations[0]?.id || null;
        paymentButtons.forEach(button => button.classList.toggle('active', button.dataset.payment === paymentMethod));
        showMessage('');
        closePapers();
        app.classList.remove('hidden');
        renderDurations();
        renderVehicles();
    }
    if (data.action === 'openPapers') {
        currency = data.currency || currency;
        app.classList.remove('hidden');
        openPapers(data.rental || {}, true);
    }
    if (data.action === 'close') {
        closePapers();
        app.classList.add('hidden');
    }
});
