// Firestore over REST: no SDK, a few hundred bytes. Public reads (menu, store info) and the order create.
import { site } from '../site.config';

const emulator = import.meta.env.PUBLIC_FIRESTORE_EMULATOR as string | undefined;
const { projectId, apiKey, storeId } = site.firebase;
const root = `projects/${projectId}/databases/(default)/documents`;
const api = emulator ? `http://${emulator}/v1` : 'https://firestore.googleapis.com/v1';
const key = emulator ? '' : `key=${apiKey}`;

export const storePath = `${root}/stores/${storeId}`;

type Value = Record<string, any>;

export function fromValue(v: Value | undefined): any {
  if (!v) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('timestampValue' in v) return v.timestampValue;
  if ('arrayValue' in v) return (v.arrayValue.values ?? []).map(fromValue);
  if ('mapValue' in v) return fromFields(v.mapValue.fields ?? {});
  return null;
}
const fromFields = (f: Record<string, Value>) => Object.fromEntries(Object.entries(f).map(([k, v]) => [k, fromValue(v)]));

export function toValue(v: unknown): Value {
  if (v === null || v === undefined) return { nullValue: null };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  if (Array.isArray(v)) return { arrayValue: { values: v.map(toValue) } };
  return { mapValue: { fields: toFields(v as Record<string, unknown>) } };
}
const toFields = (o: Record<string, unknown>) => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined).map(([k, v]) => [k, toValue(v)]));

const withKey = (url: string) => (key ? `${url}${url.includes('?') ? '&' : '?'}${key}` : url);

export async function getDoc<T = any>(path: string): Promise<T | null> {
  const res = await fetch(withKey(`${api}/${storePath}/${path}`), { signal: AbortSignal.timeout(8000) });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const d = await res.json();
  return fromFields(d.fields ?? {}) as T;
}

export async function listDocs<T = any>(collection: string): Promise<(T & { id: string })[]> {
  const res = await fetch(withKey(`${api}/${storePath}/${collection}?pageSize=300`), { signal: AbortSignal.timeout(8000) });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const body = await res.json();
  return (body.documents ?? []).map((d: any) => ({ id: d.name.split('/').pop(), ...fromFields(d.fields ?? {}) }));
}

export class CreateError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

/** Creates a document only if it doesn't exist; `serverTime` fields are set to the request time. */
export async function createDoc(path: string, data: Record<string, unknown>, serverTime: string[] = []) {
  const res = await fetch(withKey(`${api}/${root}:commit`), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    signal: AbortSignal.timeout(15000),
    body: JSON.stringify({
      writes: [
        {
          update: { name: `${storePath}/${path}`, fields: toFields(data) },
          currentDocument: { exists: false },
          updateTransforms: serverTime.map((f) => ({ fieldPath: f, setToServerValue: 'REQUEST_TIME' })),
        },
      ],
    }),
  });
  if (!res.ok) throw new CreateError(res.status, await res.text());
}
