import 'package:cloud_functions/cloud_functions.dart';

class ThumbnailService {
  ThumbnailService({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFunctions _functions;

  Future<String?> generateForDoc({required String churchId, required String collection, required String docId, required String title}) async {
    try {
      final callable = _functions.httpsCallable('generateThumbnail');
      final res = await callable.call({
        'churchId': churchId,
        'collection': collection,
        'docId': docId,
        'title': title,
      });
      final data = (res.data as Map?)?.map((k, v) => MapEntry(k.toString(), v));
      return data?['url'] as String?;
    } catch (_) {
      return null;
    }
  }
}