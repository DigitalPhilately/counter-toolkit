# Counter Toolkit

Counter Toolkit is a Flutter app for front-counter postal work. It is designed
as a practical queue-side helper for common parcel, postage, and service
questions.

Current app version: `0.2.1+3`

## Live Tools

- Track & Trace lookup flow with provider-aware routing and demo journeys.
- Best Fit Stamps calculator for exact postage make-up from the stamp book.
- Dashboard and About screens with Counter Toolkit branding, product notes, and
  visible build version.
- Multi-platform Flutter project with generated launcher icons for supported
  targets.

## Backlog

- Connect Track & Trace to a live backend adapter.
- Add Parcel Sizer: carrier size and weight limits, plus height, width, depth,
  and weight entry to provide a format or size guide.
- Persist the stamp workflow with picked-state memory and saved stock
  exclusions.
- Add service comparison prompts for customer conversations.

## Project Shape

- App shell and dependency wiring live under `lib/app`.
- Dashboard, About, tracking, and stamp features live under `lib/features`.
- Domain logic is covered by focused tests under `test/features`.
- Widget tests cover the main user-facing flows.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d macos
```
