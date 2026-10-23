// Cart drawer, product options sheet, add-to-cart buttons, checkout and the live menu on the page.
import { waLink } from '../lib/menu';
import * as store from '../lib/store';
import { OrderError, placeOrder, shopWhatsApp } from '../lib/order';

type View = 'cart' | 'checkout' | 'done';

const $ = <T extends Element = HTMLElement>(sel: string, root: ParentNode = document) => root.querySelector<T>(sel)!;
const $$ = <T extends Element = HTMLElement>(sel: string, root: ParentNode = document) => [...root.querySelectorAll<T>(sel)];
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);
const lenis = () => (window as any).__lenis as { stop(): void; start(): void } | undefined;

let checked = false;

const PAUSED: Record<string, string> = {
  paused: 'Online ordering is paused right now. Visit us in store, we’d love to see you.',
  away: 'We’re not taking online orders at the moment. The shop may be closed, so please try again during opening hours.',
  unknown: 'We couldn’t reach the shop’s ordering system. Check your connection and try again in a moment.',
};

export function initCart() {
  const dialog = $<HTMLDialogElement>('[data-cart]');
  const sheet = $<HTMLDialogElement>('[data-sheet]');
  if (!dialog) return;

  const linesEl = $('[data-lines]', dialog);
  const emptyEl = $('[data-empty]', dialog);
  const pausedEl = $('[data-paused]', dialog);
  const nextBtn = $<HTMLButtonElement>('[data-next]', dialog);
  const backBtn = $<HTMLButtonElement>('[data-cart-back]', dialog);
  const titleEl = $('[data-cart-title]', dialog);
  const foot = $('[data-foot]', dialog);
  const form = $<HTMLFormElement>('[data-checkout]', dialog);
  const errorEl = $('[data-error]', dialog);
  const summaryEl = $('[data-summary]', dialog);
  let view: View = 'cart';
  let busy = false;

  // ───────────── Drawer ─────────────

  const open = () => {
    if (!dialog.open) dialog.showModal();
    requestAnimationFrame(() => dialog.classList.add('is-open'));
    lenis()?.stop();
    store.refreshLive(true).then(() => (checked = true, render()));
  };
  const close = () => {
    dialog.classList.remove('is-open');
    lenis()?.start();
    setTimeout(() => {
      if (!dialog.classList.contains('is-open')) {
        dialog.close();
        if (view === 'done') setView('cart');
      }
    }, 450);
  };
  dialog.addEventListener('cancel', (e) => (e.preventDefault(), close()));
  dialog.addEventListener('click', (e) => {
    const t = e.target as HTMLElement;
    if (t === dialog || t.closest('[data-close-cart]')) close();
  });
  $$('[data-open-cart]').forEach((b) => b.addEventListener('click', open));
  backBtn.addEventListener('click', () => setView('cart'));

  const setView = (v: View) => {
    view = v;
    $$('[data-view]', dialog).forEach((s) => (s.hidden = s.dataset.view !== v));
    backBtn.hidden = v !== 'checkout';
    titleEl.textContent = v === 'checkout' ? 'Almost there' : v === 'done' ? 'Thank you!' : 'Your order';
    foot.hidden = v === 'done';
    errorEl.hidden = true;
    if (v === 'checkout') setTimeout(() => $<HTMLInputElement>('input[name=phone]', form).focus(), 350);
    if (v === 'done') requestAnimationFrame(() => $('.done', dialog).classList.add('is-in'));
    render();
  };

  // ───────────── Rendering ─────────────

  const render = () => {
    const lines = store.lines();
    emptyEl.hidden = lines.length > 0;
    linesEl.innerHTML = lines
      .map((l) => {
        const p = store.products.get(l.productId)!;
        const meta = store.describe(l);
        return `<li data-key="${l.key}">
          ${p.thumb ? `<img class="line__img" src="${p.thumb}" alt="" width="64" height="72" loading="lazy">` : '<span class="line__img"></span>'}
          <div><a class="line__name" href="${p.url}">${esc(p.name)}</a>${meta ? `<div class="line__meta">${esc(meta)}</div>` : ''}${
            p.available ? '' : '<div class="line__meta" style="color:var(--danger)">Sold out today</div>'
          }</div>
          <div class="line__right">
            <div class="qty"><button type="button" data-line-step="-1" aria-label="One less ${esc(p.name)}">−</button><output>${l.qty}</output><button type="button" data-line-step="1" aria-label="One more ${esc(p.name)}">+</button></div>
          </div>
        </li>`;
      })
      .join('');

    const s = store.status;
    const soldOut = lines.some((l) => !store.products.get(l.productId)?.available);
    pausedEl.hidden = s.open || !checked || view === 'done';
    pausedEl.textContent = PAUSED[s.reason ?? 'unknown'] ?? PAUSED.unknown;
    if (view === 'cart') {
      nextBtn.textContent = !checked ? 'Checking availability…' : 'Continue to pickup details';
      nextBtn.disabled = !lines.length || !s.open || soldOut;
      if (soldOut && s.open) {
        pausedEl.hidden = false;
        pausedEl.textContent = 'Something in your order just sold out. Remove it to continue.';
      }
    } else if (view === 'checkout') {
      nextBtn.textContent = busy ? 'Placing your order…' : 'Place pickup order';
      nextBtn.disabled = busy || !lines.length || !s.open;
      summaryEl.innerHTML = lines.map((l) => `<li><span>${l.qty}× ${esc(store.products.get(l.productId)!.name)}</span><span>${esc(store.describe(l))}</span></li>`).join('');
    }
    if (view === 'checkout' && !lines.length) setView('cart');
  };

  linesEl.addEventListener('click', (e) => {
    const b = (e.target as HTMLElement).closest<HTMLElement>('[data-line-step]');
    if (!b) return;
    const key = b.closest<HTMLElement>('[data-key]')!.dataset.key!;
    const line = store.lines().find((l) => l.key === key);
    if (line) store.setQty(key, line.qty + Number(b.dataset.lineStep));
  });

  // ───────────── Checkout ─────────────

  const phoneInput = $<HTMLInputElement>('input[name=phone]', form);
  phoneInput.addEventListener('input', () => {
    phoneInput.value = phoneInput.value.replace(/[^\d+\- ]/g, '');
    phoneInput.removeAttribute('aria-invalid');
    errorEl.hidden = true;
  });

  const submit = async () => {
    if (busy) return;
    const fd = new FormData(form);
    errorEl.hidden = true;
    // Bots fill the hidden field: pretend it worked, send nothing.
    if (String(fd.get('company') || '')) return showDone('THANK', String(fd.get('phone')));
    busy = true;
    render();
    try {
      const items = store.lines().map((l) => ({ name: store.products.get(l.productId)!.name, qty: l.qty }));
      const placed = await placeOrder({ phone: String(fd.get('phone') || ''), name: String(fd.get('name') || ''), note: String(fd.get('note') || ''), items });
      form.reset();
      showDone(placed.code, placed.phone, placed.name);
    } catch (e) {
      errorEl.textContent = e instanceof OrderError ? e.message : 'Something went wrong. Please try again.';
      errorEl.hidden = false;
      if (e instanceof OrderError && /mobile number/.test(e.message)) phoneInput.setAttribute('aria-invalid', 'true');
      store.refreshLive(true);
    } finally {
      busy = false;
      render();
    }
  };
  form.addEventListener('submit', (e) => (e.preventDefault(), submit()));

  nextBtn.addEventListener('click', () => (view === 'cart' ? setView('checkout') : submit()));

  const showDone = (code: string, phone: string, name = '') => {
    $('[data-done-code]', dialog).textContent = `#${code}`;
    $('[data-done-phone]', dialog).textContent = phone;
    const wa = $<HTMLAnchorElement>('[data-done-wa]', dialog);
    const link = shopWhatsApp(store.status.whatsapp, `Hi Essence! I just placed pickup order #${code}${name ? ` (${name})` : ''}.`);
    wa.hidden = !link;
    wa.href = link || '#';
    setView('done');
  };

  // ───────────── Add to cart ─────────────

  document.addEventListener('click', (e) => {
    const btn = (e.target as HTMLElement).closest<HTMLButtonElement>('[data-add]');
    if (!btn || btn.disabled) return;
    const id = btn.dataset.add!;
    if (btn.hasAttribute('data-options')) return openSheet(id, btn);
    const qtyEl = btn.hasAttribute('data-with-qty') ? btn.parentElement?.querySelector('[data-qty] output') : null;
    const qty = Number(qtyEl?.textContent || 1);
    store.add(id, { qty });
    if (qtyEl) qtyEl.textContent = '1';
    added(btn, id);
  });

  // Qty steppers next to "Add" (item page) and in the sheet.
  document.addEventListener('click', (e) => {
    const b = (e.target as HTMLElement).closest<HTMLElement>('[data-step]');
    if (!b) return;
    const out = b.parentElement!.querySelector('output')!;
    out.textContent = String(Math.max(1, Math.min(20, Number(out.textContent) + Number(b.dataset.step))));
    out.dispatchEvent(new Event('change', { bubbles: true }));
  });

  const added = (btn: HTMLElement, id: string) => {
    flyToCart(btn, id);
    btn.classList.add('is-added');
    const label = btn.querySelector('span');
    const old = label?.textContent;
    if (label) label.textContent = 'Added';
    setTimeout(() => {
      btn.classList.remove('is-added');
      if (label && old) label.textContent = old;
    }, 1400);
    toast(`${store.products.get(id)?.name ?? 'Item'} added to your order`, open);
  };

  // ───────────── Options sheet ─────────────

  const openSheet = (id: string, from: HTMLElement) => {
    const p = store.products.get(id);
    if (!p || !sheet) return;
    const img = $<HTMLImageElement>('[data-sheet-img]', sheet);
    img.src = p.thumb;
    img.hidden = !p.thumb;
    $('[data-sheet-title]', sheet).textContent = p.name;
    $('[data-sheet-desc]', sheet).textContent = p.description;
    const groups = p.modifierGroupIds.map((g) => store.groups.get(g)).filter(Boolean) as NonNullable<ReturnType<typeof store.groups.get>>[];
    const defSize = p.sizes.find((s) => s.delta === 0) ?? p.sizes[0];
    $('[data-sheet-groups]', sheet).innerHTML = [
      p.sizes.length > 1
        ? `<fieldset><legend>Size</legend>${p.sizes
            .map((s) => `<label><input type="radio" name="size" value="${s.code}" ${s === defSize ? 'checked' : ''}><span>${esc(s.label)}</span></label>`)
            .join('')}</fieldset>`
        : '',
      ...groups.map(
        (g) =>
          `<fieldset data-group="${g.id}" data-min="${g.minSelect}" data-max="${g.maxSelect}"><legend>${esc(g.name)}${g.minSelect ? '' : ' <small>(optional)</small>'}</legend>${g.options
            .map((o) => `<label><input type="${g.maxSelect === 1 ? 'radio' : 'checkbox'}" name="g-${g.id}" value="${o.id}"><span>${esc(o.name)}</span></label>`)
            .join('')}</fieldset>`,
      ),
    ].join('');
    $('[data-sheet-qty] output', sheet).textContent = '1';

    const read = () => {
      const fd = new FormData($<HTMLFormElement>('[data-sheet-form]', sheet));
      const sizeCode = (fd.get('size') as string) || defSize?.code;
      const optionIds = groups.flatMap((g) => fd.getAll(`g-${g.id}`) as string[]);
      const qty = Number($('[data-sheet-qty] output', sheet).textContent);
      return { sizeCode, optionIds, qty };
    };
    const update = () => {
      // Respect each group's maximum.
      $$<HTMLFieldSetElement>('fieldset[data-group]', sheet).forEach((fs) => {
        const max = Number(fs.dataset.max) || 99;
        const boxes = $$<HTMLInputElement>('input[type=checkbox]', fs);
        const n = boxes.filter((b) => b.checked).length;
        boxes.forEach((b) => (b.disabled = !b.checked && n >= max));
      });
      const r = read();
      const missing = groups.some((g) => g.minSelect > 0 && !r.optionIds.some((o) => g.options.some((x) => x.id === o)));
      $<HTMLButtonElement>('[data-sheet-add]', sheet).disabled = missing;
    };
    sheet.oninput = update;
    sheet.onchange = update;
    sheet.onclick = (e) => (e.target as HTMLElement).closest('[data-step]') && setTimeout(update);
    $<HTMLButtonElement>('[data-sheet-add]', sheet).onclick = () => {
      const r = read();
      store.add(id, r);
      sheet.close();
      added(from, id);
    };
    update();
    sheet.showModal();
  };
  sheet?.addEventListener('close', () => lenis()?.start());
  sheet?.addEventListener('click', (e) => e.target === sheet && sheet.close());

  // ───────────── Live menu on the page ─────────────

  const applyLive = () => {
    for (const el of $$('[data-product]')) {
      const p = store.products.get(el.dataset.product!);
      if (!p) continue;
      el.toggleAttribute('data-sold', !p.available);
      el.querySelectorAll<HTMLButtonElement>(`[data-add="${p.id}"]`).forEach((b) => (b.disabled = !p.available));
    }
    const s = store.status;
    $$('[data-live="address"]').forEach((e) => s.address && (e.textContent = s.address));
    $$('[data-live="hours"]').forEach((e) => {
      e.textContent = s.hours;
      e.hidden = !s.hours;
    });
    $$('[data-live="whatsapp"]').forEach((e) => (e.textContent = s.whatsapp));
    $$('[data-live-row]').forEach((e) => (e.hidden = !(s as any)[e.dataset.liveRow!]));
    $$<HTMLAnchorElement>('[data-live="whatsapp-link"]').forEach((a) => {
      const link = shopWhatsApp(s.whatsapp, 'Hi Essence!');
      a.hidden = !link;
      if (link) a.href = link;
    });
    // "Ask on WhatsApp" buttons (items, cart): the shop's number comes live from the POS.
    $$<HTMLAnchorElement>('[data-wa]').forEach((a) => {
      const link = waLink(s.whatsapp, a.dataset.wa!);
      a.hidden = !link;
      if (link) a.href = link;
    });
  };

  store.subscribe(() => {
    applyLive();
    render();
  });
  render();
}

// ───────────── Little extras ─────────────

/** A photo flies from the button's card into the cart icon. */
function flyToCart(from: HTMLElement, id: string) {
  const target = document.querySelector('.cart-btn');
  const src = from.closest('[data-product]')?.querySelector('img') ?? null;
  if (!target || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  const thumb = store.products.get(id)?.thumb;
  const a = (src ?? from).getBoundingClientRect();
  const b = target.getBoundingClientRect();
  const ghost = document.createElement(thumb ? 'img' : 'span');
  if (thumb) (ghost as HTMLImageElement).src = thumb;
  const size = Math.min(a.width, 120);
  Object.assign(ghost.style, {
    position: 'fixed',
    left: `${a.left + a.width / 2 - size / 2}px`,
    top: `${a.top + a.height / 2 - size / 2}px`,
    width: `${size}px`,
    height: `${size}px`,
    borderRadius: '999px',
    objectFit: 'cover',
    background: 'var(--coffee)',
    zIndex: '60',
    pointerEvents: 'none',
    boxShadow: '0 20px 40px -10px rgb(0 0 0 / 40%)',
  });
  document.body.appendChild(ghost);
  const dx = b.left + b.width / 2 - (a.left + a.width / 2);
  const dy = b.top + b.height / 2 - (a.top + a.height / 2);
  ghost
    .animate(
      [
        { transform: 'translate(0,0) scale(1)', opacity: 1 },
        { transform: `translate(${dx * 0.5}px, ${dy * 0.5 - 80}px) scale(0.6)`, opacity: 1, offset: 0.55 },
        { transform: `translate(${dx}px, ${dy}px) scale(0.12)`, opacity: 0.3 },
      ],
      { duration: 850, easing: 'cubic-bezier(.5,0,.3,1)' },
    )
    .finished.finally(() => ghost.remove());
}

let toastTimer = 0;
function toast(message: string, onView: () => void) {
  let el = document.querySelector<HTMLElement>('.toast');
  if (!el) {
    el = document.createElement('div');
    el.className = 'toast';
    el.setAttribute('role', 'status');
    el.innerHTML = '<span></span><button type="button">View order</button>';
    document.body.appendChild(el);
    el.querySelector('button')!.addEventListener('click', () => {
      el!.classList.remove('is-in');
      onView();
    });
  }
  el.querySelector('span')!.textContent = message;
  requestAnimationFrame(() => el!.classList.add('is-in'));
  clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => el!.classList.remove('is-in'), 3200);
}
