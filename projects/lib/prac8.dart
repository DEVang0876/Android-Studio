import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Prac8 extends StatefulWidget {
  const Prac8({super.key});

  @override
  State<Prac8> createState() => _Prac8State();
}

class _Prac8State extends State<Prac8> {
  List articles = [];

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final url = "https://newsapi.org/v2/everything?q=tesla&from=2025-08-21&sortBy=publishedAt&apiKey=6c56e0739b844b1c8848d7e6a6a99343";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Log the API response
        if (data['articles'] != null) {
          setState(() {
            articles = data['articles'];
          });
        } else {
          print('No articles found in response');
        }
      } else {
        print('Failed to fetch articles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Articles'),
        backgroundColor: Colors.blueAccent,
      ),
      body: articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(articles[index]['title'] ?? 'No Title'),
                    subtitle: Text(articles[index]['description'] ?? 'No Description'),
                  ),
                );
              },
            ),
    );
  }
}
