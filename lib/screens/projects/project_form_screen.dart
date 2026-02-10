import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';
import '../../utils/animations.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  // ... существующий код состояния

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeIn(
      child: Scaffold(
        // ... существующий код Scaffold
      ),
    );
  }
}