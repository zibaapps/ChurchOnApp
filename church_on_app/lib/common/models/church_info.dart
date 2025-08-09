import 'package:equatable/equatable.dart';

class ChurchInfo extends Equatable {
  const ChurchInfo({required this.id, required this.name, this.iconUrl});
  final String id;
  final String name;
  final String? iconUrl;

  factory ChurchInfo.fromDoc(String id, Map<String, dynamic> data) => ChurchInfo(
        id: id,
        name: data['name'] as String? ?? 'Unnamed Church',
        iconUrl: data['iconUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, name, iconUrl];
}