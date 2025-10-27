import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'category_provider.dart';
import 'transaction_provider.dart';
import 'recurring_transaction_provider.dart';
import 'budget_provider.dart';
import 'account_provider.dart';
import 'chat_provider.dart';

export 'auth_provider.dart';
export 'dashboard_provider.dart';
export 'category_provider.dart';
export 'transaction_provider.dart';
export 'recurring_transaction_provider.dart';
export 'budget_provider.dart';
export 'account_provider.dart';
export 'chat_provider.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
    ChangeNotifierProvider(create: (_) => RecurringTransactionProvider()),
    ChangeNotifierProvider(create: (_) => BudgetProvider()),
    ChangeNotifierProvider(create: (_) => AccountProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ];
}
