import 'package:flutter/material.dart';
import '../../services/database_helper.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _analysisHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await DatabaseHelper.instance.getUsers();
    final posts = await DatabaseHelper.instance.getPosts();
    final history = await DatabaseHelper.instance.getAnalysisHistory();

    setState(() {
      _users = users;
      _posts = posts;
      _analysisHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Database Viewer"),
          backgroundColor: const Color(0xFF7D2424),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Posts'),
              Tab(text: 'History'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFDF6E3),
        body: TabBarView(
          children: [
            _buildTableSection('Users Table', _users),
            _buildTableSection('Posts Table', _posts),
            _buildTableSection('Analysis History', _analysisHistory),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadData,
          backgroundColor: const Color(0xFF22512F),
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildTableSection(String title, List<Map<String, dynamic>> data) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Questrial',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text('ID: ${item['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.entries
                          .where((e) => e.key != 'id')
                          .map((e) => Text('${e.key}: ${e.value}'))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
