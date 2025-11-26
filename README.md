# MCA Finance

A comprehensive Flutter-based finance tracking application that helps you manage your personal finances with ease. Track accounts, transactions, budgets, and get AI-powered financial insights.

## Features

- **Dashboard**: View your financial health score, income/expense summary, budget status, and spending trends
- **Account Management**: Track multiple bank accounts and their balances
- **Transaction Tracking**: Record and categorize income and expenses
- **Budget Management**: Set budgets for different categories and monitor spending
- **Category Organization**: Organize transactions with customizable categories
- **AI Assistant**: Get personalized financial advice and insights through an AI chatbot
- **Financial Health Score**: Real-time assessment of your financial well-being
- **Dark Mode Support**: Automatically adapts to your device's theme preference

## Tech Stack

- **Flutter**: Cross-platform mobile development framework
- **Provider**: State management solution
- **Dio**: HTTP client for API communication
- **json_serializable**: Automatic JSON serialization
- **fl_chart**: Beautiful charts and graphs for data visualization
- **FVM**: Flutter Version Manager for consistent Flutter versions

## Getting Started

### Prerequisites

- Flutter SDK (3.3.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd c_i
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint** (optional)

   You can set a custom API base URL using dart-define:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-api-endpoint.com
   ```

   Or edit [lib/config/env.dart](lib/config/env.dart) to set a default endpoint.

5. **Run the app**
   ```bash
   # Run on connected device/emulator
   flutter run

   # Run on specific device
   flutter run -d <device-id>
   ```

### Development Commands

```bash
# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Watch for model changes and auto-regenerate code
flutter pub run build_runner watch --delete-conflicting-outputs

# Build APK for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for web
flutter build web
```

## Project Structure

```
lib/
├── config/          # Configuration files (theme, environment)
├── models/          # Data models with JSON serialization
├── providers/       # State management (ChangeNotifier classes)
├── screens/         # Full-page UI components
├── services/        # API clients and business logic
└── widgets/         # Reusable UI components
```

## Architecture

### State Management
- Uses Provider pattern for reactive state management
- All providers are registered in [lib/providers/app_providers.dart](lib/providers/app_providers.dart)
- Providers include: AuthProvider, DashboardProvider, CategoryProvider, TransactionProvider, BudgetProvider, AccountProvider

### API Integration
- **BaseService**: Configures Dio client with headers and interceptors
- **ApiInterceptor**: Automatically adds authentication tokens to requests
- **CrudService**: Generic service for CRUD operations on API resources

### Model Serialization
- All models use `@JsonSerializable()` annotation
- After modifying models, run: `flutter pub run build_runner build`

## Configuration

### Theme
- Light and dark themes defined in [lib/config/theme.dart](lib/config/theme.dart)
- Automatically follows system theme preference

### Environment Variables
- API base URL can be configured via `--dart-define=API_BASE_URL`
- Default configuration in [lib/config/env.dart](lib/config/env.dart)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.
