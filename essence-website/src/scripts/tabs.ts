// Category tabs on the home menu preview (works with or without animations).
export function initTabs() {
  document.querySelectorAll<HTMLElement>('[data-tabs]').forEach((root) => {
    const tabs = [...root.querySelectorAll<HTMLButtonElement>('[role=tab]')];
    const ink = root.querySelector<HTMLElement>('.tabs__ink');
    const moveInk = (t: HTMLElement) => {
      if (!ink) return;
      ink.style.width = `${t.offsetWidth}px`;
      ink.style.transform = `translateX(${t.offsetLeft}px)`;
    };
    const select = (t: HTMLButtonElement, focus = false) => {
      tabs.forEach((x) => {
        const on = x === t;
        x.setAttribute('aria-selected', String(on));
        x.tabIndex = on ? 0 : -1;
        const panel = document.getElementById(x.getAttribute('aria-controls')!);
        if (panel) panel.hidden = !on;
        if (on && panel) panel.dispatchEvent(new CustomEvent('tab:shown', { bubbles: true }));
      });
      moveInk(t);
      if (focus) t.focus();
    };
    tabs.forEach((t, i) => {
      t.addEventListener('click', () => select(t));
      t.addEventListener('keydown', (e) => {
        const d = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
        if (d) select(tabs[(i + d + tabs.length) % tabs.length], true);
      });
    });
    const current = tabs.find((t) => t.getAttribute('aria-selected') === 'true') ?? tabs[0];
    if (current) {
      moveInk(current);
      document.fonts?.ready.then(() => moveInk(current));
      window.addEventListener('resize', () => moveInk(tabs.find((t) => t.getAttribute('aria-selected') === 'true')!));
    }
  });
}
