/** wa.me chat link to the shop with a message already written ('' when there's no number). */
export function waLink(number: string, message: string, greeting = 'Hi ESSENCE! ') {
  let d = (number || '').replace(/\D/g, '');
  if (d.startsWith('0')) d = `92${d.slice(1)}`;
  return d ? `https://wa.me/${d}?text=${encodeURIComponent(`${greeting}${message}`)}` : '';
}
