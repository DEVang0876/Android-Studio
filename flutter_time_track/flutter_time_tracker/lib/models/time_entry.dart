class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final double totalTime;
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalTime': totalTime,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      taskId: json['taskId'] as String,
      totalTime: (json['totalTime'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      notes: json['notes'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TimeEntry(id: $id, projectId: $projectId, taskId: $taskId, totalTime: $totalTime, date: $date, notes: $notes)';
  }
}