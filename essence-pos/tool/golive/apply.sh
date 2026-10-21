#!/bin/bash
# Applies build/golive.json to the live store as an admin login.
# Usage: ADMIN_EMAIL=... ADMIN_PASSWORD=... tool/golive/apply.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
KEY=$(grep -A3 "static const FirebaseOptions web" lib/firebase_options.dart | grep apiKey | sed "s/.*apiKey: '\(.*\)',/\1/")
TOK=$(curl -s -X POST -H 'Content-Type: application/json' \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\",\"returnSecureToken\":true}" \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$KEY" | python3 -I -c 'import json,sys;print(json.load(sys.stdin)["idToken"])')
python3 -I - "build/golive.json" <<'PY' > build/golive_batches.jsonl
import json, sys
DOC = 'projects/essenceisb/databases/(default)/documents/stores/essence'
def val(v):
    if v is None: return {'nullValue': None}
    if isinstance(v, bool): return {'booleanValue': v}
    if isinstance(v, int): return {'integerValue': str(v)}
    if isinstance(v, float): return {'doubleValue': v}
    if isinstance(v, str): return {'stringValue': v}
    if isinstance(v, list): return {'arrayValue': {'values': [val(x) for x in v]}}
    if isinstance(v, dict): return {'mapValue': {'fields': {k: val(x) for k, x in v.items()}}}
    raise TypeError(type(v))
writes = json.load(open(sys.argv[1]))
out = []
for w in writes:
    u = {'update': {'name': f"{DOC}/{w['collection']}/{w['id']}", 'fields': {k: val(x) for k, x in w['data'].items()}},
         'updateTransforms': [{'fieldPath': 'syncedAt', 'setToServerValue': 'REQUEST_TIME'}]}
    if 'mask' in w:
        u['updateMask'] = {'fieldPaths': w['mask']}
        u['currentDocument'] = {'exists': True}
    out.append(u)
for i in range(0, len(out), 15):
    print(json.dumps({'writes': out[i:i+15]}))
PY
n=0
while IFS= read -r batch; do
  r=$(curl -s -X POST -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' -d "$batch" \
    'https://firestore.googleapis.com/v1/projects/essenceisb/databases/(default)/documents:commit')
  if echo "$r" | grep -q '"error"'; then echo "batch $n failed: $r"; exit 1; fi
  n=$((n+1)); echo "batch $n ok"
done < build/golive_batches.jsonl
echo "Applied $(python3 -I -c 'import json;print(len(json.load(open("build/golive.json"))))') writes."
