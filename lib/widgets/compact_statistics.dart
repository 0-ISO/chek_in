import 'package:flutter/material.dart';
import 'statistics_grid.dart';
import '../utils/animations.dart';

class CompactStatistics extends StatelessWidget {
  final List<StatItem> items;
  
  const CompactStatistics({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeSlideIn(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ключевые показатели',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length} шт.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Компактная сетка
              _buildCompactGrid(items),
              
              // Время обновления
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Обновлено: ${_formatTime()}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompactGrid(List<StatItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AppAnimations.scaleIn(
          child: _buildCompactStatCard(items[index]),
        );
      },
    );
  }
  
  Widget _buildCompactStatCard(StatItem item) {
    return Container(
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 20,
            color: item.color,
          ),
          
          const SizedBox(height: 8),
          
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _formatTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}