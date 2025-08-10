import 'package:cloud_firestore/cloud_firestore.dart';

class PageResult<T> {
  PageResult({required this.items, required this.lastDoc, required this.hasMore});
  final List<T> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
}