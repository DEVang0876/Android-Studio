class Employee 
{
  final String name;
  final double hourly_rate;
  final double hours_worked;

  Employee(this.name, this.hourly_rate, this.hours_worked);

  double weeklySalary() 
  {
    final regularHours = hours_worked <= 40 ? hours_worked : 40;
    final overtimeHours = hours_worked > 40 ? (hours_worked - 40) : 0;
    final salary = (regularHours * hourly_rate) + (overtimeHours * hourly_rate * 1.5);
    return double.parse(salary.toStringAsFixed(2));
  }

  @override
  String toString() => '$name = ₹${weeklySalary()}';
}

void main() 
{
  final employees = <Employee>
  [
    Employee('Virat', 500.0, 38),
    Employee('Rohit', 450.0, 41),
    Employee('Gill', 600.0, 50),
  ];
  print('Weekly Salaries');
  for (final e in employees) {
    print(e);
  }
  print(''); 
}

