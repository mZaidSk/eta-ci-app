import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/account.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  AccountProvider() : _service = AccountService();

  final AccountService _service;
  bool _loading = false;
  List<Account> _items = <Account>[];
  String? _error;

  bool get isLoading => _loading;
  List<Account> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      debugPrint('📋 Fetching accounts from API...');
      _items = await _service.getAccounts();
      debugPrint('✅ Fetched ${_items.length} accounts');
    } on DioException catch (e) {
      debugPrint('❌ Error fetching accounts: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to fetch accounts';
    } catch (e) {
      debugPrint('❌ Unexpected error fetching accounts: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Account account) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('➕ Creating account: ${account.name}');
      final newAccount = await _service.createAccount(
        name: account.name,
        accountType: account.accountType,
        balance: account.balance,
      );

      if (newAccount != null) {
        _items = List<Account>.from(_items)..add(newAccount);
        debugPrint('✅ Account created: ${newAccount.id}');
        _error = null;
      } else {
        _error = 'Failed to create account';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating account: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to create account';
    } catch (e) {
      debugPrint('❌ Unexpected error creating account: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Account account) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('✏️ Updating account: ${account.id}');
      final updatedAccount = await _service.updateAccount(
        id: account.id,
        name: account.name,
        accountType: account.accountType,
        balance: account.balance,
      );

      if (updatedAccount != null) {
        final idx = _items.indexWhere((c) => c.id == account.id);
        if (idx != -1) {
          _items = List<Account>.from(_items)..[idx] = updatedAccount;
          debugPrint('✅ Account updated: ${updatedAccount.id}');
          _error = null;
        } else {
          _error = 'Account not found';
        }
      } else {
        _error = 'Failed to update account';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating account: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to update account';
    } catch (e) {
      debugPrint('❌ Unexpected error updating account: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('🗑️ Deleting account: $id');
      final success = await _service.deleteAccount(id);

      if (success) {
        _items = _items.where((c) => c.id != id).toList();
        debugPrint('✅ Account deleted: $id');
        _error = null;
      } else {
        _error = 'Failed to delete account';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error deleting account: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to delete account';
    } catch (e) {
      debugPrint('❌ Unexpected error deleting account: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get account by ID
  Account? getById(String id) {
    try {
      return _items.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate total balance
  double get totalBalance {
    return _items.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  // Get accounts by type
  List<Account> getByType(String accountType) {
    return _items.where((account) => account.accountType == accountType).toList();
  }
}
