import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  TimeEntryProvider() {
    _loadData();
  }

  // Initialize with default projects and tasks
  void _initializeDefaultData() {
    _projects = [
      Project(id: '1', name: 'Project A'),
      Project(id: '2', name: 'Project B'),
      Project(id: '3', name: 'Project C'),
    ];

    _tasks = [
      Task(id: '1', name: 'Task 1'),
      Task(id: '2', name: 'Task 2'),
      Task(id: '3', name: 'Task 3'),
      Task(id: '4', name: 'Task 4'),
    ];

    _saveData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Debug: Print what's in storage
    print('=== DEBUG: Loading from SharedPreferences ===');
    print('Projects JSON: ${prefs.getString('projects')}');
    print('Tasks JSON: ${prefs.getString('tasks')}');
    print('Entries JSON: ${prefs.getString('entries')}');
    
    // Load projects
    final projectsJson = prefs.getString('projects');
    if (projectsJson != null) {
      final List<dynamic> projectsList = json.decode(projectsJson);
      _projects = projectsList.map((json) => Project.fromJson(json)).toList();
      print('Loaded ${_projects.length} projects');
    } else {
      print('No projects found, initializing default data');
      _initializeDefaultData();
      return;
    }

    // Load tasks
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      _tasks = tasksList.map((json) => Task.fromJson(json)).toList();
      print('Loaded ${_tasks.length} tasks');
    }

    // Load entries
    final entriesJson = prefs.getString('entries');
    if (entriesJson != null) {
      final List<dynamic> entriesList = json.decode(entriesJson);
      _entries = entriesList.map((json) => TimeEntry.fromJson(json)).toList();
      print('Loaded ${_entries.length} entries');
    } else {
      print('No entries found in storage');
    }

    print('=== DEBUG: Load complete ===');
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('=== DEBUG: Saving to SharedPreferences ===');
    print('Saving ${_projects.length} projects');
    print('Saving ${_tasks.length} tasks');
    print('Saving ${_entries.length} entries');
    
    // Save projects
    final projectsJson = json.encode(_projects.map((p) => p.toJson()).toList());
    await prefs.setString('projects', projectsJson);

    // Save tasks
    final tasksJson = json.encode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', tasksJson);

    // Save entries
    final entriesJson = json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('entries', entriesJson);
    
    print('=== DEBUG: Save complete ===');
  }

  // Add a new time entry
  void addTimeEntry(TimeEntry entry) {
    print('DEBUG: Adding time entry: ${entry.id}');
    _entries.add(entry);
    _saveData();
    notifyListeners();
    print('DEBUG: Total entries after add: ${_entries.length}');
  }

  // Delete a time entry
  void deleteTimeEntry(String id) {
    print('DEBUG: Deleting time entry: $id');
    _entries.removeWhere((entry) => entry.id == id);
    _saveData();
    notifyListeners();
    print('DEBUG: Total entries after delete: ${_entries.length}');
  }

  // Debug method to clear all stored data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _entries.clear();
    _projects.clear();
    _tasks.clear();
    _initializeDefaultData();
    print('DEBUG: All data cleared and reset to defaults');
    notifyListeners();
  }

  // Debug method to get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'projects_stored': prefs.getString('projects') != null,
      'tasks_stored': prefs.getString('tasks') != null,
      'entries_stored': prefs.getString('entries') != null,
      'projects_count': _projects.length,
      'tasks_count': _tasks.length,
      'entries_count': _entries.length,
    };
  }

  // Debug method to print all storage contents
  Future<void> printAllStorageContents() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== COMPLETE STORAGE DUMP ===');
    
    // Print all SharedPreferences keys
    final keys = prefs.getKeys();
    print('All stored keys: $keys');
    
    // Print detailed content
    final projectsJson = prefs.getString('projects');
    final tasksJson = prefs.getString('tasks');
    final entriesJson = prefs.getString('entries');
    
    print('--- PROJECTS ---');
    if (projectsJson != null) {
      print('Raw JSON: $projectsJson');
      print('Parsed count: ${_projects.length}');
      for (var project in _projects) {
        print('  Project: ${project.id} - ${project.name}');
      }
    } else {
      print('No projects in storage');
    }
    
    print('--- TASKS ---');
    if (tasksJson != null) {
      print('Raw JSON: $tasksJson');
      print('Parsed count: ${_tasks.length}');
      for (var task in _tasks) {
        print('  Task: ${task.id} - ${task.name}');
      }
    } else {
      print('No tasks in storage');
    }
    
    print('--- ENTRIES ---');
    if (entriesJson != null) {
      print('Raw JSON: $entriesJson');
      print('Parsed count: ${_entries.length}');
      for (var entry in _entries) {
        print('  Entry: ${entry.id} - Project:${entry.projectId} Task:${entry.taskId} Time:${entry.totalTime}h Date:${entry.date}');
      }
    } else {
      print('No entries in storage');
    }
    
    print('=== END STORAGE DUMP ===');
  }

  // Add a new project
  void addProject(Project project) {
    _projects.add(project);
    _saveData();
    notifyListeners();
  }

  // Delete a project
  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    // Also remove related time entries
    _entries.removeWhere((entry) => entry.projectId == id);
    _saveData();
    notifyListeners();
  }

  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  // Delete a task
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    // Also remove related time entries
    _entries.removeWhere((entry) => entry.taskId == id);
    _saveData();
    notifyListeners();
  }

  // Get project by id
  Project? getProjectById(String id) {
    return _projects.where((project) => project.id == id).firstOrNull;
  }

  // Get task by id
  Task? getTaskById(String id) {
    return _tasks.where((task) => task.id == id).firstOrNull;
  }

  // Get entries grouped by project
  Map<String, List<TimeEntry>> getEntriesGroupedByProject() {
    final Map<String, List<TimeEntry>> grouped = {};
    
    for (final entry in _entries) {
      final projectId = entry.projectId;
      if (!grouped.containsKey(projectId)) {
        grouped[projectId] = [];
      }
      grouped[projectId]!.add(entry);
    }
    
    return grouped;
  }
}