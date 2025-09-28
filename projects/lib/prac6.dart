import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Practical 6: Notes App using SharedPreferences
/// - Persist notes (title + body) locally
/// - Dark mode toggle that persists
/// - "Remember me" switch persisted as an example preference
///
/// All logic is contained within this single file for simplicity.

class Prac6 extends StatefulWidget {
  const Prac6({super.key});

  @override
  State<Prac6> createState() => _Prac6State();
}

class _Prac6State extends State<Prac6> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _themeMode = await Prefs.loadThemeMode();
    _rememberMe = await Prefs.loadRememberMe();
    if (mounted) setState(() {});
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    await Prefs.saveThemeMode(_themeMode);
  }

  Future<void> _setRemember(bool value) async {
    setState(() => _rememberMe = value);
    await Prefs.saveRememberMe(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _themeMode == ThemeMode.dark;
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
    );
    // Return a single screen (no nested MaterialApp), consistent with other practials.
    return Theme(
      data: theme,
      child: NotesHomePage(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        rememberMe: _rememberMe,
        onRememberChanged: _setRemember,
      ),
    );
  }
}

// ------------------------------
// Data layer and persistence
// ------------------------------

class Note {
  final String id;
  String title;
  String body;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.body,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class Prefs {
  static const String notesKey = 'prac6_notes_v1';
  static const String darkModeKey = 'prac6_dark_mode';
  static const String rememberMeKey = 'prac6_remember_me';

  static Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  // Notes
  static Future<List<Note>> loadNotes() async {
    final p = await _p;
    final raw = p.getStringList(notesKey) ?? <String>[];
    return raw
        .map((e) => Note.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList(growable: true);
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final p = await _p;
    final raw = notes.map((n) => json.encode(n.toJson())).toList();
    await p.setStringList(notesKey, raw);
  }

  // Theme
  static Future<ThemeMode> loadThemeMode() async {
    final p = await _p;
    final v = p.getString(darkModeKey);
    switch (v) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final p = await _p;
    final value = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await p.setString(darkModeKey, value);
  }

  // Remember Me
  static Future<bool> loadRememberMe() async {
    final p = await _p;
    return p.getBool(rememberMeKey) ?? false;
  }

  static Future<void> saveRememberMe(bool value) async {
    final p = await _p;
    await p.setBool(rememberMeKey, value);
  }
}

// ------------------------------
// UI
// ------------------------------

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.rememberMe,
    required this.onRememberChanged,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Note> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _notes = await Prefs.loadNotes();
    setState(() => _loading = false);
  }

  Future<void> _addOrEdit([Note? note]) async {
    final result = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (_) => EditNotePage(initial: note),
      ),
    );
    if (result == null) return;
    setState(() {
      final idx = _notes.indexWhere((n) => n.id == result.id);
      if (idx >= 0) {
        _notes[idx] = result;
      } else {
        _notes.insert(0, result);
      }
    });
    await Prefs.saveNotes(_notes);
  }

  Future<void> _delete(Note note) async {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    await Prefs.saveNotes(_notes);
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final isDark = widget.themeMode == ThemeMode.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: isDark,
                title: const Text('Dark mode'),
                subtitle: const Text('Toggle app theme and persist it'),
                onChanged: (_) {
                  Navigator.pop(ctx);
                  widget.onToggleTheme();
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              const Divider(height: 4),
              SwitchListTile(
                value: widget.rememberMe,
                title: const Text('Remember me'),
                subtitle: const Text('Example preference stored locally'),
                onChanged: (v) => widget.onRememberChanged(v),
                secondary: const Icon(Icons.check_circle_outline),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes (Shared Preferences)'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light' : 'Switch to dark',
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _EmptyState(rememberMe: widget.rememberMe)
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96, left: 8, right: 8, top: 8),
                  itemBuilder: (ctx, i) {
                    final n = _notes[i];
                    return Dismissible(
                      key: ValueKey(n.id),
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete),
                      ),
                      secondaryBackground: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (_) => _delete(n),
                      child: ListTile(
                        title: Text(n.title.isEmpty ? '(No title)' : n.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          n.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          _formatTime(n.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () => _addOrEdit(n),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemCount: _notes.length,
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addOrEdit,
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.rememberMe});
  final bool rememberMe;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            const Text('No notes yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tap the + button to create your first note.'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 6),
                Text('Remember me: ${rememberMe ? 'ON' : 'OFF'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  const EditNotePage({super.key, this.initial});
  final Note? initial;

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late final TextEditingController _title;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _body = TextEditingController(text: widget.initial?.body ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final now = DateTime.now();
    final note = widget.initial == null
        ? Note(id: UniqueKey().toString(), title: _title.text.trim(), body: _body.text.trim())
        : Note(
            id: widget.initial!.id,
            title: _title.text.trim(),
            body: _body.text.trim(),
            createdAt: widget.initial!.createdAt,
            updatedAt: now,
          );
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit note' : 'New note'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _body,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


