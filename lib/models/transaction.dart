import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes,
  });

  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? notes;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}