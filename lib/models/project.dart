import 'dart:convert';

enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled
}

class Project {
  int? id;
  String name;
  String? description;
  ProjectStatus status;
  double? budget;
  double? spent;
  String? city;
  DateTime? deadline;
  List<int> buildingIds; // Связь со зданиями
  
  Project({
    this.id,
    required this.name,
    this.description,
    this.status = ProjectStatus.planning,
    this.budget,
    this.spent,
    this.city,
    this.deadline,
    this.buildingIds = const [],
  });
  
  double get progress {
    if (budget == null || budget == 0) return 0;
    if (spent == null) return 0;
    return (spent! / budget!).clamp(0.0, 1.0);
  }
  
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'status': status.name,
    'budget': budget,
    'spent': spent,
    'city': city,
    'deadline': deadline?.toIso8601String(),
    'buildingIds': jsonEncode(buildingIds), // Сохраняем как JSON
  };
  
  factory Project.fromJson(Map<String, dynamic> json) {
    List<int> buildingIds = [];
    if (json['buildingIds'] != null) {
      try {
        buildingIds = List<int>.from(jsonDecode(json['buildingIds']));
      } catch (e) {
        buildingIds = [];
      }
    }
    
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      budget: json['budget']?.toDouble(),
      spent: json['spent']?.toDouble(),
      city: json['city'],
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline']) 
          : null,
      buildingIds: buildingIds,
    );
  }
}