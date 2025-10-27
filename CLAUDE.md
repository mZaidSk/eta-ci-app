# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter-based finance tracking application named "MCA Finance" with support for accounts, transactions, budgets, and categories. Uses Provider for state management, Dio for HTTP networking, and json_serializable for model serialization.

## Development Commands

### Setup
```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code
flutter pub run build_runner build

# Watch for changes and regenerate code
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run with environment variables
flutter run --dart-define=API_BASE_URL=https://your-api.com
```

### Testing & Quality
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code for issues
flutter analyze
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build iOS app
flutter build ios

# Build web app
flutter build web
```

## Architecture

### State Management
- **Provider pattern**: All application state is managed through ChangeNotifierProvider
- **Centralized provider setup**: [lib/providers/app_providers.dart](lib/providers/app_providers.dart) contains `buildAppProviders()` which registers all providers in a single location
- **Provider list**: AuthProvider, DashboardProvider, CategoryProvider, TransactionProvider, BudgetProvider, AccountProvider
- Each provider follows a consistent pattern: loading state, error handling, and notifyListeners() calls

### API & Networking
- **BaseService**: [lib/services/base_service.dart](lib/services/base_service.dart) - Creates configured Dio client with timeouts, headers, and interceptors
- **ApiInterceptor**: [lib/services/api_interceptor.dart](lib/services/api_interceptor.dart) - Automatically injects Bearer token from auth state into all requests
- **CrudService**: [lib/services/crud_service.dart](lib/services/crud_service.dart) - Generic service for CRUD operations, extends BaseService with endpoint-specific methods (list, getById, create, update, delete)
- **Environment config**: API base URL configured via compile-time variable `--dart-define=API_BASE_URL` or defaults to example URL

### Models & Serialization
- All models use json_serializable for automatic JSON conversion
- Import pattern: Models import from [lib/models/json_serializable.dart](lib/models/json_serializable.dart) which re-exports json_annotation
- Generated files: Models like Category and Transaction have corresponding `.g.dart` files (e.g., `category.g.dart`)
- **IMPORTANT**: After modifying any model with `@JsonSerializable()`, run `flutter pub run build_runner build` to regenerate `.g.dart` files

### Routing
- Named routes defined in [lib/main.dart](lib/main.dart)
- Each screen has a static `routeName` constant
- Routes: HomeScreen (initial), LoginScreen, AskAiScreen, ProfileScreen, AccountsScreen, CategoriesScreen, TransactionsScreen, BudgetsScreen

### Theming
- Light and dark themes defined in [lib/config/theme.dart](lib/config/theme.dart)
- ThemeMode.system follows device theme preference
- Access via `AppTheme.light()` and `AppTheme.dark()`

## Project Structure

```
lib/
├── config/          # Environment variables, theme configuration
├── models/          # Data models with JSON serialization
├── providers/       # State management (ChangeNotifier classes)
├── screens/         # Full-page UI components
├── services/        # API clients, business logic
└── widgets/         # Reusable UI components
```

## Important Notes

- **FVM**: Project uses Flutter Version Manager with stable channel (see [fvm/fvm_config.json](fvm/fvm_config.json))
- **Auth**: Currently uses mock authentication in AuthProvider (returns demo token after delay)
- **Initial route**: Configured to HomeScreen, LoginScreen route is commented out in main.dart
- When creating new services for API resources, extend CrudService<T> for automatic CRUD methods
- When adding new providers, register them in [lib/providers/app_providers.dart](lib/providers/app_providers.dart) `buildAppProviders()`
