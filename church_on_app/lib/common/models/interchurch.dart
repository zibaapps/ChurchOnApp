import 'package:equatable/equatable.dart';

class InterchurchEvent extends Equatable {
  const InterchurchEvent({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    this.participatingChurchIds = const <String>[],
    this.description,
  });
  final String id;
  final String name;
  final DateTime date;
  final String? location;
  final List<String> participatingChurchIds;
  final String? description;
  Map<String, dynamic> toMap() => {
        'name': name,
        'date': date.toUtc().toIso8601String(),
        'location': location,
        'participatingChurchIds': participatingChurchIds,
        'description': description,
      };
  factory InterchurchEvent.fromDoc(String id, Map<String, dynamic> map) => InterchurchEvent(
        id: id,
        name: map['name'] as String,
        date: DateTime.tryParse(map['date'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        location: map['location'] as String?,
        participatingChurchIds: (map['participatingChurchIds'] as List?)?.cast<String>() ?? const <String>[],
        description: map['description'] as String?,
      );
  @override
  List<Object?> get props => [id, name, date];
}

class InterchurchProject extends Equatable {
  const InterchurchProject({
    required this.id,
    required this.title,
    this.description,
    this.totalGiving = 0,
    this.participatingChurchIds = const <String>[],
  });
  final String id;
  final String title;
  final String? description;
  final double totalGiving;
  final List<String> participatingChurchIds;
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'totalGiving': totalGiving,
        'participatingChurchIds': participatingChurchIds,
      };
  factory InterchurchProject.fromDoc(String id, Map<String, dynamic> map) => InterchurchProject(
        id: id,
        title: map['title'] as String,
        description: map['description'] as String?,
        totalGiving: (map['totalGiving'] as num?)?.toDouble() ?? 0,
        participatingChurchIds: (map['participatingChurchIds'] as List?)?.cast<String>() ?? const <String>[],
      );
  @override
  List<Object?> get props => [id, title, totalGiving];
}

class YearProgram extends Equatable {
  const YearProgram({
    required this.id,
    required this.churchId,
    required this.year,
    required this.items,
  });
  final String id;
  final String churchId;
  final int year;
  final List<Map<String, dynamic>> items; // [{date,title,desc}]
  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'year': year,
        'items': items,
      };
  factory YearProgram.fromDoc(String id, Map<String, dynamic> map) => YearProgram(
        id: id,
        churchId: map['churchId'] as String,
        year: (map['year'] as num).toInt(),
        items: ((map['items'] as List?) ?? const <dynamic>[]).cast<Map<String, dynamic>>(),
      );
  @override
  List<Object?> get props => [id, churchId, year];
}