# Localization and RTL

English and Arabic are generated from ARB files. English uses the `Inter` family token and Arabic uses `Noto Sans Arabic`; final licensed font files must be supplied before store release, otherwise the platform fallback is used. Locale persistence is local and is also synchronized to the profile when authenticated.

Arabic is natural, concise, and Gulf-friendly. Layout direction is inherited rather than manually mirrored. Phone numbers, OTP, timestamps, and Latin digits remain LTR islands. Directional icons follow Flutter mirroring; brand marks and media do not mirror. Both languages use Latin digits 0–9.
