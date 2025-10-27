import 'json_serializable.dart';

part 'category.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Category {
  Category({
    required this.id,
    required this.name,
    required this.type,
    this.user,
    this.createdAt,
    this.colorHex,
    this.icon,
  });

  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final String? user;
  final DateTime? createdAt;
  final String? colorHex;
  final String? icon;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      user: json['user']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
      };

  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? user,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
