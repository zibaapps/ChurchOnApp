import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import '../services/reports_service.dart';
import 'auth_providers.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) => ReportsService());

final reportsStreamProvider = StreamProvider.family<List<ChurchReport>, ReportType?>((ref, type) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId == null) return const Stream.empty();
  return ref.watch(reportsServiceProvider).streamReports(churchId, type: type);
});