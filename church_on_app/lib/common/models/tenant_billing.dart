import 'package:equatable/equatable.dart';

enum TenantPlan { free, pro, enterprise }

class TenantUsage extends Equatable {
  const TenantUsage({
    required this.eventsThisMonth,
    required this.sermonsThisMonth,
    required this.storageMB,
    required this.members,
    required this.messagesThisMonth,
  });
  final int eventsThisMonth;
  final int sermonsThisMonth;
  final int messagesThisMonth;
  final int members;
  final double storageMB;

  Map<String, dynamic> toMap() => {
        'eventsThisMonth': eventsThisMonth,
        'sermonsThisMonth': sermonsThisMonth,
        'messagesThisMonth': messagesThisMonth,
        'members': members,
        'storageMB': storageMB,
      };

  factory TenantUsage.fromMap(Map<String, dynamic>? map) => TenantUsage(
        eventsThisMonth: (map?['eventsThisMonth'] as num?)?.toInt() ?? 0,
        sermonsThisMonth: (map?['sermonsThisMonth'] as num?)?.toInt() ?? 0,
        messagesThisMonth: (map?['messagesThisMonth'] as num?)?.toInt() ?? 0,
        members: (map?['members'] as num?)?.toInt() ?? 0,
        storageMB: (map?['storageMB'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [eventsThisMonth, sermonsThisMonth, messagesThisMonth, members, storageMB];
}

class TenantBilling extends Equatable {
  const TenantBilling({
    required this.plan,
    required this.usage,
    required this.graceUntil,
    required this.status,
  });
  final TenantPlan plan;
  final TenantUsage usage;
  final DateTime? graceUntil; // if past due, allow grace period
  final String status; // active|past_due|canceled

  Map<String, dynamic> toMap() => {
        'plan': plan.name,
        'usage': usage.toMap(),
        'graceUntil': graceUntil?.toUtc().toIso8601String(),
        'status': status,
      };

  factory TenantBilling.fromMap(Map<String, dynamic>? map) => TenantBilling(
        plan: TenantPlan.values.firstWhere((p) => p.name == (map?['plan'] as String? ?? 'free'), orElse: () => TenantPlan.free),
        usage: TenantUsage.fromMap(map?['usage'] as Map<String, dynamic>?),
        graceUntil: (map?['graceUntil'] as String?) != null ? DateTime.tryParse(map!['graceUntil'] as String) : null,
        status: (map?['status'] as String?) ?? 'active',
      );

  @override
  List<Object?> get props => [plan, usage, graceUntil, status];
}