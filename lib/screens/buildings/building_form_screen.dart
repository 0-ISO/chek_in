import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/building.dart';
import '../../models/project.dart';

class BuildingFormScreen extends StatefulWidget {
  final Building? building;
  final Project? selectedProject;

  const BuildingFormScreen({super.key, this.building, this.selectedProject});

  @override
  State<BuildingFormScreen> createState() => _BuildingFormScreenState();
}

class _BuildingFormScreenState extends State<BuildingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late int _floors;
  late int _apartmentsPerFloor;
  Project? _selectedProject;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.building?.name ?? '');
    _floors = widget.building?.floors ?? 1;
    _apartmentsPerFloor = widget.building?.apartmentsPerFloor ?? 1;
    _selectedProject = widget.selectedProject;
    
    // Если передано здание, находим его проект
    if (widget.building?.projectId != null && _selectedProject == null) {
      final projectProvider = context.read<ProjectProvider>();
      _selectedProject = projectProvider.getProjectById(widget.building!.projectId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBuilding() async {
    if (!_formKey.currentState!.validate()) return;

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    
    final building = Building(
      id: widget.building?.id,
      name: _nameController.text.trim(),
      floors: _floors,
      apartmentsPerFloor: _apartmentsPerFloor,
      projectId: _selectedProject?.id,
    );

    if (widget.building == null) {
      await projectProvider.addBuilding(building);
      
      // Если выбран проект, добавляем здание к проекту
      if (_selectedProject != null) {
        final project = _selectedProject!;
        project.buildingIds.add(building.id!);
        await projectProvider.updateProject(project);
      }
    } else {
      await projectProvider.updateBuilding(building);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.building != null;
    final totalApartments = _floors * _apartmentsPerFloor;
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать здание' : 'Новое здание'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить здание?'),
                    content: const Text('Все квартиры в этом здании также будут удалены.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
                  await projectProvider.deleteBuilding(widget.building!.id!);
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Выбор проекта
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Проект',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      DropdownButtonFormField<Project?>(
                        value: _selectedProject,
                        decoration: const InputDecoration(
                          labelText: 'Выберите проект',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: [
                          const DropdownMenuItem<Project?>(
                            value: null,
                            child: Text('Без проекта'),
                          ),
                          ...projectProvider.projects.map((project) {
                            return DropdownMenuItem<Project?>(
                              value: project,
                              child: Text(project.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (project) {
                          setState(() {
                            _selectedProject = project;
                          });
                        },
                      ),
                      
                      if (_selectedProject != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Выбран проект: ${_selectedProject!.name}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название здания*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название здания';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Остальной код формы остается таким же...
              // [Код с выбором этажей и квартир из предыдущей версии]
              // Этажи
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Этажи',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          IconButton(
                            onPressed: _floors > 1
                                ? () {
                                    setState(() {
                                      _floors--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          
                          Expanded(
                            child: Text(
                              '$_floors',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _floors++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Text(
                        'Всего этажей: $_floors',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Квартиры на этаже
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Квартир на этаже',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          IconButton(
                            onPressed: _apartmentsPerFloor > 1
                                ? () {
                                    setState(() {
                                      _apartmentsPerFloor--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          
                          Expanded(
                            child: Text(
                              '$_apartmentsPerFloor',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _apartmentsPerFloor++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Text(
                        'Квартир на этаже: $_apartmentsPerFloor',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Итоговая статистика
              Card(
                color: const Color(0xFFE5BD77).withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Итоговая информация',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          const Icon(Icons.home, color: Color(0xFFCC7952)),
                          const SizedBox(width: 10),
                          Text(
                            'Этажи: $_floors',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          const Icon(Icons.door_front_door, color: Color(0xFFCC7952)),
                          const SizedBox(width: 10),
                          Text(
                            'Квартир на этаже: $_apartmentsPerFloor',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          const Icon(Icons.calculate, color: Color(0xFFCC7952)),
                          const SizedBox(width: 10),
                          Text(
                            'Всего квартир: $totalApartments',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCC7952),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBuilding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC7952),
                  ),
                  child: Text(isEdit ? 'Сохранить изменения' : 'Создать здание'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}