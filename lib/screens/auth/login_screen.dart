import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../utils/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegistering = false;
  final _nameController = TextEditingController();
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'admin@example.com';
    _passwordController.text = 'password';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppAnimations.fadeIn(
      duration: const Duration(milliseconds: 800),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5EFE6), Color(0xFFDFD0BB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Логотип
                  AppAnimations.slideInFromTop(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE5BD77), Color(0xFFCC7952)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.business,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Заголовок
                  AppAnimations.fadeSlideIn(
                    child: Text(
                      _isRegistering ? 'Регистрация' : 'Building Manager',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF474344),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  AppAnimations.fadeSlideIn(
                    offset: const Offset(0, 10),
                    child: Text(
                      _isRegistering 
                          ? 'Создайте новый аккаунт'
                          : 'Управление строительными объектами',
                      style: const TextStyle(
                        color: Color(0xFF474344),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Форма
                  AppAnimations.fadeSlideIn(
                    offset: const Offset(0, 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 30,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_isRegistering) ...[
                            AppAnimations.fadeIn(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Имя и фамилия',
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                          
                          AppAnimations.fadeIn(
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          AppAnimations.fadeIn(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Пароль',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          if (_isRegistering) ...[
                            const SizedBox(height: 20),
                            
                            AppAnimations.fadeIn(
                              child: DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Роль',
                                  prefixIcon: Icon(Icons.work),
                                ),
                                items: UserRole.values.map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role.name,
                                    child: Text(_getRoleName(role)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                },
                              ),
                            ),
                          ],
                          
                          if (authProvider.error != null) ...[
                            const SizedBox(height: 16),
                            AppAnimations.fadeIn(
                              child: Text(
                                authProvider.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          AppAnimations.scaleIn(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_isRegistering) {
                                          // Регистрация
                                          if (_nameController.text.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Введите имя и фамилию'),
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          if (_selectedRole == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Выберите роль'),
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          final success = await authProvider.register(
                                            _emailController.text.trim(),
                                            _nameController.text.trim(),
                                            _selectedRole!,
                                          );
                                          
                                          if (!success) {
                                            // Ошибка уже показана
                                          }
                                        } else {
                                          // Вход
                                          final success = await authProvider.signIn(
                                            _emailController.text.trim(),
                                            _passwordController.text,
                                          );
                                          
                                          if (!success) {
                                            // Ошибка уже показана
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCC7952),
                                ),
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(_isRegistering ? 'Зарегистрироваться' : 'Войти'),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          AppAnimations.fadeIn(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isRegistering = !_isRegistering;
                                  _selectedRole = null;
                                  _nameController.clear();
                                });
                              },
                              child: Text(
                                _isRegistering 
                                  ? 'Уже есть аккаунт? Войти'
                                  : 'Нет аккаунта? Зарегистрироваться',
                                style: const TextStyle(color: Color(0xFFCC7952)),
                              ),
                            ),
                          ),
                          
                          if (!_isRegistering) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            AppAnimations.fadeIn(
                              child: const Text('Демо аккаунты:'),
                            ),
                            const SizedBox(height: 12),
                            
                            Wrap(
                              spacing: 8,
                              children: [
                                AppAnimations.scaleIn(
                                  child: ActionChip(
                                    label: const Text('Администратор'),
                                    onPressed: () {
                                      _emailController.text = 'admin@example.com';
                                      _passwordController.text = 'password';
                                    },
                                  ),
                                ),
                                AppAnimations.scaleIn(
                                  child: ActionChip(
                                    label: const Text('Работник'),
                                    onPressed: () {
                                      _emailController.text = 'worker@example.com';
                                      _passwordController.text = 'password';
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Администратор';
      case UserRole.manager:
        return 'Менеджер';
      case UserRole.supervisor:
        return 'Начальник';
      case UserRole.worker:
        return 'Работник';
      case UserRole.viewer:
        return 'Наблюдатель';
    }
  }
}