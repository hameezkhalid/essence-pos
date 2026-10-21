// Tiny Firestore REST helpers shared by the build scripts (no Firebase SDK needed).

/** Converts a Firestore REST `Value` into plain JSON. */
export function fromValue(v) {
  if (v == null) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('nullValue' in v) return null;
  if ('timestampValue' in v) return v.timestampValue;
  if ('arrayValue' in v) return (v.arrayValue.values ?? []).map(fromValue);
  if ('mapValue' in v) return fromFields(v.mapValue.fields ?? {});
  return null;
}

export function fromFields(fields) {
  return Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, fromValue(v)]));
}

/** Lists every document in a store collection. */
export async function listCollection(base, collection, apiKey) {
  const out = [];
  let pageToken = '';
  do {
    const url = `${base}/${collection}?pageSize=300${pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : ''}${apiKey ? `&key=${apiKey}` : ''}`;
    const res = await fetch(url, { signal: AbortSignal.timeout(15000) });
    if (!res.ok) throw new Error(`${collection}: HTTP ${res.status} ${await res.text()}`);
    const body = await res.json();
    for (const d of body.documents ?? []) out.push({ id: d.name.split('/').pop(), ...fromFields(d.fields ?? {}) });
    pageToken = body.nextPageToken ?? '';
  } while (pageToken);
  return out;
}
