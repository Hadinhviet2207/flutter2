import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/invite_code_list.dart';
import '../widgets/join_with_invite_code.dart';

class InviteManagementScreen extends StatelessWidget {
  final String projectId;
  final String userId;
  final bool isOwner;

  const InviteManagementScreen({
    Key? key,
    required this.projectId,
    required this.userId,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thành viên')),
      body: CustomScrollView(
        slivers: [
          if (!isOwner)
            SliverToBoxAdapter(child: JoinWithInviteCode(userId: userId)),
          if (isOwner) ...[
            SliverToBoxAdapter(
              child: InviteCodeList(projectId: projectId, ownerUid: userId),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildJoinRequestsList()),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('join_requests')
              .where('projectId', isEqualTo: projectId)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return const Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Không có yêu cầu tham gia nào đang chờ duyệt'),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // KEY FIX: Prevent expansion
              children: [
                const Text(
                  'Yêu cầu tham gia đang chờ duyệt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // FIX: Use Column instead of ListView.builder inside scrollable
                ...requests.map((request) {
                  final data = request.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
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
                                  () =>
                                      _handleRequest(context, request.id, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
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
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
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
            projectData['memberIds'] ??
                [], // FIX: Use memberIds instead of members
          );
          if (!currentMembers.contains(requesterId)) {
            currentMembers.add(requesterId);
          }

          txn.update(projectRef, {'memberIds': currentMembers});
          txn.update(docRef, {'status': 'approved', 'approvedBy': userId});
        });
      } else {
        await docRef.update({'status': 'rejected', 'approvedBy': userId});
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
