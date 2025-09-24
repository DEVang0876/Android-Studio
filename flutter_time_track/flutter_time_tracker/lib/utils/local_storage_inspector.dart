import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageWebInspector {
  static HttpServer? _server;
  static int _port = 8080;

  static Future<void> startInspectorServer() async {
    try {
      // Try to start server on port 8080, if busy try others
      for (int port = 8080; port <= 8090; port++) {
        try {
          _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
          _port = port;
          break;
        } catch (e) {
          if (port == 8090) rethrow;
          continue;
        }
      }

      print('🌐 Local Storage Inspector started at: http://localhost:$_port');
      
      await for (HttpRequest request in _server!) {
        await _handleRequest(request);
      }
    } catch (e) {
      print('❌ Failed to start inspector server: $e');
    }
  }

  static Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    
    // Enable CORS
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      response.statusCode = 200;
      await response.close();
      return;
    }

    try {
      if (request.uri.path == '/') {
        await _serveInspectorPage(response);
      } else if (request.uri.path == '/api/storage') {
        await _serveStorageData(response);
      } else if (request.uri.path == '/api/clear') {
        await _clearStorage(response);
      } else {
        response.statusCode = 404;
        response.write('Not Found');
      }
    } catch (e) {
      response.statusCode = 500;
      response.write('Error: $e');
    }

    await response.close();
  }

  static Future<void> _serveInspectorPage(HttpResponse response) async {
    response.headers.contentType = ContentType.html;
    
    final html = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Time Tracker - Local Storage Inspector</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: #2196F3;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .controls {
            display: flex;
            gap: 10px;
        }
        button {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-refresh {
            background: rgba(255,255,255,0.2);
            color: white;
        }
        .btn-clear {
            background: #f44336;
            color: white;
        }
        .btn-refresh:hover { background: rgba(255,255,255,0.3); }
        .btn-clear:hover { background: #d32f2f; }
        .storage-table {
            width: 100%;
            border-collapse: collapse;
        }
        .storage-table th,
        .storage-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        .storage-table th {
            background: #f8f9fa;
            font-weight: 600;
            position: sticky;
            top: 0;
        }
        .key-cell {
            font-weight: 500;
            color: #1976D2;
            min-width: 150px;
        }
        .value-cell {
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 12px;
            max-width: 600px;
            word-break: break-all;
        }
        .json-value {
            background: #f5f5f5;
            padding: 8px;
            border-radius: 4px;
            white-space: pre-wrap;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        .stats {
            background: #f8f9fa;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #666;
        }
        .loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🕒 Time Tracker - Local Storage Inspector</h1>
            <div class="controls">
                <button class="btn-refresh" onclick="loadStorageData()">🔄 Refresh</button>
                <button class="btn-clear" onclick="clearStorage()">🗑️ Clear All</button>
            </div>
        </div>
        
        <div class="stats" id="stats">
            <span>Loading...</span>
        </div>
        
        <div id="content" class="loading">
            Loading storage data...
        </div>
    </div>

    <script>
        async function loadStorageData() {
            try {
                const response = await fetch('/api/storage');
                const data = await response.json();
                
                updateStats(data);
                renderStorageTable(data.storage);
            } catch (error) {
                document.getElementById('content').innerHTML = 
                    '<div class="empty-state">❌ Error loading storage data: ' + error.message + '</div>';
            }
        }

        function updateStats(data) {
            const stats = document.getElementById('stats');
            stats.innerHTML = `
                <span>📁 Projects: \${data.counts.projects}</span>
                <span>✅ Tasks: \${data.counts.tasks}</span>
                <span>⏱️ Time Entries: \${data.counts.entries}</span>
                <span>🔑 Storage Keys: \${Object.keys(data.storage).length}</span>
            `;
        }

        function renderStorageTable(storage) {
            const content = document.getElementById('content');
            
            if (Object.keys(storage).length === 0) {
                content.innerHTML = '<div class="empty-state">📭 No data in local storage</div>';
                return;
            }

            let tableHTML = `
                <table class="storage-table">
                    <thead>
                        <tr>
                            <th>Key</th>
                            <th>Value</th>
                        </tr>
                    </thead>
                    <tbody>
            `;

            for (const [key, value] of Object.entries(storage)) {
                const displayValue = typeof value === 'string' && value.length > 100 
                    ? value.substring(0, 100) + '...' 
                    : value;
                    
                tableHTML += `
                    <tr>
                        <td class="key-cell">\${key}</td>
                        <td class="value-cell">
                            <div class="json-value">\${JSON.stringify(displayValue, null, 2)}</div>
                        </td>
                    </tr>
                `;
            }

            tableHTML += '</tbody></table>';
            content.innerHTML = tableHTML;
        }

        async function clearStorage() {
            if (!confirm('⚠️ Are you sure you want to clear all storage data?')) {
                return;
            }
            
            try {
                const response = await fetch('/api/clear', { method: 'POST' });
                if (response.ok) {
                    alert('✅ Storage cleared successfully!');
                    loadStorageData();
                } else {
                    alert('❌ Failed to clear storage');
                }
            } catch (error) {
                alert('❌ Error: ' + error.message);
            }
        }

        // Auto-refresh every 5 seconds
        setInterval(loadStorageData, 5000);
        
        // Initial load
        loadStorageData();
    </script>
</body>
</html>
    ''';
    
    response.write(html);
  }

  static Future<void> _serveStorageData(HttpResponse response) async {
    response.headers.contentType = ContentType.json;
    
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    final storage = <String, dynamic>{};
    for (String key in keys) {
      storage[key] = prefs.get(key);
    }

    // Parse counts
    int projectCount = 0, taskCount = 0, entryCount = 0;
    
    try {
      final projectsJson = prefs.getString('projects');
      if (projectsJson != null) {
        final projects = json.decode(projectsJson) as List;
        projectCount = projects.length;
      }
    } catch (e) { /* ignore */ }
    
    try {
      final tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        final tasks = json.decode(tasksJson) as List;
        taskCount = tasks.length;
      }
    } catch (e) { /* ignore */ }
    
    try {
      final entriesJson = prefs.getString('entries');
      if (entriesJson != null) {
        final entries = json.decode(entriesJson) as List;
        entryCount = entries.length;
      }
    } catch (e) { /* ignore */ }

    final responseData = {
      'storage': storage,
      'counts': {
        'projects': projectCount,
        'tasks': taskCount,
        'entries': entryCount,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    response.write(json.encode(responseData));
  }

  static Future<void> _clearStorage(HttpResponse response) async {
    response.headers.contentType = ContentType.json;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      response.write(json.encode({'success': true, 'message': 'Storage cleared'}));
    } catch (e) {
      response.statusCode = 500;
      response.write(json.encode({'success': false, 'error': e.toString()}));
    }
  }

  static Future<void> stopInspectorServer() async {
    await _server?.close();
    _server = null;
    print('🛑 Local Storage Inspector stopped');
  }
}