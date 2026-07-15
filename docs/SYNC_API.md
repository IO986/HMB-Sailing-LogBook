# Sync API — HMB Sailing Log

Reference for anyone implementing a backend endpoint that HMB Sailing Log
can sync to (`Nastavenia → Synchronizácia → Vlastný server`). The app comes
with a built-in transport for `hmba.boats` (Strapi) and a generic REST
transport for anything else. Both send the exact same envelope — only the
URL shape and attachment step differ.

---

## 1. Transport, per target

| Setting: Cieľ synchronizácie | Transport | Endpoint shape | Attachments |
|---|---|---|---|
| HMB Sailing Academy (`hmba.boats`) | `StrapiTransport` | `POST {baseUrl}/api/{collection}`, body `{"data": <envelope>}` | `POST {baseUrl}/api/upload` first, file id goes into `envelope.attachments` |
| Vlastný server | `RestTransport` | `POST {baseUrl}/{entityType}`, body is `<envelope>` directly (no wrapper) | inlined as base64 inside `envelope.attachments`, no separate request |

One request per outbox item either way (`batchSize = 1`) — there is no
bulk-create endpoint assumed for either transport.

**HTTPS is mandatory** for a custom server. The app refuses to construct a
transport for a plain-`http://` URL; the auth token travels in the
`Authorization` header and would otherwise leak in transit.

---

## 2. The envelope

Every request body (or, for Strapi, everything under `"data"`) is this
shape:

```json
{
  "clientId": "b3f1c2d4-...-uuid-v4",
  "entityType": "log_entry",
  "operation": "create",
  "timestamp": "2026-07-14T09:12:03+02:00",
  "appVersion": "1.21.0+42",
  "payload": { },
  "attachments": []
}
```

| Field | Type | Notes |
|---|---|---|
| `clientId` | string (uuid v4) | Generated on the device. **The idempotency key** — see §5. |
| `entityType` | string | One of the values in §3. |
| `operation` | string | `create` \| `update` \| `delete`. |
| `timestamp` | string, ISO-8601 | Local time **with a numeric UTC offset** (e.g. `+02:00`), never `Z`. When the record was created on the device, not when it's sent. |
| `appVersion` | string | `<version>+<buildNumber>`, e.g. `1.21.0+42`. |
| `payload` | object | Entity-specific fields — see §4. Opaque to the sync layer; shape is entirely up to `entityType`. |
| `attachments` | array | See §3 for the shape per transport. Empty array if none. |

### Attachment entries

**Strapi transport** (after `POST /api/upload`):
```json
{ "field": "photo", "remoteRef": "42" }
```
`remoteRef` is the uploaded file's id as returned by Strapi's upload
endpoint.

**Custom REST transport** (inlined, no upload step):
```json
{ "field": "photo", "mimeType": "image/jpeg", "data": "<base64>" }
```

`field` always matches the name the payload table below documents for that
attachment (e.g. `"photo"` for a `log_entry`'s picture).

---

## 3. `entityType` values

`voyage`, `log_entry`, `track_point`, `instrument_sample`, `photo`,
`vessel`. Only `log_entry` is actually produced by the app today (manual
logbook entries and quick-photo); the rest are reserved for entities not
wired into the outbox yet.

---

## 4. `payload` contents per entity

| `entityType` | `payload` contains |
|---|---|
| `voyage` | departure port, arrival port, start/end time, **`crew_count`** (headcount only — see §6) |
| `log_entry` | timestamp, position, **`accuracy_meters`, `location_source`, `is_mocked`** (GPS fix quality — see the app's own location-quality feature), event type, note |
| `track_point` | GPS point, timestamp, speed, course |
| `instrument_sample` | wind, depth, log, heading (NMEA/Raymarine) |
| `photo` | attachment + metadata (caption, timestamp, position if available) |
| `vessel` | name, type, registration |

## What is never sent

- **Crew names or any contact info.**
- **Safety briefing content, acknowledgements, or signatures.**

The only crew-related field that ever leaves the device is `crew_count` on
a `voyage` payload — a number, not people. This is a deliberate privacy
design decision (minimise personal data in transit), not a temporary gap.
There is no setting, flag, or configuration that re-enables sending crew
names, contacts, or safety-briefing/signature data — implementing a custom
server does not get you this data either, because the app never
constructs a payload containing it.

---

## 5. Idempotency

`clientId` is the outbox item's own id (a uuid v4 generated on the
device), stable across retries. Your server must treat it as a unique key
per record:

- **First time you see a `clientId`:** create the record normally, `2xx`.
- **A `clientId` you've already stored:** this is a **retry of an already-
  accepted item**, not a new record and not an error. Respond `409
  Conflict` (preferred), or `400` with a message naming the field (the app
  looks for `"clientid"` or `"unique"`, case-insensitively, in the error
  body to recognise this as `400`-shaped duplicate too). **Do not create a
  second record.**

The app enqueues + writes its local copy in a single database transaction
(see the app's own "domain write ↔ enqueue" wiring) — a record can't exist
locally without also being queued, or vice versa. But *retries* are normal:
a push can succeed on your server while the response is lost to a network
blip, in which case the app retries the same `clientId` and expects the
`409`/duplicate response above, not a second row.

---

## 6. HTTP response contract

| Response | Outcome |
|---|---|
| `2xx` | Success. Store your server-assigned id if you have one — the app doesn't require it, but keeps it if returned. |
| `409`, or `400` naming the unique field | Duplicate (§5) — treated as success, not retried. |
| `408`, `429`, any `5xx`, or a connection/read/write timeout | **Retryable** — the app retries with exponential backoff (jitter, capped) up to a configured max attempts. |
| `400` (not a duplicate), `401`, `403`, `404`, `422` | **Non-retryable** — the app gives up on this item immediately and surfaces it as "failed" in the sync queue screen, requiring a manual retry. |

Anything else (a network exception with no response at all) is treated the
same as a retryable failure.

---

## 7. Sync cadence

Sync runs **only while the app is open** — there is no background service,
foreground service, or platform job scheduler (WorkManager/BGTaskScheduler)
involved. A user-configurable timer (5 / 15 / 30 minutes, default 15)
drives periodic retries while the app is in the foreground; opening the
app or regaining connectivity also triggers an immediate attempt.

### Attachment policy and retry budget

The attachment setting (`nikdy` / `len na Wi-Fi` / `vždy`) — and the
sync enable/disable toggle — are enforced entirely client-side, before
your endpoint is ever called: on `len na Wi-Fi`, an item with an
attachment is held back while the device is on mobile data; with sync
disabled, nothing is attempted at all.

Neither case reaches your server, and **neither spends retry budget.**
`SyncPolicyTransport` reports a held-back item as `hmb_core`'s
`SyncItemOutcome.deferred` — a distinct outcome from a real `failure`.
The sync engine leaves the item's `retryCount` and last-attempt time
untouched for a `deferred` result: it isn't treated as an attempt at all,
so it can never exhaust `maxRetries` and can never end up "failed" purely
because of a local policy. The item is simply re-evaluated against the
same policy on the next cycle (periodic timer, app foreground, or
connectivity restored) and sent as soon as the gate clears — indefinitely,
with no backoff growth, since `retryCount` never moves.

This is a structural guarantee, not a convention your server needs to
account for: because `deferred` never reaches a transport's `push()` at
all, your endpoint has no way to distinguish "the app hasn't tried yet"
from "the app tried and a policy held it back" — both look identical from
the server side (no request happened).

**In the UI**, this status is surfaced as "Odložené" (deferred) — visually
and structurally distinct from "Zlyhalo" (failed, `SyncStatus.failed`) in
both the queue screen and the header badge, backed by a dedicated
`deferred` count in the sync queue snapshot (not inferred from error-text
matching). A deferred item never shows a retry count, since none was
spent.

### "Test connection"

The settings screen's "Otestovať pripojenie" button does a plain `GET /`
against your base URL (with the configured token) and reports success on
**any** HTTP response, including a `404` — it's checking that DNS/TLS/
routing work, not that a particular route exists. A network, TLS, or
timeout exception is reported as failure.
