// Corporate & events "Request a Quote": there's no email/admin backend yet, so the enquiry goes to the shop on
// WhatsApp (the brief's fallback). The success message shows only once WhatsApp has actually been opened.
import { status } from '../lib/store';
import { waLink } from '../lib/wa';
import { site } from '../site.config';

const field = (fd: FormData, k: string) => String(fd.get(k) ?? '').trim();

function formatDate(v: string) {
  if (!v) return '';
  const d = new Date(`${v}T00:00:00`);
  return Number.isNaN(d.getTime()) ? v : d.toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'long', year: 'numeric' });
}

/** The brief's pre-filled message, with the customer's answers in place of the blanks. */
export function quoteMessage(fd: FormData) {
  const lines = [
    'Hello ESSENCE, I would like to enquire about a corporate order or event.',
    '',
    `Name: ${field(fd, 'name')}`,
    field(fd, 'company') ? `Company: ${field(fd, 'company')}` : null,
    `Phone/WhatsApp: ${field(fd, 'phone')}`,
    field(fd, 'email') ? `Email: ${field(fd, 'email')}` : null,
    `Event type: ${field(fd, 'type') || '—'}`,
    `Date: ${formatDate(field(fd, 'date')) || '—'}`,
    `Approximate guests/quantity: ${field(fd, 'guests') || '—'}`,
    `Location: ${field(fd, 'location') || '—'}`,
    `Items/services required: ${field(fd, 'items') || '—'}`,
    field(fd, 'details') ? `Details: ${field(fd, 'details')}` : null,
    '',
    'Please let me know availability and the next steps.',
  ];
  return lines.filter((l) => l !== null).join('\n');
}

export function initQuote() {
  const form = document.querySelector<HTMLFormElement>('[data-quote]');
  if (!form) return;
  const error = document.querySelector<HTMLElement>('[data-quote-error]')!;
  const done = document.querySelector<HTMLElement>('[data-quote-done]')!;
  const blocked = document.querySelector<HTMLElement>('[data-quote-blocked]')!;
  const again = document.querySelector<HTMLAnchorElement>('[data-quote-open]')!;
  const blockedOpen = document.querySelector<HTMLAnchorElement>('[data-quote-blocked-open]')!;

  const show = (el: HTMLElement) => {
    form.hidden = true;
    done.hidden = blocked.hidden = true;
    el.hidden = false;
    el.focus({ preventScroll: true });
    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    requestAnimationFrame(() => el.classList.add('is-in'));
  };

  form.addEventListener('input', (e) => {
    (e.target as HTMLElement).removeAttribute('aria-invalid');
    error.hidden = true;
  });

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const fd = new FormData(form);
    const missing: string[] = [];
    const mark = (name: string, bad: boolean, label: string) => {
      const el = form.elements.namedItem(name) as HTMLElement | null;
      el?.toggleAttribute('aria-invalid', bad);
      if (bad) missing.push(label);
    };
    mark('name', !field(fd, 'name'), 'your name');
    mark('phone', field(fd, 'phone').replace(/\D/g, '').length < 10, 'a phone / WhatsApp number');
    mark('type', !field(fd, 'type'), 'the enquiry type');
    const email = field(fd, 'email');
    mark('email', !!email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email), 'a valid email (or leave it empty)');
    if (missing.length) {
      error.textContent = `Please add ${missing.join(', ')}.`;
      error.hidden = false;
      (form.querySelector('[aria-invalid]') as HTMLElement | null)?.focus();
      return;
    }

    const link = waLink(status.whatsapp || site.whatsapp, quoteMessage(fd), '');
    if (!link) {
      error.textContent = 'Our WhatsApp line isn’t available right now. Please try again shortly or visit us in Bahria Town Phase 8.';
      error.hidden = false;
      return;
    }
    again.href = blockedOpen.href = link;
    // Opening in the same click keeps pop-up blockers happy; if it's still blocked, offer a tap-to-send button.
    const w = window.open(link, '_blank');
    if (w) {
      w.opener = null;
      show(done);
    } else {
      show(blocked);
    }
  });

  blockedOpen.addEventListener('click', () => setTimeout(() => show(done), 300));

  document.querySelector('[data-quote-reset]')?.addEventListener('click', () => {
    form.reset();
    done.hidden = true;
    done.classList.remove('is-in');
    form.hidden = false;
    (form.elements.namedItem('name') as HTMLElement).focus();
  });
}
