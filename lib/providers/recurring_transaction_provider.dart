import 'package:flutter/foundation.dart';
import '../models/recurring_transaction.dart';
import '../services/recurring_transaction_service.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final RecurringTransactionService _service = RecurringTransactionService();

  bool _loading = false;
  List<RecurringTransaction> _items = [];
  String? _error;

  bool get isLoading => _loading;
  List<RecurringTransaction> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.list(query: query);
      final data = response.data;

      print('Recurring Transaction API Response: $data');
      print('Response type: ${data.runtimeType}');

      if (data is List) {
        // Direct list response
        _items = data.map((json) {
          print('Parsing recurring transaction: $json');
          return RecurringTransaction.fromJson(json as Map<String, dynamic>);
        }).toList();
        print('Successfully parsed ${_items.length} recurring transactions');
      } else if (data is Map) {
        // Check for custom wrapper with "data" key
        if (data['data'] is List) {
          final dataList = data['data'] as List;
          _items = dataList.map((json) {
            print('Parsing recurring transaction: $json');
            return RecurringTransaction.fromJson(json as Map<String, dynamic>);
          }).toList();
          print('Successfully parsed ${_items.length} recurring transactions from wrapped response');
        }
        // Check for Django REST Framework pagination with "results" key
        else if (data['results'] is List) {
          final results = data['results'] as List;
          _items = results.map((json) {
            print('Parsing recurring transaction: $json');
            return RecurringTransaction.fromJson(json as Map<String, dynamic>);
          }).toList();
          print('Successfully parsed ${_items.length} recurring transactions from paginated response');
        } else {
          print('Unexpected data format: $data');
          _items = [];
        }
      } else {
        print('Unexpected data format: $data');
        _items = [];
      }
    } catch (e, stackTrace) {
      print('Error fetching recurring transactions: $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
      _items = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create(RecurringTransaction transaction) async {
    try {
      final response = await _service.create(transaction.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetch();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(String id, RecurringTransaction transaction) async {
    try {
      final response = await _service.update(id, transaction.toJson());
      if (response.statusCode == 200) {
        await fetch();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      final response = await _service.delete(id);
      if (response.statusCode == 204 || response.statusCode == 200) {
        _items.removeWhere((item) => item.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<RecurringTransaction> getByFrequency(String frequency) {
    return _items
        .where((t) => t.frequency.toLowerCase() == frequency.toLowerCase())
        .toList();
  }

  double getTotalAmount() {
    return _items.fold(0.0, (sum, t) => sum + t.amount);
  }
}
