import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class MediaDownloadService {
  MediaDownloadService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<File> _targetFile(String url, {String? filename}) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = filename ?? url.split('/').last.split('?').first;
    final file = File('${dir.path}/media/$name');
    if (!await file.parent.exists()) await file.parent.create(recursive: true);
    return file;
  }

  Future<File?> downloadAudio(String url, {String? filename, void Function(int, int)? onProgress}) async {
    try {
      final file = await _targetFile(url, filename: filename);
      await _dio.download(url, file.path, onReceiveProgress: onProgress);
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isDownloaded(String url, {String? filename}) async {
    final file = await _targetFile(url, filename: filename);
    return file.existsSync();
  }

  Future<void> deleteDownloaded(String url, {String? filename}) async {
    final file = await _targetFile(url, filename: filename);
    if (await file.exists()) await file.delete();
  }
}