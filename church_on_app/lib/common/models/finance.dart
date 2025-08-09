import 'package:equatable/equatable.dart';

class ContributionPool extends Equatable {
  const ContributionPool({
    required this.id,
    required this.churchId,
    required this.title,
    this.description,
    this.targetAmount = 0,
    this.currentAmount = 0,
  });
  final String id;
  final String churchId;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'description': description,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
      };

  factory ContributionPool.fromDoc(String id, Map<String, dynamic> map) => ContributionPool(
        id: id,
        churchId: map['churchId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0,
        currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [id, churchId, title, currentAmount, targetAmount];
}

class TitheRecord extends Equatable {
  const TitheRecord({
    required this.id,
    required this.churchId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    this.note,
  });
  final String id;
  final String churchId;
  final String userId;
  final double amount;
  final DateTime createdAt;
  final String? note;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'userId': userId,
        'amount': amount,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'note': note,
      };

  factory TitheRecord.fromDoc(String id, Map<String, dynamic> map) => TitheRecord(
        id: id,
        churchId: map['churchId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        note: map['note'] as String?,
      );

  @override
  List<Object?> get props => [id, churchId, userId, amount, createdAt];
}