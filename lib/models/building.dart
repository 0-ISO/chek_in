import 'dart:convert';

class Building {
  int? id;
  String name;
  int floors;
  int apartmentsPerFloor;
  int? projectId; // Связь с проектом
  List<int> apartmentIds; // Связь с квартирами
  
  Building({
    this.id,
    required this.name,
    required this.floors,
    required this.apartmentsPerFloor,
    this.projectId,
    this.apartmentIds = const [],
  });
  
  int get totalApartments => floors * apartmentsPerFloor;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'floors': floors,
    'apartmentsPerFloor': apartmentsPerFloor,
    'projectId': projectId,
    'apartmentIds': jsonEncode(apartmentIds),
  };
  
  factory Building.fromJson(Map<String, dynamic> json) {
    List<int> apartmentIds = [];
    if (json['apartmentIds'] != null) {
      try {
        apartmentIds = List<int>.from(jsonDecode(json['apartmentIds']));
      } catch (e) {
        apartmentIds = [];
      }
    }
    
    return Building(
      id: json['id'],
      name: json['name'],
      floors: json['floors'],
      apartmentsPerFloor: json['apartmentsPerFloor'],
      projectId: json['projectId'],
      apartmentIds: apartmentIds,
    );
  }
}