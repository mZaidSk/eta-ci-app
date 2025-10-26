import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/category.dart';
// import '../services/crud_service.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider();

  // final CrudService<Category> _service;

  bool _loading = false;
  List<Category> _items = <Category>[];
  String? _error;

  bool get isLoading => _loading;
  List<Category> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Mock categories
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _items = [
        Category(id: 'c1', name: 'Food', type: 'expense', colorHex: '#FF7043'),
        Category(id: 'c2', name: 'Transport', type: 'expense', colorHex: '#29B6F6'),
        Category(id: 'c3', name: 'Shopping', type: 'expense', colorHex: '#AB47BC'),
        Category(id: 'c4', name: 'Salary', type: 'income', colorHex: '#66BB6A'),
        Category(id: 'c5', name: 'Freelance', type: 'income', colorHex: '#42A5F5'),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Category category) async {
    // Mock create locally
    _items = List<Category>.from(_items)..add(category);
    notifyListeners();
  }

  Future<void> update(Category category) async {
    final idx = _items.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _items = List<Category>.from(_items)..[idx] = category;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _items = _items.where((c) => c.id != id).toList();
    notifyListeners();
  }
}

