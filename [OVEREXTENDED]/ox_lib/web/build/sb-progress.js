
(() => {
  const root = document.createElement('div');
  root.id = 'sb-progress-root';
  document.body.appendChild(root);

  let active = null;

  const postComplete = () => {
    try {
      const request = new XMLHttpRequest();
      request.open('POST', `https://${GetParentResourceName()}/progressComplete`, true);
      request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
      request.send('{}');
    } catch (_) {}
  };

  const clearActive = (sendComplete) => {
    if (!active) return;
    const entry = active;
    active = null;
    cancelAnimationFrame(entry.frame);
    entry.element.classList.add('sb-progress-leaving');
    setTimeout(() => entry.element.remove(), 230);
    if (sendComplete) postComplete();
  };

  const startProgress = (data) => {
    clearActive(false);

    const duration = Math.max(100, Number(data?.duration) || 1000);
    const wrap = document.createElement('div');
    wrap.className = 'sb-progress-wrap';
    if (data?.position === 'middle') wrap.classList.add('sb-progress-middle');

    const card = document.createElement('div');
    card.className = 'sb-progress-card';

    const head = document.createElement('div');
    head.className = 'sb-progress-head';

    const label = document.createElement('div');
    label.className = 'sb-progress-label';
    label.textContent = data?.label ? String(data.label) : 'Arbejder...';

    const percent = document.createElement('div');
    percent.className = 'sb-progress-percent';
    percent.textContent = '0%';

    const track = document.createElement('div');
    track.className = 'sb-progress-track';

    const fill = document.createElement('div');
    fill.className = 'sb-progress-fill';

    const shine = document.createElement('div');
    shine.className = 'sb-progress-shine';

    fill.appendChild(shine);
    track.appendChild(fill);
    head.append(label, percent);
    card.append(head, track);

    if (data?.canCancel) {
      const hint = document.createElement('div');
      hint.className = 'sb-progress-hint';
      hint.textContent = 'Tryk X for at annullere';
      card.appendChild(hint);
    }

    wrap.appendChild(card);
    root.appendChild(wrap);

    const start = performance.now();
    const entry = { element: wrap, frame: 0 };
    active = entry;

    const tick = (now) => {
      if (active !== entry) return;
      const elapsed = now - start;
      const value = Math.min(1, elapsed / duration);
      fill.style.width = `${value * 100}%`;
      percent.textContent = `${Math.floor(value * 100)}%`;

      if (value >= 1) {
        percent.textContent = '100%';
        clearActive(true);
        return;
      }

      entry.frame = requestAnimationFrame(tick);
    };

    entry.frame = requestAnimationFrame(tick);
  };

  window.addEventListener('message', (event) => {
    const message = event.data;
    if (message?.action === 'sbProgress') startProgress(message.data || {});
    if (message?.action === 'sbProgressCancel') clearActive(false);
  });
})();
