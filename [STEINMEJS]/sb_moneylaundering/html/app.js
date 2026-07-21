const app = document.getElementById('app');
const amountInput = document.getElementById('amount');
const errorElement = document.getElementById('error');
const launderButton = document.getElementById('launder');

let state = {
  blackMoney: 0,
  feePercent: 40,
  minimumAmount: 500,
  maximumAmount: 250000
};

const post = (name, data = {}) => fetch(`https://${GetParentResourceName()}/${name}`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(data)
}).then(response => response.json());

const formatMoney = value => `${new Intl.NumberFormat('da-DK').format(Math.floor(value || 0))} kr.`;
const cleanAmount = value => Math.max(0, Math.floor(Number(String(value).replace(/\D/g, '')) || 0));

function calculate(amount) {
  const fee = Math.floor(amount * (state.feePercent / 100));
  return { fee, payout: Math.max(0, amount - fee) };
}

function setError(message) {
  errorElement.textContent = message || '';
  errorElement.classList.toggle('hidden', !message);
}

function updateSummary() {
  const amount = cleanAmount(amountInput.value);
  const { fee, payout } = calculate(amount);

  document.getElementById('summary-amount').textContent = formatMoney(amount);
  document.getElementById('summary-fee').textContent = formatMoney(fee);
  document.getElementById('summary-payout').textContent = formatMoney(payout);
  setError('');
}

function setAmount(amount) {
  amountInput.value = amount > 0 ? new Intl.NumberFormat('da-DK').format(amount) : '';
  updateSummary();
}

function close() {
  app.classList.add('hidden');
  setError('');
  post('close');
}

window.addEventListener('message', event => {
  const { action, data } = event.data;

  if (action === 'open') {
    state = { ...state, ...data };
    document.getElementById('black-money').textContent = `${data.blackMoneyFormatted} kr.`;
    document.getElementById('fee-label').textContent = `${data.feePercent}% gebyr`;
    setAmount(0);
    app.classList.remove('hidden');
  }

  if (action === 'hideForTrade') {
    app.classList.add('hidden');
    setError('');
  }

  if (action === 'transactionSuccess') {
    state.blackMoney = data.remainingBlackMoney;
    document.getElementById('black-money').textContent = `${data.remainingBlackMoneyFormatted} kr.`;
    setAmount(0);
  }

  if (action === 'close') close();
});

amountInput.addEventListener('input', () => {
  const amount = cleanAmount(amountInput.value);
  amountInput.value = amount > 0 ? new Intl.NumberFormat('da-DK').format(amount) : '';
  updateSummary();
});

document.querySelectorAll('.quick-buttons button').forEach(button => {
  button.addEventListener('click', () => {
    const percent = Number(button.dataset.percent) || 0;
    const maximumAllowed = Math.min(state.blackMoney, state.maximumAmount);
    setAmount(Math.floor(maximumAllowed * (percent / 100)));
  });
});

document.getElementById('close').addEventListener('click', close);

launderButton.addEventListener('click', async () => {
  const amount = cleanAmount(amountInput.value);

  if (amount < state.minimumAmount) {
    setError(`Minimum er ${formatMoney(state.minimumAmount)}.`);
    return;
  }

  if (amount > state.maximumAmount) {
    setError(`Maksimum er ${formatMoney(state.maximumAmount)} pr. handel.`);
    return;
  }

  if (amount > state.blackMoney) {
    setError('Du har ikke nok sorte penge.');
    return;
  }

  launderButton.disabled = true;
  app.classList.add('hidden');
  setError('');
  const result = await post('launder', { amount }).catch(() => ({ success: false, message: 'Handlen kunne ikke gennemføres.' }));
  launderButton.disabled = false;

  if (!result.success) console.warn(result.message || 'Handlen kunne ikke gennemføres.');
});

document.addEventListener('keyup', event => {
  if (event.key === 'Escape') close();
});
