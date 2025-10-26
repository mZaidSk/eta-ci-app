import 'package:flutter/foundation.dart';

// import '../services/crud_service.dart';

class TransactionItem {
  TransactionItem({required this.id, required this.amount, required this.categoryId, required this.date});
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
      };
}

class TransactionProvider extends ChangeNotifier {
  TransactionProvider();

  // final CrudService<TransactionItem> _service;

  bool _loading = false;
  List<TransactionItem> _items = <TransactionItem>[];
  String? _error;

  bool get isLoading => _loading;
  List<TransactionItem> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Mock transactions
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _items = [
        TransactionItem(id: 't1', amount: -12.45, categoryId: 'Food', date: DateTime.now().subtract(const Duration(days: 0))),
        TransactionItem(id: 't2', amount: -42.10, categoryId: 'Transport', date: DateTime.now().subtract(const Duration(days: 1))),
        TransactionItem(id: 't3', amount:  500.00, categoryId: 'Salary', date: DateTime.now().subtract(const Duration(days: 2))),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

