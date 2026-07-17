(() => {
  const root = document.createElement('div');
  root.id = 'sb-notify-root';
  document.body.appendChild(root);

  const stacks = new Map();
  const active = new Map();
  const icons = {
    success: '✓',
    error: '×',
    warning: '!',
    info: 'i',
    inform: 'i'
  };

  const normalizePosition = (position) => {
    const valid = ['top', 'top-right', 'top-left', 'bottom', 'bottom-right', 'bottom-left', 'center-right', 'center-left'];
    return valid.includes(position) ? position : 'top-right';
  };

  const getStack = (position) => {
    const normalized = normalizePosition(position);
    if (stacks.has(normalized)) return stacks.get(normalized);
    const stack = document.createElement('div');
    stack.className = `sb-notify-stack sb-pos-${normalized}`;
    root.appendChild(stack);
    stacks.set(normalized, stack);
    return stack;
  };

  const removeNotify = (entry) => {
    if (!entry || entry.removing) return;
    entry.removing = true;
    clearTimeout(entry.timer);
    entry.element.classList.add('sb-leaving');
    setTimeout(() => {
      entry.element.remove();
      if (entry.id) active.delete(entry.id);
    }, 270);
  };

  const createNotify = (data) => {
    if (!data || (!data.title && !data.description)) return;

    const id = data.id != null ? String(data.id) : null;
    if (id && active.has(id)) removeNotify(active.get(id));

    const type = ['success', 'error', 'warning', 'info', 'inform'].includes(data.type) ? data.type : 'info';
    const duration = Math.max(500, Number(data.duration) || 3000);
    const element = document.createElement('div');
    element.className = `sb-notify sb-type-${type}`;
    element.style.setProperty('--duration', `${duration}ms`);

    const icon = document.createElement('div');
    icon.className = 'sb-notify-icon';
    icon.textContent = icons[type];

    const content = document.createElement('div');
    content.className = 'sb-notify-content';

    if (data.title) {
      const title = document.createElement('div');
      title.className = 'sb-notify-title';
      title.textContent = String(data.title);
      content.appendChild(title);
    }

    if (data.description) {
      const description = document.createElement('div');
      description.className = 'sb-notify-description';
      description.textContent = String(data.description);
      content.appendChild(description);
    }

    element.append(icon, content);

    if (data.showDuration !== false) {
      const progress = document.createElement('div');
      progress.className = 'sb-notify-progress';
      element.appendChild(progress);
    }

    if (data.iconColor) element.style.setProperty('--accent', String(data.iconColor));
    if (data.style && typeof data.style === 'object') Object.assign(element.style, data.style);

    const entry = { id, element, removing: false, timer: null };
    getStack(data.position).appendChild(element);
    entry.timer = setTimeout(() => removeNotify(entry), duration);
    if (id) active.set(id, entry);
  };

  window.addEventListener('message', (event) => {
    const message = event.data;
    if (message?.action === 'sbNotify') createNotify(message.data);
  });
})();
