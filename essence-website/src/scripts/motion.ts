// Scroll and pointer animations. Loaded only when the visitor hasn't asked for reduced motion.
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import Lenis from 'lenis';

gsap.registerPlugin(ScrollTrigger);

const finePointer = matchMedia('(hover: hover) and (pointer: fine)').matches;

export function initMotion() {
  const lenis = smoothScroll();
  reveals();
  leaves();
  hero();
  marquee();
  story();
  steps();
  footerMark();
  if (finePointer) {
    tilt();
    magnetic();
  }
  (window as any).__motionReady = true;
  document.documentElement.classList.remove('reveal-fallback');
  // Images and fonts change layout after load; re-measure the triggers.
  window.addEventListener('load', () => ScrollTrigger.refresh());
  document.fonts?.ready.then(() => ScrollTrigger.refresh());
  return lenis;
}

function smoothScroll() {
  const lenis = new Lenis({ duration: 1.15, smoothWheel: true });
  (window as any).__lenis = lenis;
  lenis.on('scroll', ScrollTrigger.update);
  gsap.ticker.add((t) => lenis.raf(t * 1000));
  gsap.ticker.lagSmoothing(0);

  // In-page links (#story, /#visit on the home page) glide instead of jumping.
  document.addEventListener('click', (e) => {
    const a = (e.target as HTMLElement).closest<HTMLAnchorElement>('a[href*="#"]');
    if (!a || a.origin !== location.origin || a.pathname !== location.pathname || !a.hash) return;
    const target = document.querySelector(a.hash);
    if (!target) return;
    e.preventDefault();
    lenis.scrollTo(target as HTMLElement, { offset: -70, duration: 1.4 });
    history.replaceState(null, '', a.hash);
  });
  return lenis;
}

function reveals() {
  ScrollTrigger.batch('[data-reveal]', {
    start: 'top 90%',
    once: true,
    onEnter: (els) => gsap.to(els, { opacity: 1, y: 0, scale: 1, duration: 1.2, ease: 'expo.out', stagger: 0.1, overwrite: true }),
  });

  // Product grids: cards rise in a wave.
  const cards = gsap.utils.toArray<HTMLElement>('[data-stagger] > *');
  gsap.set(cards, { opacity: 0, y: 60 });
  ScrollTrigger.batch(cards, {
    start: 'top 92%',
    once: true,
    onEnter: (els) => gsap.to(els, { opacity: 1, y: 0, duration: 1.1, ease: 'expo.out', stagger: 0.09, overwrite: true }),
  });
  // Cards in a tab revealed later animate when their tab opens.
  document.addEventListener('tab:shown', (e) => {
    const els = (e.target as HTMLElement).querySelectorAll(':scope > *');
    gsap.fromTo(els, { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.9, ease: 'expo.out', stagger: 0.07, overwrite: true });
  });
}

function leaves() {
  const io = new IntersectionObserver(
    (entries) =>
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add('is-drawn');
          io.unobserve(e.target);
        }
      }),
    { threshold: 0.2 },
  );
  document.querySelectorAll('.leaf[data-draw]').forEach((el) => io.observe(el));
}

function hero() {
  const root = document.querySelector<HTMLElement>('[data-hero]');
  if (!root) return;
  const imgs = gsap.utils.toArray<HTMLElement>('[data-depth]', root);

  // Scroll: the art drifts up at different speeds, the copy fades away.
  imgs.forEach((el) => {
    gsap.to(el, { yPercent: -Number(el.dataset.depth) * 1.2, ease: 'none', scrollTrigger: { trigger: root, start: 'top top', end: 'bottom top', scrub: true } });
  });
  gsap.to(root.querySelector('.hero__copy'), { y: -80, opacity: 0.2, ease: 'none', scrollTrigger: { trigger: root, start: 'top top', end: 'bottom top', scrub: true } });

  // Pointer: a gentle 3D drift.
  if (!finePointer) return;
  const movers = imgs.map((el) => ({ el, d: Number(el.dataset.depth), x: gsap.quickTo(el, 'x', { duration: 1.2, ease: 'power3' }), y: gsap.quickTo(el, 'y', { duration: 1.2, ease: 'power3' }) }));
  root.addEventListener('pointermove', (e) => {
    const r = root.getBoundingClientRect();
    const nx = (e.clientX - r.left) / r.width - 0.5;
    const ny = (e.clientY - r.top) / r.height - 0.5;
    movers.forEach((m) => {
      m.x(nx * m.d * 1.4);
      m.y(ny * m.d);
    });
  });
}

function marquee() {
  const track = document.querySelector<HTMLElement>('[data-marquee]');
  const drip = document.querySelector<SVGPathElement>('[data-drip]');
  if (drip) {
    gsap.fromTo(drip, { scaleY: 0.6, transformOrigin: '50% 0%' }, { scaleY: 1.5, ease: 'none', scrollTrigger: { trigger: drip, start: 'top 80%', end: 'bottom top', scrub: true } });
  }
  if (!track) return;
  // Lean into the scroll: faster scrolling skews the words.
  const skew = gsap.quickTo(track, 'skewX', { duration: 0.6, ease: 'power3' });
  ScrollTrigger.create({
    trigger: track,
    start: 'top bottom',
    end: 'bottom top',
    onUpdate: (self) => skew(gsap.utils.clamp(-12, 12, self.getVelocity() / -260)),
    onLeave: () => skew(0),
    onLeaveBack: () => skew(0),
  });
}

function story() {
  const root = document.querySelector<HTMLElement>('[data-story]');
  if (!root) return;
  const mm = gsap.matchMedia();
  mm.add('(min-width: 861px)', () => {
    const beats = gsap.utils.toArray<HTMLElement>('[data-beat]', root);
    const tl = gsap.timeline({ defaults: { ease: 'none' }, scrollTrigger: { trigger: root, start: 'top top', end: 'bottom bottom', scrub: 0.8 } });
    tl.fromTo('[data-story-img]', { scale: 0.78, clipPath: 'inset(18% 10% 0% 10% round 999px 999px 26px 26px)' }, { scale: 1, clipPath: 'inset(0% 0% 0% 0% round 999px 999px 26px 26px)', duration: 1 }, 0)
      .fromTo('[data-story-bg]', { xPercent: 4 }, { xPercent: -38, duration: 3 }, 0)
      .fromTo(beats, { opacity: 0.12, y: 30 }, { opacity: 1, y: 0, duration: 0.5, stagger: 0.7 }, 0.3)
      .fromTo('[data-beat-body]', { opacity: 0, y: 20 }, { opacity: 1, y: 0, duration: 0.5 }, 2.2)
      .fromTo(root.querySelector('.link-arrow'), { opacity: 0 }, { opacity: 1, duration: 0.4 }, 2.5);
  });
  mm.add('(max-width: 860px)', () => {
    gsap.from(gsap.utils.toArray('[data-beat], [data-beat-body]', root), { opacity: 0, y: 30, stagger: 0.15, duration: 1, ease: 'expo.out', scrollTrigger: { trigger: root, start: 'top 70%' } });
  });
}

function steps() {
  const line = document.querySelector<SVGPathElement>('[data-steps-line]');
  if (!line) return;
  gsap.fromTo(line, { strokeDasharray: 1, strokeDashoffset: 1 }, { strokeDashoffset: 0, ease: 'none', scrollTrigger: { trigger: '[data-steps]', start: 'top 75%', end: 'bottom 55%', scrub: true } });
}

function footerMark() {
  const mark = document.querySelector<HTMLElement>('[data-mark]');
  if (!mark) return;
  const text = mark.textContent ?? '';
  mark.innerHTML = [...text].map((c) => `<span style="display:inline-block">${c}</span>`).join('');
  gsap.from(mark.children, { yPercent: 70, opacity: 0, rotate: 6, stagger: 0.05, duration: 1.4, ease: 'expo.out', scrollTrigger: { trigger: mark, start: 'top 95%' } });
}

function tilt() {
  document.querySelectorAll<HTMLElement>('[data-tilt]').forEach((el) => {
    const media = el.querySelector<HTMLElement>('.tile__media') ?? el;
    el.addEventListener('pointermove', (e) => {
      const r = el.getBoundingClientRect();
      media.style.setProperty('--ry', `${((e.clientX - r.left) / r.width - 0.5) * 10}deg`);
      media.style.setProperty('--rx', `${-((e.clientY - r.top) / r.height - 0.5) * 8}deg`);
    });
    el.addEventListener('pointerleave', () => {
      media.style.setProperty('--ry', '0deg');
      media.style.setProperty('--rx', '0deg');
    });
  });
}

function magnetic() {
  document.querySelectorAll<HTMLElement>('[data-magnetic], .btn').forEach((el) => {
    const magnetic = el.hasAttribute('data-magnetic');
    const x = magnetic ? gsap.quickTo(el, 'x', { duration: 0.6, ease: 'power3' }) : null;
    const y = magnetic ? gsap.quickTo(el, 'y', { duration: 0.6, ease: 'power3' }) : null;
    el.addEventListener('pointermove', (e) => {
      const r = el.getBoundingClientRect();
      el.style.setProperty('--mx', `${e.clientX - r.left}px`);
      el.style.setProperty('--my', `${e.clientY - r.top}px`);
      x?.((e.clientX - r.left - r.width / 2) * 0.25);
      y?.((e.clientY - r.top - r.height / 2) * 0.35);
    });
    el.addEventListener('pointerleave', () => {
      x?.(0);
      y?.(0);
    });
  });
}
