import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/apartment.dart';
import '../../models/building.dart';

class ApartmentFormScreen extends StatefulWidget {
  final Apartment? apartment;
  final Building? building;

  const ApartmentFormScreen({super.key, this.apartment, this.building});

  @override
  State<ApartmentFormScreen> createState() => _ApartmentFormScreenState();
}

class _ApartmentFormScreenState extends State<ApartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _numberController;
  late int _floor;

  @override
  void initState() {
    super.initState();
    
    _numberController = TextEditingController(text: widget.apartment?.number.toString() ?? '');
    _floor = widget.apartment?.floor ?? 1;
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _saveApartment() async {
    if (!_formKey.currentState!.validate()) return;

    final number = int.tryParse(_numberController.text);
    if (number == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный номер квартиры')),
      );
      return;
    }

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    
    final apartment = Apartment(
      id: widget.apartment?.id,
      number: number,
      floor: _floor,
    );

    if (widget.apartment == null) {
      await projectProvider.addApartment(apartment);
    } else {
      await projectProvider.updateApartment(apartment);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.apartment != null;
    final projectProvider = context.watch<ProjectProvider>();
    final building = widget.building;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать квартиру' : 'Новая квартира'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Удалить квартиру?'),
                    content: const Text('Это действие нельзя отменить.'),
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
                  await projectProvider.deleteApartment(widget.apartment!.id!);
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
              // Информация о здании
              if (building != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Здание',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        
                        Text(
                          building.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Icon(Icons.home, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 5),
                            Text('Этажей: ${building.floors}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Номер квартиры*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер квартиры';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Введите число';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              // В начало формы добавляем выбор здания:

              // Выбор здания
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Здание',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      DropdownButtonFormField<Building?>(
                        value: widget.building,
                        decoration: const InputDecoration(
                          labelText: 'Выберите здание',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home_work),
                        ),
                        items: [
                          const DropdownMenuItem<Building?>(
                            value: null,
                            child: Text('Без здания'),
                          ),
                          ...projectProvider.buildings.map((building) {
                            return DropdownMenuItem<Building?>(
                              value: building,
                              child: Text('${building.name} (${building.floors} эт.)'),
                            );
                          }).toList(),
                        ],
                        onChanged: (building) {
                          setState(() {
                            // Обновляем выбранное здание
                          });
                        },
                      ),
                      
                      if (widget.building != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Выбрано: ${widget.building!.name}',
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
              
              // Выбор этажа
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Этаж',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          IconButton(
                            onPressed: _floor > 1
                                ? () {
                                    setState(() {
                                      _floor--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          
                          Expanded(
                            child: Text(
                              'Этаж $_floor',
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
                                _floor++;
                              });
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Визуализация этажа
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.door_front_door,
                                size: 40,
                                color: const Color(0xFFCC7952),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Квартира $_floor${String.fromCharCode(8320 + (_floor % 10))} этажа',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Список существующих квартир
              if (projectProvider.apartments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Существующие квартиры',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: projectProvider.apartments
                          .take(20)
                          .map((apartment) {
                        return Chip(
                          label: Text('№${apartment.number} (эт.${apartment.floor})'),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    
                    if (projectProvider.apartments.length > 20)
                      Text(
                        '...и ещё ${projectProvider.apartments.length - 20} квартир',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveApartment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC7952),
                  ),
                  child: Text(isEdit ? 'Сохранить изменения' : 'Создать квартиру'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}