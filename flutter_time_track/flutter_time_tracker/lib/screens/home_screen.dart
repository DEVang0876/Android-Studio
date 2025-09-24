import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../utils/local_storage_inspector.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Entries'),
            Tab(text: 'By Project'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) async {
              final provider = Provider.of<TimeEntryProvider>(context, listen: false);
              if (value == 'debug_storage') {
                await _showDebugInfo(context, provider);
              } else if (value == 'print_storage') {
                await provider.printAllStorageContents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Storage contents printed to console - check terminal/logs')),
                );
              } else if (value == 'web_inspector') {
                await _startWebInspector(context);
              } else if (value == 'clear_storage') {
                await _showClearStorageDialog(context, provider);
              } else if (value == 'manage_projects') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectTaskManagementScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'manage_projects',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Manage Projects & Tasks'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'debug_storage',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Debug Storage Info'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'print_storage',
                child: ListTile(
                  leading: Icon(Icons.print),
                  title: Text('Print Storage to Console'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'web_inspector',
                child: ListTile(
                  leading: Icon(Icons.web),
                  title: Text('Open Web Inspector'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clear_storage',
                child: ListTile(
                  leading: Icon(Icons.clear_all, color: Colors.red),
                  title: Text('Clear All Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllEntriesTab(),
          _buildByProjectTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimeEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllEntriesTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No time entries yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first entry',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Sort entries by date (newest first)
        final sortedEntries = [...provider.entries];
        sortedEntries.sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return _buildTimeEntryCard(entry, provider);
          },
        );
      },
    );
  }

  Widget _buildByProjectTab() {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        final groupedEntries = provider.getEntriesGroupedByProject();

        if (groupedEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No entries by project yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: groupedEntries.entries.map((entry) {
            final projectId = entry.key;
            final entries = entry.value;
            final project = provider.getProjectById(projectId);
            final totalTime = entries.fold(0.0, (sum, e) => sum + e.totalTime);

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Text(
                  project?.name ?? 'Unknown Project',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Total: ${totalTime.toStringAsFixed(1)} hours (${entries.length} entries)',
                ),
                children: entries.map((timeEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: _buildTimeEntryCard(timeEntry, provider, isNested: true),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTimeEntryCard(TimeEntry entry, TimeEntryProvider provider, {bool isNested = false}) {
    final project = provider.getProjectById(entry.projectId);
    final task = provider.getTaskById(entry.taskId);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isNested ? 8.0 : 16.0,
        vertical: 4.0,
      ),
      elevation: isNested ? 1.0 : 2.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            entry.totalTime.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${project?.name ?? 'Unknown'} - ${task?.name ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${entry.totalTime} hours on ${dateFormat.format(entry.date)}'),
            if (entry.notes.isNotEmpty)
              Text(
                entry.notes,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmation(context, entry, provider);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TimeEntry entry,
    TimeEntryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this time entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTimeEntry(entry.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Time entry deleted')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDebugInfo(BuildContext context, TimeEntryProvider provider) async {
    final storageInfo = await provider.getStorageInfo();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Debug: Storage Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Projects in memory: ${storageInfo['projects_count']}'),
                Text('Tasks in memory: ${storageInfo['tasks_count']}'),
                Text('Entries in memory: ${storageInfo['entries_count']}'),
                const SizedBox(height: 16),
                Text('Projects stored: ${storageInfo['projects_stored']}'),
                Text('Tasks stored: ${storageInfo['tasks_stored']}'),
                Text('Entries stored: ${storageInfo['entries_stored']}'),
                const SizedBox(height: 16),
                const Text('Check console/logs for detailed JSON data'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearStorageDialog(BuildContext context, TimeEntryProvider provider) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete all projects, tasks, and time entries from local storage. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await provider.clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared and reset to defaults'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startWebInspector(BuildContext context) async {
    try {
      // Start the web inspector server
      LocalStorageWebInspector.startInspectorServer();
      
      // Show dialog with instructions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🌐 Web Inspector Started'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Local Storage Inspector is now running!'),
                SizedBox(height: 16),
                Text('Open your browser and go to:'),
                SizedBox(height: 8),
                SelectableText(
                  'http://localhost:8080',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Text('You can also try ports 8081-8090 if 8080 is busy.'),
                SizedBox(height: 8),
                Text('The inspector will auto-refresh every 5 seconds.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it!'),
              ),
            ],
          );
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌐 Web Inspector started - check browser at localhost:8080'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to start web inspector: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}