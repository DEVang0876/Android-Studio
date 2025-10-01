
class Student 
{
  final String name;
  final List<int> marks;
  Student(this.name, this.marks);

  double average() =>
      marks.isEmpty ? 0.0 : marks.reduce((a, b) => a + b) / marks.length;

  int total() => marks.isEmpty ? 0 : marks.reduce((a, b) => a + b);
}

void main() 
{
  print('Performance Analyzer');
  final students = <Student>[
    Student('Arjun', [78, 82, 91, 87]),
    Student('Bhavna', [55, 60, 58, 62]),
    Student('Chirag', [92, 95, 90, 96]),
    Student('Diya', [70, 68, 72, 75]),
  ];

  
  final averages = students.map((s) => {'name': s.name, 'avg': s.average()}).toList();
  for (final row in averages) {
    print('${row['name']}: avg ${(row['avg'] as double).toStringAsFixed(2)}');
  }

  final highest = students.reduce((a, b) => a.average() >= b.average() ? a : b);
  final lowest = students.reduce((a, b) => a.average() <= b.average() ? a : b);
  print('Highest: ${highest.name} (${highest.average().toStringAsFixed(2)})');
  print('Lowest: ${lowest.name} (${lowest.average().toStringAsFixed(2)})');

  
  const threshold = 75.0;
  final above = students.where((s) => s.average() > threshold).toList();
  print('Above $threshold: ${above.map((s) => s.name).join(', ')}');

  print('');
}
