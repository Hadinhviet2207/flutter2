import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/comment.dart';
import '../services/project_service.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({Key? key, required this.project})
    : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectService _projectService = ProjectService();
  final CommentService _commentService = CommentService();
  final AuthService _authService = AuthService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa Project'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tên Project'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên project';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    maxLines: 3,
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
                    final updatedProject = widget.project.copyWith(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      updatedAt: DateTime.now(),
                    );
                    await _projectService.updateProject(
                      widget.project.id,
                      updatedProject,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _showMemberDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quản lý thành viên'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.project.memberIds.length,
                  itemBuilder: (context, index) {
                    final memberId = widget.project.memberIds[index];
                    final isOwner = memberId == widget.project.ownerId;
                    return ListTile(
                      title: Text(memberId),
                      subtitle: Text(isOwner ? 'Chủ sở hữu' : 'Thành viên'),
                      trailing:
                          !isOwner
                              ? IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () async {
                                  final updatedMembers = List<String>.from(
                                    widget.project.memberIds,
                                  )..remove(memberId);
                                  final updatedProject = widget.project
                                      .copyWith(
                                        memberIds: updatedMembers,
                                        updatedAt: DateTime.now(),
                                      );
                                  await _projectService.updateProject(
                                    widget.project.id,
                                    updatedProject,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    setState(() {});
                                  }
                                },
                              )
                              : null,
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm Bình Luận'),
            content: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung bình luận',
                hintText: 'Nhập nội dung bình luận...',
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _commentController.clear();
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_commentController.text.isNotEmpty) {
                    final now = DateTime.now();
                    final currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      final comment = Comment(
                        id: _commentService.generateNewId(),
                        projectId: widget.project.id,
                        content: _commentController.text,
                        createdBy: currentUser.uid,
                        createdAt: now,
                        updatedAt: now,
                        mentionedUserIds: [],
                        attachmentUrls: [],
                      );
                      await _commentService.createComment(comment);
                      if (mounted) {
                        Navigator.pop(context);
                        _commentController.clear();
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

  void _showReplyDialog(Comment parentComment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Trả Lời Bình Luận'),
            content: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung trả lời',
                hintText: 'Nhập nội dung trả lời...',
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _commentController.clear();
                },
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_commentController.text.isNotEmpty) {
                    final now = DateTime.now();
                    final currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      final reply = Comment(
                        id: _commentService.generateNewId(),
                        projectId: widget.project.id,
                        content: _commentController.text,
                        createdBy: currentUser.uid,
                        createdAt: now,
                        updatedAt: now,
                        mentionedUserIds: [],
                        attachmentUrls: [],
                        parentId: parentComment.id,
                      );
                      await _commentService.createComment(reply);
                      if (mounted) {
                        Navigator.pop(context);
                        _commentController.clear();
                      }
                    }
                  }
                },
                child: const Text('Trả Lời'),
              ),
            ],
          ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () => _showReplyDialog(comment),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Bởi ${comment.createdBy} - ${comment.createdAt.toString()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            StreamBuilder<List<Comment>>(
              stream: _commentService.getReplies(comment.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children:
                        snapshot.data!
                            .map((reply) => _buildCommentItem(reply))
                            .toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showMemberDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final updatedProject = widget.project.copyWith(
                isDeleted: true,
                updatedAt: DateTime.now(),
              );
              await _projectService.updateProject(
                widget.project.id,
                updatedProject,
              );
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(widget.project.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bình Luận',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<Comment>>(
                  stream: _commentService.getProjectComments(widget.project.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Center(child: Text('Chưa có bình luận nào'));
                    }

                    return Column(
                      children:
                          comments
                              .map((comment) => _buildCommentItem(comment))
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        child: const Icon(Icons.comment),
      ),
    );
  }
}
