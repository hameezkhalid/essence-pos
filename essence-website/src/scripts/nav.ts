import { count, subscribe } from '../lib/store';

export function initNav() {
  const nav = document.querySelector<HTMLElement>('[data-nav]');
  const burger = document.querySelector<HTMLButtonElement>('[data-burger]');
  const menu = document.querySelector<HTMLElement>('[data-mobile-menu]');
  if (!nav) return;

  // Solid background after the top; hide while scrolling down, show on the way up.
  let last = window.scrollY;
  const onScroll = () => {
    const y = window.scrollY;
    nav.classList.toggle('is-scrolled', y > 40);
    if (!document.body.classList.contains('menu-open')) nav.classList.toggle('is-hidden', y > 480 && y > last + 4);
    if (y < last - 4) nav.classList.remove('is-hidden');
    last = y;
  };
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  const setOpen = (open: boolean) => {
    if (!burger || !menu) return;
    burger.setAttribute('aria-expanded', String(open));
    burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    document.body.classList.toggle('menu-open', open);
    if (open) {
      menu.hidden = false;
      requestAnimationFrame(() => menu.classList.add('is-open'));
      (window as any).__lenis?.stop();
    } else {
      menu.classList.remove('is-open');
      setTimeout(() => !menu.classList.contains('is-open') && (menu.hidden = true), 700);
      (window as any).__lenis?.start();
    }
  };
  burger?.addEventListener('click', () => setOpen(burger.getAttribute('aria-expanded') !== 'true'));
  menu?.addEventListener('click', (e) => (e.target as HTMLElement).closest('a') && setOpen(false));
  document.addEventListener('keydown', (e) => e.key === 'Escape' && document.body.classList.contains('menu-open') && setOpen(false));

  // Cart count badge.
  const badges = document.querySelectorAll<HTMLElement>('[data-cart-count]');
  let prev = count();
  const render = () => {
    const n = count();
    badges.forEach((b) => {
      b.textContent = String(n);
      b.hidden = n === 0;
    });
    if (n > prev) {
      const btn = document.querySelector('.cart-btn');
      btn?.classList.remove('bump');
      void (btn as HTMLElement | null)?.offsetWidth;
      btn?.classList.add('bump');
    }
    prev = n;
  };
  subscribe(render);
  render();
}
