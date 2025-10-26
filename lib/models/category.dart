import 'json_serializable.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  Category({
    required this.id,
    required this.name,
    required this.type,
    this.colorHex,
    this.icon,
  });

  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final String? colorHex;
  final String? icon;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
