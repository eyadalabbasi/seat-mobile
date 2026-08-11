# API Integration

The client targets the frozen SEAT API under `/api/v1`.

| Capability | Endpoint |
|---|---|
| OTP | `POST /auth/otp/request`, `POST /auth/otp/verify` |
| Session | `POST /auth/refresh`, `POST /auth/logout`, `GET /auth/me` |
| Discovery | `GET /restaurants`, `/restaurants/search`, `/restaurants/:id`, `/restaurants/:id/branches` |
| Requests | `POST /reservations`, `GET /me/reservations`, `GET /reservations/:id` |
| Customer decisions | `POST /reservations/:id/accept-alternative`, `/decline-alternative`, `/cancel` |
| Notifications | `GET /me/notifications`, `/unread-count`, `PATCH /me/notifications/:id/read` |
| Profile/settings | `GET/PATCH /me/profile`, `GET/PATCH /me/notification-preferences` |
| Device registration | `POST /me/devices`, `DELETE /me/devices/:deviceId` (provider adapter pending credentials) |

`Idempotency-Key` is generated for reservation creation and alternative acceptance/decline. A submission timeout is treated as unknown outcome; the app does not claim confirmation and refreshes server state. Customer DTOs intentionally discard allocation internals.

Backend integration prerequisite: set a reachable base URL. Android emulators use `http://10.0.2.2:3000` for local development; physical devices need the host LAN address and production requires HTTPS.
