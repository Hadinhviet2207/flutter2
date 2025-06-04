import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/project_detail.dart';
import '../models/comment.dart';
import '../services/project_service.dart';
import '../services/project_detail_service.dart';
import '../services/comment_service.dart';
import '../services/auth_service.dart';
import '../services/upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'project_members_screen.dart';
import 'project_list_screen.dart';
import 'package:file_picker/file_picker.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({Key? key, required this.project})
    : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectService _projectService = ProjectService();
  final ProjectDetailService _projectDetailService = ProjectDetailService();
  final CommentService _commentService = CommentService();
  final AuthService _authService = AuthService();
  final UploadService _uploadService = UploadService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    ProjectStatus selectedStatus = widget.project.status;
    DateTime? selectedDueDate = widget.project.dueDate;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa Project'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tên Project',
                      ),
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
                    const SizedBox(height: 16),
                    // Dropdown chọn trạng thái
                    DropdownButtonFormField<ProjectStatus>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                      items:
                          ProjectStatus.values.map((status) {
                            return DropdownMenuItem<ProjectStatus>(
                              value: status,
                              child: Text(_getStatusText(status)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedStatus = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ngày hết hạn
                    Row(
                      children: [
                        const Text('Ngày hết hạn: '),
                        Expanded(
                          child: Text(
                            selectedDueDate != null
                                ? "${selectedDueDate!.day.toString().padLeft(2, '0')}/"
                                    "${selectedDueDate!.month.toString().padLeft(2, '0')}/"
                                    "${selectedDueDate!.year}"
                                : 'Chưa đặt',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              selectedDueDate = picked;
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                        if (selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              selectedDueDate = null;
                              (context as Element).markNeedsBuild();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
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
                      status: selectedStatus,
                      dueDate: selectedDueDate,
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

  void _showEditContentDialog(ProjectDetail projectDetail) {
    _contentController.text = projectDetail.content;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa nội dung'),
            content: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                hintText: 'Nhập nội dung chi tiết...',
              ),
              maxLines: 10,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_contentController.text.isNotEmpty) {
                    final updatedDetail = projectDetail.copyWith(
                      content: _contentController.text,
                      updatedAt: DateTime.now(),
                    );
                    await _projectDetailService.updateProjectDetail(
                      projectDetail.id,
                      updatedDetail,
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
                    final isTeamLeader =
                        memberId == widget.project.teamLeaderId;
                    return ListTile(
                      title: Text(memberId),
                      subtitle: Text(
                        isOwner
                            ? 'Chủ sở hữu'
                            : isTeamLeader
                            ? 'Trưởng nhóm'
                            : 'Thành viên',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isTeamLeader &&
                              widget.project.teamLeaderId ==
                                  _authService.currentUser?.uid)
                            IconButton(
                              icon: const Icon(Icons.star),
                              onPressed: () async {
                                final updatedProject = widget.project.copyWith(
                                  teamLeaderId: memberId,
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
                              tooltip: 'Chỉ định làm trưởng nhóm',
                            ),
                          if (!isOwner)
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () async {
                                final updatedMembers = List<String>.from(
                                  widget.project.memberIds,
                                )..remove(memberId);
                                final updatedProject = widget.project.copyWith(
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
                              tooltip: 'Xóa khỏi dự án',
                            ),
                        ],
                      ),
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
                      await _commentService.createReply(
                        parentComment.id,
                        reply,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        _commentController.clear();
                        setState(() {});
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

  void _showUploadDialog(ProjectDetail projectDetail) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tải lên'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Tải lên ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    final currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      final imageUrl = await UploadService.pickAndUploadImage(
                        userId: currentUser.uid,
                        projectId: widget.project.id,
                        parentId: projectDetail.id,
                      );
                      if (imageUrl != null && mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Tải lên file'),
                  onTap: () async {
                    Navigator.pop(context);
                    final currentUser = _authService.currentUser;
                    if (currentUser != null) {
                      final fileUrl = await UploadService.pickAndUploadFile(
                        userId: currentUser.uid,
                        projectId: widget.project.id,
                        parentId: projectDetail.id,
                      );
                      if (fileUrl != null && mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
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
              stream: _commentService.getReplies(comment.id, widget.project.id),
              builder: (context, snapshot) {
                print(
                  'StreamBuilder for ${comment.id}: ${snapshot.connectionState}',
                );
                if (snapshot.hasError) {
                  print('Error loading replies: ${snapshot.error}');
                  return Text('Lỗi: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final replies = snapshot.data!;
                print('Number of replies: ${replies.length}');
                if (replies.isEmpty) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children:
                        replies.map((reply) {
                          print('Building reply: ${reply.id}');
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reply.content,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bởi ${reply.createdBy} - ${reply.createdAt.toString()}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
    return Card(
      child: ListTile(
        leading: Icon(
          file['type'] == 'image' ? Icons.image : Icons.insert_drive_file,
        ),
        title: Text(file['name'] ?? 'Không có tên'),
        subtitle: Text(
          '${_formatFileSize(file['size'] ?? 0)} - ${file['uploadedAt']?.toDate().toString() ?? ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file['type'] == 'image')
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(file['url'], fit: BoxFit.contain),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // TODO: Implement delete file
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xfff4f5f7),
      appBar: AppBar(
        title: Text(widget.project.title),
        automaticallyImplyLeading: true,
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ảnh bìa với hiệu ứng mờ nhẹ
            Stack(
              children: [
                Image.asset(
                  'assets/icon_des1.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.2),
                  colorBlendMode: BlendMode.darken,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 18,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Ảnh bìa",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: "Đóng",
                    ),
                  ),
                ),
              ],
            ),
            // Nội dung chính cuộn được
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề project
                    Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.project.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Nhãn tag + mô tả ngắn
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.6),
                                blurRadius: 6,
                                offset: const Offset(1, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.project.status
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.project.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Ngày bắt đầu & kết thúc
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          "Bắt đầu: " +
                              "${widget.project.startDate.day.toString().padLeft(2, '0')}/"
                                  "${widget.project.startDate.month.toString().padLeft(2, '0')}/"
                                  "${widget.project.startDate.year}",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.event_available,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.project.dueDate != null
                              ? "Hạn: ${widget.project.dueDate!.day.toString().padLeft(2, '0')}/"
                                  "${widget.project.dueDate!.month.toString().padLeft(2, '0')}/"
                                  "${widget.project.dueDate!.year}"
                              : "Hạn: Chưa đặt",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Thao tác nhanh
                    Text(
                      "Các thao tác nhanh",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Thêm project con
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProjectListScreen(
                                      parentProject: widget.project,
                                    ),
                              ),
                            );
                          },
                          child: _quickActionButton(
                            Icons.check_box,
                            "Thêm Danh sách...",
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final currentUser = _authService.currentUser;
                            if (currentUser != null) {
                              final projectDetail =
                                  await _projectDetailService
                                      .getProjectDetail(widget.project.id)
                                      .first;
                              if (projectDetail != null) {
                                await UploadService.pickAndUploadFile(
                                  userId: currentUser.uid,
                                  projectId: widget.project.id,
                                  parentId: projectDetail.id,
                                );
                                if (mounted) setState(() {});
                              }
                            }
                          },
                          child: _quickActionButton(
                            Icons.attachment,
                            "Thêm Tệp đính kèm",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Thành viên
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProjectMembersScreen(
                                      projectId: widget.project.id,
                                      isTeamLeader:
                                          widget.project.teamLeaderId ==
                                          FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.uid,
                                    ),
                              ),
                            );
                          },
                          child: _quickActionButton(Icons.person, "Thành viên"),
                        ),
                        GestureDetector(
                          onTap: _showEditDialog,
                          child: _quickActionButton(Icons.edit, "Cập nhật"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Mô tả chi tiết
                    Row(
                      children: [
                        Icon(
                          Icons.subject_outlined,
                          size: 20,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Thêm mô tả",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<ProjectDetail?>(
                      stream: _projectDetailService.getProjectDetail(
                        widget.project.id,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text("Chưa có mô tả chi tiết");
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: TextEditingController(
                                text: snapshot.data!.content,
                              ),
                              maxLines: 4,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Nhập mô tả...",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            // --- HIỂN THỊ ẢNH LỚN NGAY DƯỚI MÔ TẢ ---
                            StreamBuilder<QuerySnapshot>(
                              stream:
                                  snapshot.data!.attachments.isEmpty
                                      ? null
                                      : FirebaseFirestore.instance
                                          .collection('files')
                                          .where(
                                            FieldPath.documentId,
                                            whereIn:
                                                snapshot.data!.attachments
                                                    .map((e) => e.id)
                                                    .toList(),
                                          )
                                          .snapshots(),
                              builder: (context, fileSnap) {
                                if (!fileSnap.hasData || fileSnap.data == null)
                                  return const SizedBox();
                                final allFiles =
                                    fileSnap.data!.docs
                                        .map(
                                          (doc) =>
                                              doc.data()
                                                  as Map<String, dynamic>,
                                        )
                                        .toList();
                                final images =
                                    allFiles
                                        .where(
                                          (file) => file['type'] == 'image',
                                        )
                                        .toList();
                                if (images.isEmpty) return const SizedBox();
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                return Center(
                                  child: SizedBox(
                                    width: screenWidth * 0.8,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                            childAspectRatio: 1,
                                          ),
                                      itemCount: images.length,
                                      itemBuilder: (context, idx) {
                                        final img = images[idx];
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => Dialog(
                                                    child: InteractiveViewer(
                                                      child: Image.network(
                                                        img['url'],
                                                      ),
                                                    ),
                                                  ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              img['url'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            // --- KẾT THÚC HIỂN THỊ ẢNH LỚN ---
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Tệp đính kèm
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 20,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Tệp đính kèm",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // --- HIỂN THỊ DANH SÁCH FILE (KHÔNG PHẢI ẢNH) ---
                    StreamBuilder<ProjectDetail?>(
                      stream: _projectDetailService.getProjectDetail(
                        widget.project.id,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.attachments.isEmpty) {
                          return const Text("Chưa có tệp đính kèm");
                        }
                        final attachmentIds =
                            snapshot.data!.attachments
                                .map((e) => e.id)
                                .toList();
                        if (attachmentIds.isEmpty)
                          return const Text("Chưa có tệp đính kèm");
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('files')
                                  .where(
                                    FieldPath.documentId,
                                    whereIn: attachmentIds,
                                  )
                                  .snapshots(),
                          builder: (context, fileSnap) {
                            if (!fileSnap.hasData)
                              return const CircularProgressIndicator();
                            final allFiles =
                                fileSnap.data!.docs
                                    .map(
                                      (doc) =>
                                          doc.data() as Map<String, dynamic>,
                                    )
                                    .toList();
                            final files =
                                allFiles
                                    .where((file) => file['type'] != 'image')
                                    .toList();
                            if (files.isEmpty)
                              return const Text("Chưa có tệp đính kèm");
                            return Column(
                              children:
                                  files
                                      .map(
                                        (file) => Card(
                                          elevation: 1.5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: const Icon(
                                              Icons.insert_drive_file,
                                              color: Colors.blue,
                                            ),
                                            title: Text(file['name'] ?? ''),
                                            subtitle: Text(
                                              "${file['size']} KB • ${file['type']}",
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.more_vert),
                                              onPressed: () {},
                                              tooltip: "Thao tác thêm",
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            );
                          },
                        );
                      },
                    ),
                    // --- KẾT THÚC HIỂN THỊ DANH SÁCH FILE ---
                    const SizedBox(height: 30),
                    // Danh sách công việc (project con)
                    Row(
                      children: [
                        Icon(Icons.list_alt, size: 20, color: Colors.grey[800]),
                        const SizedBox(width: 8),
                        Text(
                          "Danh sách công việc",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Project>>(
                      stream: _projectService.getChildProjects(
                        widget.project.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Lỗi: \\${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final subProjects = snapshot.data!;
                        if (subProjects.isEmpty) {
                          return const Text("Chưa có công việc nào");
                        }
                        return Column(
                          children:
                              subProjects
                                  .map(
                                    (sub) => CheckboxListTile(
                                      value:
                                          sub.status == ProjectStatus.completed,
                                      onChanged: null,
                                      title: Text(
                                        sub.title,
                                        style: textTheme.bodyMedium,
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Bình luận
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            onSubmitted: (_) => _sendComment(),
                            decoration: InputDecoration(
                              hintText: "Bình luận...",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send, size: 22),
                                onPressed: _sendComment,
                                tooltip: "Gửi bình luận",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Danh sách bình luận
                    StreamBuilder<List<Comment>>(
                      stream: _commentService.getProjectComments(
                        widget.project.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Lỗi: \\${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final comments = snapshot.data!;
                        if (comments.isEmpty) {
                          return const Text("Chưa có bình luận nào");
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final now = DateTime.now();
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final comment = Comment(
        id: _commentService.generateNewId(),
        projectId: widget.project.id,
        content: _commentController.text.trim(),
        createdBy: currentUser.uid,
        createdAt: now,
        updatedAt: now,
        mentionedUserIds: [],
        attachmentUrls: [],
      );
      await _commentService.createComment(comment);
      if (mounted) {
        _commentController.clear();
        setState(() {});
      }
    }
  }

  // Hàm chuyển ProjectStatus thành text tiếng Việt
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
      default:
        return status.toString();
    }
  }
}
