class NumberFormatter {
  // Форматирование чисел с разделителями тысяч
  static String formatNumber(double number, {int decimalDigits = 0}) {
    if (number == 0) return '0';
    
    // Определяем, нужно ли показывать дробную часть
    final hasDecimal = number % 1 != 0 && decimalDigits > 0;
    
    if (number.abs() >= 1000000000) { // Миллиарды
      final value = number / 1000000000;
      return '${_formatDecimal(value, decimalDigits)} млрд';
    } else if (number.abs() >= 1000000) { // Миллионы
      final value = number / 1000000;
      return '${_formatDecimal(value, decimalDigits)} млн';
    } else if (number.abs() >= 1000) { // Тысячи
      final value = number / 1000;
      return '${_formatDecimal(value, decimalDigits)} тыс';
    } else if (hasDecimal) { // Дробные числа
      return number.toStringAsFixed(decimalDigits);
    } else { // Целые числа < 1000
      return number.toInt().toString();
    }
  }
  
  // Форматирование денежных значений
  static String formatCurrency(double amount, {bool showCents = false}) {
    if (amount == 0) return '0 ₽';
    
    if (amount.abs() >= 1000000000) { // Миллиарды
      final value = amount / 1000000000;
      return '${_formatDecimal(value, 1)} млрд ₽';
    } else if (amount.abs() >= 1000000) { // Миллионы
      final value = amount / 1000000;
      return '${_formatDecimal(value, 1)} млн ₽';
    } else if (amount.abs() >= 10000) { // Десятки тысяч
      final value = amount / 1000;
      return '${_formatDecimal(value, 0)} тыс ₽';
    } else if (showCents && amount % 1 != 0) { // С копейками
      return '${amount.toStringAsFixed(2)} ₽';
    } else { // Целые числа
      return '${amount.toInt()} ₽';
    }
  }
  
  // Форматирование процентов
  static String formatPercent(double value, {int decimalDigits = 1}) {
    final percent = value * 100;
    return '${percent.toStringAsFixed(decimalDigits)}%';
  }
  
  // Вспомогательный метод для форматирования десятичных чисел
  static String _formatDecimal(double value, int decimalDigits) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(decimalDigits);
    }
  }
  
  // Сокращение больших чисел для компактного отображения
  static String compactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  // Форматирование с разделителями тысяч
  static String formatWithSeparators(double number) {
    final parts = number.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integerPart[i]);
    }
    
    return '${buffer}$decimalPart';
  }
}