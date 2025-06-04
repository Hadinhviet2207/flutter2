import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/invite_code_list.dart';

class ProjectMembersScreen extends StatelessWidget {
  final String projectId;
  final bool isTeamLeader;

  const ProjectMembersScreen({
    Key? key,
    required this.projectId,
    required this.isTeamLeader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thành viên')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isTeamLeader) ...[
              InviteCodeList(
                projectId: projectId,
                ownerUid: FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Yêu cầu tham gia đang chờ duyệt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('join_requests')
                                .where('projectId', isEqualTo: projectId)
                                .where('status', isEqualTo: 'pending')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Có lỗi xảy ra: ${snapshot.error}'),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final requests = snapshot.data!.docs;

                          if (requests.isEmpty) {
                            return const Center(
                              child: Text(
                                'Không có yêu cầu tham gia nào đang chờ duyệt',
                              ),
                            );
                          }

                          return Column(
                            children:
                                requests.map((request) {
                                  final data =
                                      request.data() as Map<String, dynamic>;
                                  return Card(
                                    child: ListTile(
                                      title: FutureBuilder<DocumentSnapshot>(
                                        future:
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(data['requesterId'])
                                                .get(),
                                        builder: (context, userSnapshot) {
                                          if (!userSnapshot.hasData) {
                                            return const Text('Đang tải...');
                                          }
                                          final userData =
                                              userSnapshot.data!.data()
                                                  as Map<String, dynamic>?;
                                          return Text(
                                            userData?['displayName'] ??
                                                'Người dùng không xác định',
                                          );
                                        },
                                      ),
                                      subtitle: Text(
                                        'Yêu cầu lúc: ${_formatDateTime((data['requestedAt'] as Timestamp).toDate())}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                            onPressed:
                                                () => _handleRequest(
                                                  context,
                                                  request.id,
                                                  true,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _handleRequest(
                                                  context,
                                                  request.id,
                                                  false,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Danh sách thành viên',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('projects')
                              .doc(projectId)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Có lỗi xảy ra: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final project = Project.fromJson(
                          snapshot.data!.data() as Map<String, dynamic>,
                        );
                        final members = project.memberIds;

                        if (members.isEmpty) {
                          return const Center(
                            child: Text('Chưa có thành viên nào'),
                          );
                        }

                        return Column(
                          children:
                              members.map((memberId) {
                                return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(memberId)
                                          .get(),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const ListTile(
                                        leading: CircularProgressIndicator(),
                                      );
                                    }

                                    final userData =
                                        userSnapshot.data!.data()
                                            as Map<String, dynamic>?;
                                    final isTeamLeaderMember =
                                        memberId == project.teamLeaderId;

                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          userData?['displayName']?[0] ?? '?',
                                        ),
                                      ),
                                      title: Text(
                                        userData?['displayName'] ??
                                            'Không xác định',
                                      ),
                                      subtitle: Text(
                                        isTeamLeaderMember
                                            ? 'Trưởng nhóm'
                                            : 'Thành viên',
                                      ),
                                      trailing:
                                          isTeamLeader &&
                                                  memberId !=
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid
                                              ? IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: const Text(
                                                            'Xác nhận',
                                                          ),
                                                          content: const Text(
                                                            'Bạn có chắc muốn xóa thành viên này?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                              child: const Text(
                                                                'Hủy',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                ProjectService()
                                                                    .removeMember(
                                                                      projectId,
                                                                      memberId,
                                                                    );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: const Text(
                                                                'Xóa',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                              )
                                              : null,
                                    );
                                  },
                                );
                              }).toList(),
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

  Future<void> _handleRequest(
    BuildContext context,
    String requestId,
    bool isApproved,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('join_requests')
          .doc(requestId);
      final doc = await docRef.get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final projectId = data['projectId'];
      final requesterId = data['requesterId'];

      if (isApproved) {
        // Thêm user vào project
        await FirebaseFirestore.instance.runTransaction((txn) async {
          final projectRef = FirebaseFirestore.instance
              .collection('projects')
              .doc(projectId);
          final projectSnap = await txn.get(projectRef);
          final projectData = projectSnap.data()!;
          final currentMembers = List<String>.from(
            projectData['memberIds'] ?? [],
          );
          if (!currentMembers.contains(requesterId)) {
            currentMembers.add(requesterId);
          }

          txn.update(projectRef, {'memberIds': currentMembers});
          txn.update(docRef, {
            'status': 'approved',
            'approvedBy': FirebaseAuth.instance.currentUser?.uid,
          });
        });
      } else {
        await docRef.update({
          'status': 'rejected',
          'approvedBy': FirebaseAuth.instance.currentUser?.uid,
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu',
            ),
            backgroundColor: isApproved ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
