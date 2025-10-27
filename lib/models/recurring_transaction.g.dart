// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTransaction _$RecurringTransactionFromJson(
        Map<String, dynamic> json) =>
    RecurringTransaction(
      id: json['id'] as String?,
      account: (json['account'] as num).toInt(),
      category: (json['category'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RecurringTransactionToJson(
        RecurringTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account': instance.account,
      'category': instance.category,
      'amount': instance.amount,
      'description': instance.description,
      'frequency': instance.frequency,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };
