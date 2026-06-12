# mathverse-flutter

Flutter web frontend for MathVerse. Uses BLoC for state management, Clean Architecture, and Dio for API calls.

## Development

```bash
flutter pub get
flutter run -d chrome
```

To target a different API base URL:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Build

```bash
flutter build web
```

## Architecture

- **lib/core/** — Network client, routing (go_router), theme, DI (GetIt)
- **lib/features/** — Feature modules, each with data/domain/presentation layers
- **lib/di/** — GetIt service registration

See `../docs/architecture.md` for the full system architecture.
