import 'package:flutter/foundation.dart';

import '../models/account.dart';

class AccountProvider extends ChangeNotifier {
  AccountProvider();

  // TODO: Add real service integration when backend is ready
  // final CrudService<Account> _service;

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
      // Mock accounts
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _items = [
        Account(
          id: 'acc1',
          name: 'Main Checking Account',
          accountType: 'checking',
          balance: 2500.75,
        ),
        Account(
          id: 'acc2',
          name: 'Emergency Savings',
          accountType: 'savings',
          balance: 15000.00,
        ),
        Account(
          id: 'acc3',
          name: 'Credit Card',
          accountType: 'credit',
          balance: -1250.50,
        ),
      ];
    } catch (e) {
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
      
      // Mock API delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      // Mock create locally
      _items = List<Account>.from(_items)..add(account);
      _error = null;
    } catch (e) {
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
      
      // Mock API delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final idx = _items.indexWhere((c) => c.id == account.id);
      if (idx != -1) {
        _items = List<Account>.from(_items)..[idx] = account;
        _error = null;
      } else {
        _error = 'Account not found';
      }
    } catch (e) {
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
      
      // Mock API delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      _items = _items.where((c) => c.id != id).toList();
      _error = null;
    } catch (e) {
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
