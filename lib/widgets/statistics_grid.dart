import 'package:flutter/material.dart';
import '../utils/number_formatter.dart';
import '../utils/animations.dart';

class StatisticsGrid extends StatelessWidget {
  final List<StatItem> items;
  final bool isCompact;
  
  const StatisticsGrid({
    super.key,
    required this.items,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final crossAxisCount = isLargeScreen ? 
          (isCompact ? 4 : 3) : 
          (constraints.maxWidth > 400 ? 2 : 1);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isCompact ? 8 : 12,
            mainAxisSpacing: isCompact ? 8 : 12,
            childAspectRatio: _getAspectRatio(constraints.maxWidth, isCompact),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return AppAnimations.staggeredCard(
              index: index,
              baseDuration: const Duration(milliseconds: 200),
              delayPerItem: const Duration(milliseconds: 50),
              child: _buildStatCard(items[index], isLargeScreen, isCompact),
            );
          },
        );
      },
    );
  }
  
  double _getAspectRatio(double width, bool isCompact) {
    if (isCompact) {
      return width > 600 ? 1.0 : 0.9;
    }
    if (width > 600) return 1.2;
    if (width > 400) return 1.1;
    return 0.9;
  }
  
  Widget _buildStatCard(StatItem item, bool isLargeScreen, bool isCompact) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 8 : isLargeScreen ? 16 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Иконка
            AppAnimations.pulse(
              child: Container(
                width: isCompact ? 36 : 48,
                height: isCompact ? 36 : 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
                ),
                child: Icon(
                  item.icon,
                  size: isCompact ? 20 : 24,
                  color: item.color,
                ),
              ),
            ),
            
            SizedBox(height: isCompact ? 8 : 12),
            
            // Значение
            _buildValueWidget(item, isLargeScreen, isCompact),
            
            SizedBox(height: 4),
            
            // Название
            Text(
              item.title,
              style: TextStyle(
                fontSize: isCompact ? 12 : 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildValueWidget(StatItem item, bool isLargeScreen, bool isCompact) {
    final textStyle = TextStyle(
      fontSize: isCompact 
          ? (isLargeScreen ? 18 : 14)
          : (isLargeScreen ? 24 : 20),
      fontWeight: FontWeight.bold,
      color: item.color,
    );
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: isCompact ? 100 : 150,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          item.value,
          style: textStyle,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;
  final String? additionalInfo;
  
  StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
    this.additionalInfo,
  });
  
  factory StatItem.projectCount(int count) {
    return StatItem(
      title: 'Проектов',
      value: NumberFormatter.compactNumber(count),
      icon: Icons.business,
      color: const Color(0xFFCC7952),
    );
  }
  
  factory StatItem.buildingCount(int count) {
    return StatItem(
      title: 'Зданий',
      value: NumberFormatter.compactNumber(count),
      icon: Icons.home_work,
      color: const Color(0xFFE5BD77),
    );
  }
  
  factory StatItem.apartmentCount(int count) {
    return StatItem(
      title: 'Квартир',
      value: NumberFormatter.compactNumber(count),
      icon: Icons.apartment,
      color: const Color(0xFF2196F3),
    );
  }
  
  factory StatItem.budget(double amount) {
    return StatItem(
      title: 'Бюджет',
      value: NumberFormatter.formatCurrency(amount),
      icon: Icons.attach_money,
      color: const Color(0xFF9C27B0),
    );
  }
  
  factory StatItem.spent(double amount) {
    return StatItem(
      title: 'Потрачено',
      value: NumberFormatter.formatCurrency(amount),
      icon: Icons.money_off,
      color: const Color(0xFFF44336),
    );
  }
  
  factory StatItem.progress(double progress) {
    return StatItem(
      title: 'Прогресс',
      value: NumberFormatter.formatPercent(progress),
      icon: Icons.trending_up,
      color: const Color(0xFFFF9800),
      progress: progress,
    );
  }
}