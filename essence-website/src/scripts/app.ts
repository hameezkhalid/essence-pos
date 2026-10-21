// Every page: nav, cart and live menu; scroll animations load separately (and only when motion is allowed).
import { initNav } from './nav';
import { initCart } from './cart-ui';
import { initTabs } from './tabs';
import { refreshLive } from '../lib/store';

initNav();
initCart();
initTabs();

const idle: (cb: () => void) => void = (window as any).requestIdleCallback ?? ((cb: () => void) => setTimeout(cb, 200));
idle(() => refreshLive());
document.addEventListener('visibilitychange', () => {
  if (!document.hidden) refreshLive();
});

if (document.documentElement.classList.contains('motion')) {
  import('./motion').then((m) => m.initMotion());
}
