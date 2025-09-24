// TEMPORARY DEBUG FILE - You can run this code anywhere in your app
// Add this to any button or method to inspect storage:

import 'package:shared_preferences/shared_preferences.dart';

Future<void> inspectStorage() async {
  final prefs = await SharedPreferences.getInstance();
  
  print('=== MANUAL STORAGE INSPECTION ===');
  
  // Get all keys
  final keys = prefs.getKeys();
  print('All keys: $keys');
  
  // Check specific keys
  for (String key in keys) {
    final value = prefs.get(key);
    print('$key: $value');
  }
  
  // Specific app keys
  print('Projects: ${prefs.getString('projects')}');
  print('Tasks: ${prefs.getString('tasks')}');
  print('Entries: ${prefs.getString('entries')}');
  
  print('=== END INSPECTION ===');
}

// Or use this one-liner in any method:
// Provider.of<TimeEntryProvider>(context, listen: false).printAllStorageContents();