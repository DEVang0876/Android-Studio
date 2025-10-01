import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Prac8 extends StatelessWidget {
  const Prac8({super.key});

  static final Uri _url = Uri.parse(
    'https://newsapi.org/v2/everything?q=tesla&from=2025-09-01&sortBy=publishedAt&apiKey=6c56e0739b844b1c8848d7e6a6a99343',
  );

  Future<List<_Article>> _fetch() async {
    final res = await http.get(_url);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (body['articles'] as List?) ?? const [];
    return list.whereType<Map<String, dynamic>>().map((a) {
      return _Article(
        title: (a['title'] as String?) ?? 'No Title',
        description: (a['description'] as String?) ?? '',
        imageUrl: (a['urlToImage'] as String?),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News Articles')),
      body: FutureBuilder<List<_Article>>(
        future: _fetch(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load: ${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          final data = snap.data ?? const [];
          if (data.isEmpty) {
            return const Center(child: Text('No articles'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final a = data[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: (a.imageUrl != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            a.imageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        )
                      : const Icon(Icons.article_outlined),
                  title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Article {
  final String title;
  final String description;
  final String? imageUrl;
  const _Article({required this.title, required this.description, this.imageUrl});
}
