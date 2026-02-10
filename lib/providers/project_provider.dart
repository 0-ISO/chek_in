import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/project.dart';
import '../models/building.dart';
import '../models/apartment.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Building> _buildings = [];
  List<Apartment> _apartments = [];
  bool _isLoading = false;
  
  List<Project> get projects => _projects;
  List<Building> get buildings => _buildings;
  List<Apartment> get apartments => _apartments;
  bool get isLoading => _isLoading;
  
  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _projects = await DatabaseService.getAllProjects();
      _buildings = await DatabaseService.getAllBuildings();
      _apartments = await DatabaseService.getAllApartments();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Project CRUD
  Future<void> addProject(Project project) async {
    await DatabaseService.saveProject(project);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> updateProject(Project project) async {
    await DatabaseService.saveProject(project);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> deleteProject(int projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    
    // Также удаляем из базы данных
    final projects = await DatabaseService.getAllProjects();
    final updatedProjects = projects.where((p) => p.id != projectId).toList();
    // Здесь нужно обновить базу данных
    // Пока просто обновляем локальный список
    notifyListeners();
  }
  
  // Building CRUD
  Future<void> addBuilding(Building building) async {
    await DatabaseService.saveBuilding(building);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> updateBuilding(Building building) async {
    await DatabaseService.saveBuilding(building);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> deleteBuilding(int buildingId) async {
    _buildings.removeWhere((b) => b.id == buildingId);
    
    // Также удаляем все квартиры в этом здании
    _apartments.removeWhere((a) {
      // Здесь должна быть логика связи квартиры со зданием
      // Пока просто удаляем все квартиры
      return true; // Временная заглушка
    });
    
    notifyListeners();
  }
  
  // Apartment CRUD
  Future<void> addApartment(Apartment apartment) async {
    await DatabaseService.saveApartment(apartment);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> updateApartment(Apartment apartment) async {
    await DatabaseService.saveApartment(apartment);
    await loadProjects(); // Перезагружаем данные
  }
  
  Future<void> deleteApartment(int apartmentId) async {
    _apartments.removeWhere((a) => a.id == apartmentId);
    notifyListeners();
  }
  
  // Вспомогательные методы - ИСПРАВЛЕНЫ
  Project? getProjectById(int? id) {
    if (id == null) return null;
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Building? getBuildingById(int? id) {
    if (id == null) return null;
    try {
      return _buildings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Apartment? getApartmentById(int? id) {
    if (id == null) return null;
    try {
      return _apartments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Метод для получения проектов по статусу
  List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((p) => p.status == status).toList();
  }
  
  // Метод для получения общей статистики
  Map<String, dynamic> getStatistics() {
    return {
      'totalProjects': _projects.length,
      'totalBuildings': _buildings.length,
      'totalApartments': _apartments.length,
      'completedProjects': _projects.where((p) => p.status == ProjectStatus.completed).length,
      'activeProjects': _projects.where((p) => p.status == ProjectStatus.inProgress).length,
      'totalBudget': _projects.fold(0.0, (sum, p) => sum + (p.budget ?? 0)),
      'totalSpent': _projects.fold(0.0, (sum, p) => sum + (p.spent ?? 0)),
    };
  }
  
  // Метод для поиска проектов
  List<Project> searchProjects(String query) {
    if (query.isEmpty) return _projects;
    
    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      return project.name.toLowerCase().contains(lowercaseQuery) ||
             (project.description?.toLowerCase() ?? '').contains(lowercaseQuery) ||
             (project.city?.toLowerCase() ?? '').contains(lowercaseQuery);
    }).toList();
  }
}