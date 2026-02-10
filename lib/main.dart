import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация демо данных
  await DatabaseService.createDemoData();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Building Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFCC7952),
            primary: const Color(0xFFCC7952),
            secondary: const Color(0xFFE5BD77),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5EFE6),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            centerTitle: true,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Container(
              color: const Color(0xFFF5EFE6),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        
        return const HomeScreen();
      },
    );
  }
}