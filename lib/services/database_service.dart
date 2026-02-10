// lib/services/database_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/building.dart';
import '../models/apartment.dart';
import 'dart:convert';

class DatabaseService {
  static SharedPreferences? _prefs;
  
  static Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  // ============ USER METHODS ============
  
  static Future<void> saveUser(User user) async {
    final p = await prefs;
    final users = await getAllUsers();
    
    // Если пользователь уже существует - обновляем
    final existingIndex = users.indexWhere((u) => u.email == user.email);
    if (existingIndex != -1) {
      user.id ??= users[existingIndex].id;
      users[existingIndex] = user;
    } else {
      // Или добавляем нового
      user.id ??= DateTime.now().millisecondsSinceEpoch;
      users.add(user);
    }
    
    final jsonList = users.map((u) => u.toJson()).toList();
    await p.setString('users', json.encode(jsonList));
  }
  
  static Future<User?> getUser(String email) async {
    final users = await getAllUsers();
    return users.firstWhere((user) => user.email == email);
  }
  
  static Future<List<User>> getAllUsers() async {
    final p = await prefs;
    final jsonString = p.getString('users') ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => User.fromJson(json)).toList();
  }
  
  // ============ PROJECT METHODS ============
  
  static Future<void> saveProject(Project project) async {
    final p = await prefs;
    final projects = await getAllProjects();
    
    if (project.id == null) {
      project.id = DateTime.now().millisecondsSinceEpoch;
      projects.add(project);
    } else {
      final index = projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        projects[index] = project;
      } else {
        projects.add(project);
      }
    }
    
    final jsonList = projects.map((p) => p.toJson()).toList();
    await p.setString('projects', json.encode(jsonList));
  }
  
  static Future<List<Project>> getAllProjects() async {
    final p = await prefs;
    final jsonString = p.getString('projects') ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Project.fromJson(json)).toList();
  }
  
  // ============ BUILDING METHODS ============
  
  static Future<void> saveBuilding(Building building) async {
    final p = await prefs;
    final buildings = await getAllBuildings();
    
    if (building.id == null) {
      building.id = DateTime.now().millisecondsSinceEpoch;
      buildings.add(building);
    } else {
      final index = buildings.indexWhere((b) => b.id == building.id);
      if (index != -1) {
        buildings[index] = building;
      } else {
        buildings.add(building);
      }
    }
    
    final jsonList = buildings.map((b) => b.toJson()).toList();
    await p.setString('buildings', json.encode(jsonList));
  }
  
  static Future<List<Building>> getAllBuildings() async {
    final p = await prefs;
    final jsonString = p.getString('buildings') ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Building.fromJson(json)).toList();
  }
  
  // ============ APARTMENT METHODS ============
  
  static Future<void> saveApartment(Apartment apartment) async {
    final p = await prefs;
    final apartments = await getAllApartments();
    
    if (apartment.id == null) {
      apartment.id = DateTime.now().millisecondsSinceEpoch;
      apartments.add(apartment);
    } else {
      final index = apartments.indexWhere((a) => a.id == apartment.id);
      if (index != -1) {
        apartments[index] = apartment;
      } else {
        apartments.add(apartment);
      }
    }
    
    final jsonList = apartments.map((a) => a.toJson()).toList();
    await p.setString('apartments', json.encode(jsonList));
  }
  
  static Future<List<Apartment>> getAllApartments() async {
    final p = await prefs;
    final jsonString = p.getString('apartments') ?? '[]';
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Apartment.fromJson(json)).toList();
  }

// ============ RELATIONSHIP METHODS ============

// Добавить здание к проекту
static Future<void> addBuildingToProject(int projectId, int buildingId) async {
  final projects = await getAllProjects();
  final project = projects.firstWhere((p) => p.id == projectId);
  
  if (!project.buildingIds.contains(buildingId)) {
    project.buildingIds.add(buildingId);
    await saveProject(project);
  }
}

// Удалить здание из проекта
static Future<void> removeBuildingFromProject(int projectId, int buildingId) async {
  final projects = await getAllProjects();
  final project = projects.firstWhere((p) => p.id == projectId);
  
  project.buildingIds.remove(buildingId);
  await saveProject(project);
}

// Добавить квартиру к зданию
static Future<void> addApartmentToBuilding(int buildingId, int apartmentId) async {
  final buildings = await getAllBuildings();
  final building = buildings.firstWhere((b) => b.id == buildingId);
  
  if (!building.apartmentIds.contains(apartmentId)) {
    building.apartmentIds.add(apartmentId);
    await saveBuilding(building);
  }
}

// Удалить квартиру из здания
static Future<void> removeApartmentFromBuilding(int buildingId, int apartmentId) async {
  final buildings = await getAllBuildings();
  final building = buildings.firstWhere((b) => b.id == buildingId);
  
  building.apartmentIds.remove(apartmentId);
  await saveBuilding(building);
}

// Получить здания проекта
static Future<List<Building>> getProjectBuildings(int projectId) async {
  final allBuildings = await getAllBuildings();
  return allBuildings.where((b) => b.projectId == projectId).toList();
}

// Получить квартиры здания
static Future<List<Apartment>> getBuildingApartments(int buildingId) async {
  final allApartments = await getAllApartments();
  return allApartments.where((a) => a.buildingId == buildingId).toList();
}

// Обновить демо данные для тестирования связей
static Future<void> createDemoData() async {
  final users = await getAllUsers();
  if (users.isNotEmpty) return;
  
  // Демо пользователи
  final admin = User(
    email: 'admin@example.com',
    displayName: 'Администратор',
    role: UserRole.admin,
  );
  
  final worker = User(
    email: 'worker@example.com',
    displayName: 'Иван Петров',
    role: UserRole.worker,
  );
  
  await saveUser(admin);
  await saveUser(worker);
  
  // Демо проекты
  final project1 = Project(
    name: 'ЖК "Солнечный"',
    description: 'Многоквартирный жилой комплекс',
    budget: 10000000,
    spent: 3500000,
    city: 'Москва',
    status: ProjectStatus.inProgress,
    deadline: DateTime.now().add(const Duration(days: 60)),
  );
  
  final project2 = Project(
    name: 'Офисный комплекс',
    description: 'Бизнес-центр класса А',
    budget: 5000000,
    spent: 1200000,
    city: 'Санкт-Петербург',
    status: ProjectStatus.planning,
  );
  
  await saveProject(project1);
  await saveProject(project2);
  
  // Демо здания для проекта 1
  final building1 = Building(
    name: 'Корпус А',
    floors: 10,
    apartmentsPerFloor: 4,
    projectId: project1.id,
  );
  
  final building2 = Building(
    name: 'Корпус Б',
    floors: 8,
    apartmentsPerFloor: 6,
    projectId: project1.id,
  );
  
  // Демо здание для проекта 2
  final building3 = Building(
    name: 'Башня А',
    floors: 15,
    apartmentsPerFloor: 8,
    projectId: project2.id,
  );
  
  await saveBuilding(building1);
  await saveBuilding(building2);
  await saveBuilding(building3);
  
  // Добавляем здания к проектам
  await addBuildingToProject(project1.id!, building1.id!);
  await addBuildingToProject(project1.id!, building2.id!);
  await addBuildingToProject(project2.id!, building3.id!);
  
  // Демо квартиры для зданий
  for (int floor = 1; floor <= building1.floors; floor++) {
    for (int i = 1; i <= building1.apartmentsPerFloor; i++) {
      final apartment = Apartment(
        number: (floor * 100) + i,
        floor: floor,
        buildingId: building1.id,
      );
      await saveApartment(apartment);
      await addApartmentToBuilding(building1.id!, apartment.id!);
    }
  }
  
  for (int floor = 1; floor <= building2.floors; floor++) {
    for (int i = 1; i <= building2.apartmentsPerFloor; i++) {
      final apartment = Apartment(
        number: (floor * 100) + i + 1000,
        floor: floor,
        buildingId: building2.id,
      );
      await saveApartment(apartment);
      await addApartmentToBuilding(building2.id!, apartment.id!);
    }
  }
  
  print('✅ Демо данные с связями созданы');
}
  // ============ DELETE METHODS ============

  static Future<void> deleteProject(int projectId) async {
    final p = await prefs;
    final projects = await getAllProjects();
    final updatedProjects = projects.where((p) => p.id != projectId).toList();
    
    final jsonList = updatedProjects.map((p) => p.toJson()).toList();
    await p.setString('projects', json.encode(jsonList));
  }

  static Future<void> deleteBuilding(int buildingId) async {
    final p = await prefs;
    final buildings = await getAllBuildings();
    final updatedBuildings = buildings.where((b) => b.id != buildingId).toList();
    
    final jsonList = updatedBuildings.map((b) => b.toJson()).toList();
    await p.setString('buildings', json.encode(jsonList));
  }

  static Future<void> deleteApartment(int apartmentId) async {
    final p = await prefs;
    final apartments = await getAllApartments();
    final updatedApartments = apartments.where((a) => a.id != apartmentId).toList();
    
    final jsonList = updatedApartments.map((a) => a.toJson()).toList();
    await p.setString('apartments', json.encode(jsonList));
  }

  // ============ UPDATE METHODS ============

  static Future<void> updateProject(Project project) async {
    await saveProject(project); // saveProject уже обрабатывает обновление
  }

  static Future<void> updateBuilding(Building building) async {
    await saveBuilding(building);
  }

  static Future<void> updateApartment(Apartment apartment) async {
    await saveApartment(apartment);
  }
}
