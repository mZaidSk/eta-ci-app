import 'crud_service.dart';
import '../models/category.dart';

class CategoryService extends CrudService<Category> {
  CategoryService() : super(endpoint: '/categories/');

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final response = await list();
    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get a single category by ID
  Future<Category?> getCategory(String id) async {
    final response = await getById(id);
    if (response.data != null && response.data['data'] != null) {
      return Category.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Create a new category
  Future<Category?> createCategory({
    required String name,
    required String type,
  }) async {
    final response = await create({
      'name': name,
      'type': type,
    });

    if (response.data != null && response.data['data'] != null) {
      return Category.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Update an existing category
  Future<Category?> updateCategory({
    required String id,
    required String name,
    required String type,
  }) async {
    final response = await update(id, {
      'name': name,
      'type': type,
    });

    if (response.data != null && response.data['data'] != null) {
      return Category.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      await delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
