import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/church_info.dart';
import '../services/church_directory_service.dart';

final churchDirectoryServiceProvider = Provider<ChurchDirectoryService>((ref) => ChurchDirectoryService());

final churchListProvider = StreamProvider<List<ChurchInfo>>((ref) {
  return ref.watch(churchDirectoryServiceProvider).streamChurches();
});