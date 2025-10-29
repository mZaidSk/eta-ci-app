# MCA Finance - Complete Features List

> A comprehensive Flutter-based personal finance management application with AI-powered insights

---

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Screens & UI](#screens--ui)
- [API Integrations](#api-integrations)
- [Technical Architecture](#technical-architecture)
- [Authentication & Security](#authentication--security)
- [Analytics & Insights](#analytics--insights)
- [AI Features](#ai-features)

---

## Overview

**MCA Finance** is a production-ready personal finance tracking application built with Flutter, featuring:
- Multi-account management
- Transaction tracking (one-time & recurring)
- Budget planning and monitoring
- Category-based expense organization
- Advanced financial analytics dashboard
- AI-powered financial assistant chatbot
- Real-time insights and health scoring

**Tech Stack:**
- Flutter (Material Design 3)
- Provider (State Management)
- Dio (HTTP Client)
- JSON Serialization
- RESTful API Backend Integration

---

## Core Features

### 1. Account Management

**Multiple Account Types:**
- 💰 **Savings Accounts** (Green theme)
- 🏦 **Checking Accounts** (Blue theme)
- 💳 **Credit Accounts** (Orange theme)
- 📈 **Investment Accounts** (Purple theme)

**Account Features:**
- Real-time balance tracking
- Account number masking (* * * * 1234)
- Debt indicator for negative balances
- Color-coded visual organization
- Create, edit, and delete accounts

### 2. Transaction Management

**Transaction Types:**
- ✅ Income transactions
- ❌ Expense transactions

**Transaction Features:**
- Amount, description, date tracking
- Account and category association
- Transaction history with search/filter
- Edit and delete capabilities
- Visual indicators (+ for income, - for expense)
- Pull-to-refresh updates

**Recurring Transactions:**
- Automated transaction scheduling
- Frequency options:
  - Daily
  - Weekly
  - Monthly
  - Quarterly
  - Yearly
- Start and end date configuration
- Active/inactive status tracking
- Separate management interface

### 3. Budget Planning

**Budget Features:**
- Category-based budgets
- Date range specification (start/end)
- Amount allocation
- Real-time spending tracking
- Progress visualization
- Budget status indicators:
  - 🟢 Green: Under 80% spent
  - 🟠 Orange: 80-99% spent
  - 🔴 Red: Over 100% (exceeded)
- Remaining budget calculations
- Over-budget warnings

### 4. Category Organization

**Category Management:**
- Income categories
- Expense categories
- Custom category names
- Custom colors (hex color picker)
- Custom icons (MaterialIcons library)
- Grid-based visual display
- Type badges (INCOME/EXPENSE)

### 5. Financial Dashboard

**Dashboard Analytics:**
- 💚 **Financial Health Score** (0-100)
  - Savings Points (40 max)
  - Budget Points (30 max)
  - Stability Points (20 max)
  - Color-coded rating system
  - Health status (Excellent/Good/Fair/Poor)

- 💵 **Summary Cards**
  - Total Income
  - Total Expense
  - Net Balance
  - Account Count

- 📊 **Budget Status**
  - Top 3 active budgets
  - Progress bars
  - Remaining/overspent amounts
  - Quick navigation to Budgets tab

- 🏷️ **Top Spending Categories**
  - Top 5 expense categories
  - Total spending per category
  - Quick navigation to Categories tab

- 📈 **Monthly Trend**
  - 3-month income/expense history
  - Visual comparison (↓ income, ↑ expense)
  - Date-based organization

**Dashboard Features:**
- Pull-to-refresh
- Error states with retry
- Loading indicators
- Responsive layout

### 6. AI Financial Assistant

**Chatbot Features:**
- 🤖 Natural language conversations
- Financial query processing
- Context-aware responses
- Chat history management
- Multi-conversation support

**Chat Interface:**
- Message bubbles (user/assistant)
- Sender avatars
- Timestamp display
- Typing indicators
- Auto-scroll to latest message
- Send button with loading states

**Conversation Management:**
- Create new conversations
- View conversation history
- Delete old conversations
- Resume previous conversations
- Conversation titles
- Message count tracking
- Last message preview

**AI Capabilities:**
- Budget status inquiries
- Spending trend analysis
- Account balance queries
- Recent transaction reviews
- Financial advice
- Expense insights

---

## Screens & UI

### Authentication

#### Login Screen (`/login`)
- Email and password form
- Email validation (regex)
- Password validation (min 6 chars)
- Show/hide password toggle
- Loading state during authentication
- Error messages via SnackBar
- Link to registration

#### Register Screen (`/register`)
- Full name input
- Email input with validation
- Password with strength requirements
- Confirm password matching
- Show/hide password toggles
- Auto-login after registration
- Error handling

#### Auth Wrapper (`/`)
- Automatic authentication check
- Route redirection based on auth status
- Loading state

#### Profile Screen (`/profile`)
- User avatar (initial letter)
- Name and email display
- User ID display
- Account status
- Menu items:
  - Settings
  - Security
  - About
- Logout with confirmation
- Session information

### Main Application

#### Home Screen (`/home`)
**Layout:**
- Four-tab bottom navigation:
  1. Home (Dashboard)
  2. Categories
  3. Budgets
  4. Accounts
- Floating AI Assistant button
- Center Transactions button
- Dynamic app bar title

**Home Tab:**
- Complete financial dashboard
- All analytics widgets
- Pull-to-refresh
- Scrollable content

**Embedded Tabs:**
- Categories screen
- Budgets screen
- Accounts screen

#### Transactions Screen (`/transactions`)
**Layout:**
- Two-tab interface:
  1. Transactions
  2. Recurring Transactions

**Transaction List:**
- Card-based layout
- Transaction details:
  - Amount with +/- indicator
  - Category name
  - Account name
  - Date
  - Description (if available)
- Edit button per transaction
- Delete button per transaction
- Empty state messaging
- Error state with retry

**Recurring List:**
- Similar card layout
- Frequency badge
- Date range display
- Active/inactive status

**Add Transaction:**
- Modal bottom sheet form
- Draggable scroll
- Keyboard-aware

**FAB Actions:**
- Add transaction
- Add recurring transaction

#### Categories Screen (`/categories`)
**Layout:**
- Two-tab interface:
  1. Income Categories
  2. Expense Categories

**Grid Display:**
- 2-column grid
- Color-coded cards
- Custom icons
- Category names
- Type badges
- Edit/delete actions per card

**Empty/Error States:**
- Contextual messages
- Action buttons

#### Accounts Screen (`/accounts`)
**Grid Display:**
- 2-column grid
- Account cards with:
  - Type icon
  - Type color theme
  - Account name
  - Account type
  - Masked number
  - Balance display
  - Debt indicator (if negative)
  - Delete button

**Empty State:**
- Welcome message
- Create first account action

#### Budgets Screen (`/budgets`)
**List Display:**
- Vertical list of budget cards
- Each card shows:
  - Category icon and name
  - Date range
  - Spent vs Total
  - Percentage bar
  - Progress color coding
  - Remaining/exceeded amount
  - Delete action

**Add Budget:**
- App bar action button
- Modal form

#### Chat Screen (`/chat`)
**Chat Interface:**
- Message list with scrolling
- User messages (right-aligned, primary color)
- AI messages (left-aligned, light background)
- Avatars (AI icon, person icon)
- Relative timestamps

**Empty State:**
- Welcome message
- Feature suggestions

**Input Area:**
- Text field with placeholder
- Send button (circular)
- Disabled state while sending
- Loading spinner during send

**App Bar:**
- "New Chat" button
- "Chat History" button

**Features:**
- Auto-scroll to bottom
- Typing indicator
- Error message banner

#### Conversations Screen (`/conversations`)
**Conversation List:**
- Card-based layout
- Conversation details:
  - Title
  - Last message preview
  - Message count
  - Last updated time
  - Delete button

**Actions:**
- Tap to open conversation
- Delete with confirmation
- New chat button

**States:**
- Empty state with call-to-action
- Error state with retry
- Pull-to-refresh

---

## API Integrations

### Authentication Endpoints

```
POST /users/login/
- Body: { email, password }
- Returns: { access_token, refresh_token, user }

POST /users/register/
- Body: { name, email, password }
- Returns: { access_token, refresh_token, user }

GET /auth/me
- Headers: Authorization: Bearer <token>
- Returns: { user }
```

### Resource Endpoints (CRUD)

```
Transactions:
GET    /transactions/          - List with optional filters
GET    /transactions/{id}/     - Get single
POST   /transactions/          - Create
PUT    /transactions/{id}/     - Update
DELETE /transactions/{id}/     - Delete

Recurring Transactions:
GET    /recurring-transactions/
POST   /recurring-transactions/
PUT    /recurring-transactions/{id}/
DELETE /recurring-transactions/{id}/

Categories:
GET    /categories/
POST   /categories/
PUT    /categories/{id}/
DELETE /categories/{id}/

Accounts:
GET    /accounts/
POST   /accounts/
PUT    /accounts/{id}/
DELETE /accounts/{id}/

Budgets:
GET    /budgets/
POST   /budgets/
PUT    /budgets/{id}/
DELETE /budgets/{id}/
```

### Dashboard Analytics Endpoints

```
Basic Analytics:
GET /dashboard/summary/?account={id}
- Returns: total_income, total_expense, net_balance, accounts

GET /dashboard/category-breakdown/?account={id}
- Returns: income[], expense[] by category

GET /dashboard/budget-vs-actual/?account={id}
- Returns: category, budget, actual, remaining, percentage

GET /dashboard/monthly-trend/?account={id}
- Returns: month-by-month income/expense

Advanced Analytics:
GET /dashboard/financial-health/
- Returns: total_score (0-100), rating, savings_points, budget_points, stability_points

GET /dashboard/spending-trends/?account={id}
- Returns: month-over-month, year-over-year growth rates

GET /dashboard/cash-flow-forecast/?months={n}
- Returns: predicted future cash flow

GET /dashboard/budget-burn-rate/
- Returns: budget consumption rate analysis

GET /dashboard/spending-patterns/?account={id}
- Returns: spending by day of week, weekly trends

GET /dashboard/category-intelligence/?account={id}
- Returns: detailed category statistics and insights

GET /dashboard/transaction-statistics/?account={id}&days={n}
- Returns: statistical analysis with outlier detection

GET /dashboard/period-comparison/
- Returns: comparison between two date periods
```

### AI Chat Endpoints

```
POST /ai/chat/
- Body: { message, conversation_id? }
- Returns: { reply, conversation_id }

GET /ai/conversations/
- Returns: [ { id, title, message_count, last_message, created_at, updated_at } ]

GET /ai/conversations/{id}/
- Returns: { id, title, messages[], created_at, updated_at }

POST /ai/conversations/create/
- Body: { title }
- Returns: { id, title, created_at }

DELETE /ai/conversations/{id}/delete/
- Returns: { success: true }
```

---

## Technical Architecture

### State Management (Provider)

**9 Providers:**

1. **AuthProvider**
   - User authentication state
   - Token management
   - Login/register/logout methods

2. **DashboardProvider**
   - All dashboard analytics data
   - Summary, trends, health score
   - Parallel data fetching
   - Error handling

3. **TransactionProvider**
   - Transaction list management
   - CRUD operations
   - Type filtering
   - Total calculations

4. **RecurringTransactionProvider**
   - Recurring transaction management
   - Frequency-based operations
   - CRUD functionality

5. **CategoryProvider**
   - Category list state
   - Create/update/delete
   - Type filtering (income/expense)
   - Color and icon management

6. **AccountProvider**
   - Account list management
   - Type-based operations
   - Balance tracking

7. **BudgetProvider**
   - Budget list state
   - Progress calculations
   - Create/update/delete

8. **ChatProvider**
   - Current conversation state
   - Conversation list
   - Message sending
   - Conversation management

9. **All providers registered in:** `buildAppProviders()`

### Services (API Layer)

**BaseService:**
- Dio HTTP client configuration
- Default base URL: `http://192.168.0.102:8000/api`
- Configurable via: `--dart-define=API_BASE_URL=<url>`
- Timeouts: 15s connect, 20s send/receive
- JSON content type
- ApiInterceptor integration

**ApiInterceptor:**
- Automatic Bearer token injection
- Token management (set/clear)

**CrudService<T>:**
- Generic CRUD operations
- Base class for resource services

**Specialized Services:**
- AuthService
- TransactionService
- RecurringTransactionService
- CategoryService
- AccountService
- BudgetService
- DashboardService
- ChatService

### Models (Data Layer)

**9 Core Models:**

1. **User** - Authentication user data
2. **Transaction** - Income/expense records
3. **RecurringTransaction** - Automated transactions
4. **Category** - Income/expense categories
5. **Account** - Financial accounts
6. **Budget** - Budget allocations
7. **ChatMessage** - Chat message records
8. **Conversation** - Chat conversation data
9. **DashboardStats** (deprecated, backward compatibility)

**Model Features:**
- JSON serialization (fromJson/toJson)
- Computed properties
- copyWith() methods
- Type-safe field access
- snake_case to camelCase mapping

### Widgets (Reusable Components)

1. **TransactionForm** - Add/edit transactions
2. **RecurringTransactionForm** - Add/edit recurring
3. **CategoryForm** - Add/edit categories
4. **AccountForm** - Add/edit accounts
5. **BudgetForm** - Add/edit budgets
6. **FancyBottomNav** - Custom bottom navigation

### Routing

**Named Routes System:**
```
/          - AuthWrapper
/login     - LoginScreen
/register  - RegisterScreen
/home      - HomeScreen
/profile   - ProfileScreen
/transactions - TransactionsScreen
/categories   - CategoriesScreen
/accounts     - AccountsScreen
/budgets      - BudgetsScreen
/chat         - ChatScreen
/conversations - ConversationsScreen
```

**Route Arguments:**
- ChatScreen accepts conversationId parameter

### Theming

**Material Design 3:**
- Seed color: `#0BA39D` (Teal)
- Light theme with system default
- Dark theme with system default
- ThemeMode.system (follows device)

**Custom Themes:**
- Account type colors (Savings, Checking, Credit, Investment)
- Budget status colors (Green, Orange, Red)
- Health score gradient colors

---

## Authentication & Security

**Security Features:**
- Bearer token authentication
- Automatic token injection via interceptor
- Token storage in provider
- Session management
- Logout functionality with cleanup

**Form Validation:**
- Email regex validation
- Password strength requirements (min 6 chars)
- Name validation (min 2 chars)
- Password confirmation matching
- Real-time validation feedback

**API Security:**
- All protected endpoints require Bearer token
- Token automatically added to request headers
- 401/403 error handling

---

## Analytics & Insights

### Financial Health Score (0-100)

**Components:**
- **Savings Points** (40 max)
  - Measures savings rate
  - Income vs expense ratio

- **Budget Points** (30 max)
  - Budget adherence
  - Number of active budgets

- **Stability Points** (20 max)
  - Transaction consistency
  - Income regularity

- **Spending Efficiency** (10 max)
  - Expense optimization

**Rating System:**
- 80-100: Excellent (Green)
- 60-79: Good (Light Green)
- 40-59: Fair (Orange)
- 0-39: Poor (Red)

### Dashboard Analytics

**Available Metrics:**
1. Total Income/Expense/Balance
2. Account count and overview
3. Category-wise spending breakdown
4. Budget vs Actual comparison
5. 3-month spending trends
6. Month-over-month growth
7. Year-over-year comparison
8. Cash flow forecasting
9. Budget burn rate analysis
10. Spending pattern detection
11. Category intelligence
12. Transaction statistics
13. Outlier detection
14. Period comparisons

### Visual Representations

- Progress bars for budgets
- Color-coded indicators
- Trend arrows (↑ expense, ↓ income)
- Health score gradient
- Percentage displays
- Amount formatting
- Date formatting

---

## AI Features

### Chatbot Capabilities

**Financial Queries:**
- "What's my budget status?"
- "Show my spending trends"
- "How much did I spend on groceries?"
- "What's my account balance?"
- "Recent transactions?"

**AI Tools Available (9 tools):**
1. Get expenses by category
2. Get income by category
3. Check budget status
4. Get transactions by type
5. Get recent transactions
6. Get account balances
7. Get spending statistics
8. Analyze spending trends
9. Get budget recommendations

**Conversation Features:**
- Persistent conversation history
- Multi-turn conversations
- Context retention
- Natural language understanding
- Friendly, conversational tone

**Technical Details:**
- Powered by: LangChain + Google Gemini 2.0 Flash
- Agent-based architecture
- Tool calling for data access
- Streaming responses (optional)
- Error handling and fallbacks

---

## UI/UX Features

### User Experience

**Loading States:**
- Circular progress indicators
- Skeleton screens
- Shimmer effects
- Loading overlays

**Empty States:**
- Contextual messaging
- Helpful suggestions
- Action buttons
- Friendly icons

**Error States:**
- Clear error messages
- Retry buttons
- Error icons
- User-friendly language

**Feedback Mechanisms:**
- SnackBar notifications
- Success messages
- Error alerts
- Confirmation dialogs

**Interactive Elements:**
- Pull-to-refresh (all lists)
- Swipe gestures
- Tap actions
- Long press options
- Modal bottom sheets
- Draggable sheets
- Floating action buttons

**Visual Design:**
- Card-based layouts
- Elevation and shadows
- Color coding
- Custom icons
- Avatar displays
- Badge indicators
- Progress bars
- Gradient backgrounds

### Accessibility

- Semantic labels
- Tooltip hints
- Clear focus indicators
- Readable fonts
- High contrast options
- Icon + text labels

### Responsive Design

- Adaptive layouts
- Grid-based displays
- Flexible containers
- Scrollable content
- Keyboard-aware forms
- Safe area handling

---

## Data Management

### Data Flow

1. **User Action** → Widget Event
2. **Widget** → Provider Method Call
3. **Provider** → Service API Call
4. **Service** → HTTP Request (Dio)
5. **API** → JSON Response
6. **Service** → Model Deserialization
7. **Provider** → State Update + notifyListeners()
8. **Widget** → UI Rebuild (context.watch)

### Error Handling

**Provider Level:**
- Try-catch blocks
- Error state storage
- User-friendly error messages
- Retry mechanisms

**Service Level:**
- HTTP error handling
- Timeout handling
- Network error detection
- JSON parsing errors

**UI Level:**
- Error state displays
- Retry buttons
- Error messages
- Fallback UI

### Data Validation

**Client-Side:**
- Form field validation
- Type checking
- Range validation
- Format validation

**Server-Side:**
- API response validation
- Status code checking
- Data structure verification

---

## Configuration

### Environment Variables

**API Configuration:**
```bash
# Default
API_BASE_URL=http://192.168.0.102:8000/api

# Custom
flutter run --dart-define=API_BASE_URL=https://your-api.com
```

### Build Configuration

**Dependencies:**
- flutter
- provider (state management)
- dio (HTTP client)
- json_annotation & json_serializable (JSON)
- Material Design

**Dev Dependencies:**
- build_runner (code generation)

### Build Commands

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization
flutter pub run build_runner build

# Run app
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web
```

---

## Development Features

### Code Generation

- JSON serialization via build_runner
- Model classes with fromJson/toJson
- Automatic code generation on changes

### Debugging

- Print statements for development
- Error logging
- Request/response logging
- State change logging

### Project Structure

```
lib/
├── config/          # Environment, theme config
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # API services
├── widgets/         # Reusable widgets
└── main.dart        # App entry point
```

---

## Future Enhancement Possibilities

**Potential Features:**
1. Expense charts and graphs
2. Export to CSV/PDF
3. Receipt scanning
4. Bill reminders
5. Savings goals
6. Investment tracking
7. Multi-currency support
8. Biometric authentication
9. Dark mode toggle
10. Offline mode
11. Data backup/restore
12. Split expenses
13. Shared budgets
14. Custom reports
15. Financial goal tracking

---

## Summary Statistics

- **12 Screens**
- **9 Providers**
- **11 Services**
- **9 Models**
- **6 Custom Widgets**
- **24+ API Endpoints**
- **4 Account Types**
- **12 Dashboard Analytics**
- **9 AI Chat Tools**
- **Material Design 3**

---

## Conclusion

**MCA Finance** is a comprehensive, production-ready personal finance management application with:
- Complete transaction and budget tracking
- Multi-account support
- Advanced analytics dashboard
- AI-powered financial assistant
- Modern Material Design UI
- Robust state management
- RESTful API integration
- Responsive and accessible design

Built with Flutter best practices, clean architecture, and scalable code structure.

---

**Version:** 1.0.0
**Last Updated:** 2025-01-29
**License:** Proprietary
**Platform:** Flutter (iOS, Android, Web)
