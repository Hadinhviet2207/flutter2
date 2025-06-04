import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/join_project_form.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProjectListScreen extends StatefulWidget {
  final Project? parentProject;

  const ProjectListScreen({Key? key, this.parentProject}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildProjectCard(Project project) {
    return Slidable(
      key: ValueKey(project.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteProjectDialog(project),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _togglePin(project),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: project.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: project.isPinned ? 'Bỏ gim' : 'Gim',
          ),
          SlidableAction(
            onPressed: (_) => _showEditProjectDialog(project),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Sửa',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Image.asset(
            'assets/icon_des1.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight:
                        project.isPinned ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (project.isPinned)
                const Icon(Icons.push_pin, color: Colors.blueAccent, size: 18),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(project.status),
                    size: 16,
                    color: _getStatusColor(project.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(project.status),
                    style: TextStyle(
                      color: _getStatusColor(project.status),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (project.dueDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hết hạn: ${_formatDate(project.dueDate!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(project: project),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.waitingReview:
        return Colors.purple;
      case ProjectStatus.revisionNeeded:
        return Colors.red;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.canceled:
        return Colors.red;
      case ProjectStatus.archived:
        return Colors.grey;
      case ProjectStatus.delayed:
        return Colors.orange;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return 'Chưa bắt đầu';
      case ProjectStatus.inProgress:
        return 'Đang thực hiện';
      case ProjectStatus.onHold:
        return 'Tạm dừng';
      case ProjectStatus.waitingReview:
        return 'Chờ kiểm tra';
      case ProjectStatus.revisionNeeded:
        return 'Cần sửa lại';
      case ProjectStatus.completed:
        return 'Đã hoàn thành';
      case ProjectStatus.canceled:
        return 'Đã huỷ';
      case ProjectStatus.archived:
        return 'Lưu trữ';
      case ProjectStatus.delayed:
        return 'Bị trễ';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _togglePin(Project project) async {
    try {
      final isOwner = project.ownerId == _authService.currentUser?.uid;
      if (isOwner) {
        // Nếu là chủ project, cho phép chọn ghim cá nhân hoặc toàn cục
        final result = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Ghim Project'),
                content: const Text(
                  'Bạn muốn ghim project này cho mình hay cho tất cả thành viên?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Chỉ cho tôi'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Cho tất cả'),
                  ),
                ],
              ),
        );

        if (result != null) {
          await _projectService.togglePin(project.id, isGlobal: result);
        }
      } else {
        // Nếu không phải chủ project, chỉ cho phép ghim cá nhân
        await _projectService.togglePin(project.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  void _showEditProjectDialog(Project project) {
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    DateTime? selectedDueDate = project.dueDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 28,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Chỉnh Sửa Project',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Tên project
                            TextFormField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tên project',
                                labelText: 'Tên project',
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Vui lòng nhập tên project'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            // Mô tả
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Mô tả project',
                                labelText: 'Mô tả project',
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Vui lòng nhập mô tả'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            // Ngày kết thúc
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ListTile(
                                title: const Text(
                                  'Ngày kết thúc',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      selectedDueDate != null
                                          ? "${selectedDueDate!.day.toString().padLeft(2, '0')}/"
                                              "${selectedDueDate!.month.toString().padLeft(2, '0')}/"
                                              "${selectedDueDate!.year}"
                                          : "Chưa đặt",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              selectedDueDate ?? DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                      primary: Colors.blue,
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (date != null) {
                                          setState(
                                            () => selectedDueDate = date,
                                          );
                                        }
                                      },
                                    ),
                                    if (selectedDueDate != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => selectedDueDate = null,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _titleController.clear();
                                    _descriptionController.clear();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 36,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 6,
                                      shadowColor: Colors.blueAccent
                                          .withOpacity(0.5),
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final updatedProject = project.copyWith(
                                          title: _titleController.text,
                                          description:
                                              _descriptionController.text,
                                          dueDate: selectedDueDate,
                                          updatedAt: DateTime.now(),
                                        );
                                        await _projectService.updateProject(
                                          project.id,
                                          updatedProject,
                                        );
                                        if (mounted) {
                                          Navigator.pop(context);
                                          _titleController.clear();
                                          _descriptionController.clear();
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Lưu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  void _showDeleteProjectDialog(Project project) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa Project'),
            content: Text(
              'Bạn có chắc chắn muốn xóa project "${project.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _projectService.deleteProject(project.id);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.notStarted:
        return Icons.hourglass_empty;
      case ProjectStatus.inProgress:
        return Icons.play_circle_fill;
      case ProjectStatus.onHold:
        return Icons.pause_circle_filled;
      case ProjectStatus.waitingReview:
        return Icons.rate_review;
      case ProjectStatus.revisionNeeded:
        return Icons.edit;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.canceled:
        return Icons.cancel;
      case ProjectStatus.archived:
        return Icons.archive;
      case ProjectStatus.delayed:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon_des1.png', height: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Quản lý công việc",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProjectScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Tìm project...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KHÔNG GIAN LÀM VIỆC CỦA BẠN',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.group, color: Colors.black54),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Không gian làm việc của bạn',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const Text('Project', style: TextStyle(color: Colors.blue)),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const JoinProjectForm(),
            Expanded(
              child: StreamBuilder<List<Project>>(
                stream:
                    widget.parentProject != null
                        ? _projectService.getChildProjects(
                          widget.parentProject!.id,
                        )
                        : _projectService.getRootProjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final projects = snapshot.data!;

                  if (projects.isEmpty) {
                    return Center(
                      child: Text(
                        widget.parentProject != null
                            ? 'Chưa có project con nào'
                            : 'Chưa có project nào',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder:
                        (context, index) => _buildProjectCard(projects[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
