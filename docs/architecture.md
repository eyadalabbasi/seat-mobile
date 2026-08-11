# SEAT Customer Mobile Architecture

The app uses feature-first clean architecture. `core` owns environment configuration, Dio transport, encrypted platform credential storage, analytics/push contracts, safe shared models, and reusable UI. Each feature owns its `data`, `domain` where rules warrant it, and `presentation` boundary. Riverpod supplies dependencies and async state; go_router owns declarative navigation and preserves each bottom-tab stack.

API repositories are the only application layer that knows HTTP paths. Widgets receive customer-safe models without table IDs, allocation IDs, candidate scores, or staff notes. Access and refresh tokens use platform secure storage. The Dio interceptor attaches bearer credentials and performs a single-flight refresh; a failed refresh clears the session. Structured backend 4xx codes are mapped to recoverable UI rather than treated as 500s.

Pending request detail polls every 15 seconds only while foregrounded. Polling pauses when the app leaves the foreground and refreshes on resume. Push is an abstract integration seam and pull-to-refresh remains available. The server is authoritative for all transitions.

Development fixtures can only be enabled explicitly with `ENABLE_DEV_FIXTURES=true`; startup rejects them in production. No production screen depends on fixtures.
