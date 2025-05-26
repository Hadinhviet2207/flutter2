import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/auth_service.dart';
import 'project_detail_screen.dart';
import 'archived_projects_screen.dart';
import 'home_screen.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              widget.parentProject != null
                  ? 'Thêm Project Con'
                  : 'Thêm Project Mới',
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Vui lòng nhập tiêu đề'
                                : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Vui lòng nhập mô tả'
                                : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final now = DateTime.now();
                    final currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      final project = Project(
                        id: _projectService.generateNewId(),
                        title: _titleController.text,
                        description: _descriptionController.text,
                        createdAt: now,
                        updatedAt: now,
                        ownerId: currentUser.uid,
                        memberIds: [currentUser.uid],
                        parentId: widget.parentProject?.id,
                        startDate: now,
                      );
                      await _projectService.createProject(project);
                      if (mounted) {
                        Navigator.pop(context);
                        _titleController.clear();
                        _descriptionController.clear();
                      }
                    }
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            if (project.isGlobalPinned)
              const Icon(Icons.push_pin, color: Colors.red, size: 16)
            else if (project.isPinned)
              const Icon(Icons.push_pin, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(project.title)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(project.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                if (project.dueDate != null)
                  Text(
                    'Hết hạn: ${_formatDate(project.dueDate!)}',
                    style: TextStyle(
                      color:
                          project.dueDate!.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            if (project.parentId == null) ...[
              const SizedBox(height: 4),
              StreamBuilder<List<Project>>(
                stream: _projectService.getChildProjects(project.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final subProjects = snapshot.data!.length;
                  return Text(
                    '$subProjects project con',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.parentId == null)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProjectListScreen(parentProject: project),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(
                project.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: project.isPinned ? Colors.blue : null,
              ),
              onPressed: () => _togglePin(project),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProjectDialog(project),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteProjectDialog(project),
            ),
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: () => _archiveProject(project),
            ),
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

  String _formatNullableDate(DateTime? date) {
    if (date == null) return 'Chưa đặt';
    return _formatDate(date);
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
    ProjectStatus selectedStatus = project.status;
    DateTime? selectedDueDate = project.dueDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Chỉnh Sửa Project'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tiêu đề',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Vui lòng nhập tiêu đề'
                                        : null,
                          ),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả',
                            ),
                            validator:
                                (value) =>
                                    value?.isEmpty ?? true
                                        ? 'Vui lòng nhập mô tả'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ProjectStatus>(
                            value: selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Trạng thái',
                            ),
                            items:
                                ProjectStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(_getStatusText(status)),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedStatus = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Ngày hết hạn'),
                            subtitle: Text(
                              _formatNullableDate(selectedDueDate),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedDueDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() => selectedDueDate = null);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          selectedDueDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null) {
                                      setState(() => selectedDueDate = date);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _titleController.clear();
                        _descriptionController.clear();
                      },
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final updatedProject = project.copyWith(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            status: selectedStatus,
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
                      child: const Text('Lưu'),
                    ),
                  ],
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

  Future<void> _archiveProject(Project project) async {
    await _projectService.archiveProject(project.id);
  }

  void _showLinkAccountDialog(BuildContext context) {
    final _confirmPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Liên kết tài khoản'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _linkAccount,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Liên kết'),
              ),
            ],
          ),
    );
  }

  Future<void> _linkAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.linkEmailPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Liên kết tài khoản thành công!')),
          );
          Navigator.pop(context); // Đóng dialog
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.parentProject != null
              ? 'Project Con: ${widget.parentProject!.title}'
              : 'Danh Sách Project',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivedProjectsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => _showLinkAccountDialog(context),
            tooltip: 'Liên kết tài khoản',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream:
            widget.parentProject != null
                ? _projectService.getChildProjects(widget.parentProject!.id)
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
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) => _buildProjectCard(projects[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
