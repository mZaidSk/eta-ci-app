import 'crud_service.dart';
import '../models/account.dart';

class AccountService extends CrudService<Account> {
  AccountService() : super(endpoint: '/accounts/');

  /// Get all accounts
  Future<List<Account>> getAccounts() async {
    final response = await list();
    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => Account.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get a single account by ID
  Future<Account?> getAccount(String id) async {
    final response = await getById(id);
    if (response.data != null && response.data['data'] != null) {
      return Account.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Create a new account
  Future<Account?> createAccount({
    required String name,
    required String accountType,
    required double balance,
  }) async {
    final response = await create({
      'name': name,
      'account_type': accountType,
      'balance': balance,
    });

    if (response.data != null && response.data['data'] != null) {
      return Account.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Update an existing account
  Future<Account?> updateAccount({
    required String id,
    required String name,
    required String accountType,
    required double balance,
  }) async {
    final response = await update(id, {
      'name': name,
      'account_type': accountType,
      'balance': balance,
    });

    if (response.data != null && response.data['data'] != null) {
      return Account.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Delete an account
  Future<bool> deleteAccount(String id) async {
    try {
      await delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
