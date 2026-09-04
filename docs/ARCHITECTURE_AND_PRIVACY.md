# Architecture and Privacy

## System view

```text
Flutter client
  ├─ Firebase Authentication ── identity
  ├─ Firestore ──────────────── family-scoped state, results, rewards, memories
  ├─ Storage ────────────────── permitted family media
  ├─ Cloud Messaging ────────── wishlist and family notifications
  └─ HTTPS + Firebase ID token
          ↓
     Express AI gateway
       ├─ CORS allow-list
       ├─ rate limiting
       ├─ request-size limit
       ├─ security headers
       ├─ Firebase token verification
       ├─ Google Gemini (games and mission proof; server-held key)
       └─ OpenRouter (Sila Chat only; server-held key)
```

The client is responsible for presentation and authenticated family journeys.
Firebase rules are the data authorization boundary. The Express service is the
AI trust boundary: generative API keys never belong in the Flutter bundle.

## Data boundaries

| Data | Location | Boundary |
| --- | --- | --- |
| User profile and family membership | Firestore | Signed-in user and family-scoped rules |
| Competition records and trophies | Family Firestore subcollections | Family membership and controlled writes |
| Tokens and owned digital rewards | User Firestore subcollections | User ownership and transactional updates |
| Memories and permitted media | Family Firestore/Storage paths | Family membership rules |
| Push tokens and notifications | User subcollections | User-scoped access; server-side delivery |
| Game prompts, generated game content, and mission proof | Authenticated HTTPS gateway → Google Gemini | Firebase bearer token, CORS, limits, Gemini model fallback |
| Sila Chat messages and limited family context | Authenticated HTTPS gateway → OpenRouter | Firebase bearer token, per-user limits, bounded retained history |
| Judge demo state | In-memory simulated client state | No account and no photo upload |

## Implemented controls

- Production `/api` routes fail closed when Firebase authentication is absent or
  invalid; development can remain usable for local iteration.
- Allowed browser origins are explicit in production. Local origins are accepted
  only in development.
- API requests are rate limited and JSON bodies are capped at 2 MB.
- Security headers reduce accidental information disclosure and browser risk.
- The Flutter release resolver requires an absolute HTTPS API URL. Localhost
  defaults are available only outside release mode.
- Firestore and Storage rules are tested with official Firebase emulators,
  including cross-family denial, owner-only reward management, mission verdict
  storage without retained proof images, wishlist isolation, and storage access.
- The Competition Demo labels its data as simulated and uploads no photos.
- API keys, service accounts, and local `.env` files are excluded from source
  control and must be managed as deployment secrets.

## Production responsibilities

The code controls access paths, but deployment still matters. Before launch:

- rotate any credential ever pasted into chat, logs, screenshots, or a commit;
- store `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, and Firebase service credentials
  in the hosting platform's secret manager;
- keep games on `GEMINI_MODEL`/`GEMINI_FALLBACK_MODEL` and Sila Chat on
  `OPENROUTER_MODEL`; never route game prompts through the chat provider;
- set `NODE_ENV=production` and an exact `KINQUEST_ALLOWED_ORIGINS` list;
- deploy the API behind HTTPS and build the client with that exact URL;
- enable Firebase budget alerts, App Check where supported, and log retention
  appropriate for a family application;
- review consent, deletion, retention, and child-safety obligations with the
  team's UAE legal/privacy adviser before a public pilot;
- define an owner for incident response and credential rotation.

## Threats covered by automated checks

The repository tests production authentication, CORS, privacy headers, rate
limiting, verifier error handling, family rule isolation, reward ownership,
mission proof retention, wishlist separation, responsive layouts, Arabic/RTL,
and the complete judge demo loop.

Automated checks do not replace penetration testing, legal review, production
monitoring, or a backup/restore drill. Those remain release responsibilities.
