import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  // Метод для входа
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final user = await DatabaseService.getUser(email);
      
      if (user == null) {
        _error = 'Пользователь не найден';
        return false;
      }
      
      // Демо: пароль "password"
      if (password != 'password') {
        _error = 'Неверный пароль';
        return false;
      }
      
      _currentUser = user;
      return true;
    } catch (e) {
      _error = 'Ошибка входа: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для выхода
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }
  
  // Метод для регистрации
  Future<bool> register(String email, String displayName, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Проверяем, существует ли пользователь
      final existingUser = await DatabaseService.getUser(email);
      if (existingUser != null) {
        _error = 'Пользователь с таким email уже существует';
        return false;
      }
      
      // Создаем нового пользователя
      final newUser = User(
        email: email,
        displayName: displayName,
        role: UserRole.values.firstWhere(
          (r) => r.name == role,
          orElse: () => UserRole.worker,
        ),
      );
      
      await DatabaseService.saveUser(newUser);
      _currentUser = newUser;
      return true;
    } catch (e) {
      _error = 'Ошибка регистрации: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Метод для проверки авторизации (может пригодиться)
  Future<bool> checkAuth() async {
    // Здесь можно добавить проверку токена или других данных
    return _currentUser != null;
  }
}