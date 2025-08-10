import 'package:cloud_functions/cloud_functions.dart';

class PrivacyService {
  PrivacyService({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFunctions _functions;

  Future<void> requestExport() async {
    final callable = _functions.httpsCallable('requestDataExport');
    await callable.call();
  }

  Future<void> requestDeletion() async {
    final callable = _functions.httpsCallable('requestAccountDeletion');
    await callable.call();
  }
}