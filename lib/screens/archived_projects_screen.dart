import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_detail_screen.dart';

class ArchivedProjectsScreen extends StatelessWidget {
  final ProjectService _projectService = ProjectService();

  ArchivedProjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Đã Lưu')),
      body: StreamBuilder<List<Project>>(
        stream: _projectService.getAllProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data ?? [];
          final archivedProjects = projects.where((p) => p.isArchived).toList();

          if (archivedProjects.isEmpty) {
            return const Center(
              child: Text('Chưa có project nào được lưu trữ'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archivedProjects.length,
            itemBuilder: (context, index) {
              final project = archivedProjects[index];
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.description),
                      const SizedBox(height: 4),
                      Text(
                        'Trạng thái: ${project.isDeleted ? "Đã xóa" : "Đã lưu trữ"}',
                        style: TextStyle(
                          color: project.isDeleted ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
