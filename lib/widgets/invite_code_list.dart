import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/invite_code.dart';
import '../services/invite_code_service.dart';

class InviteCodeList extends StatelessWidget {
  final String projectId;
  final String ownerUid;
  final InviteCodeService _inviteCodeService = InviteCodeService();

  InviteCodeList({Key? key, required this.projectId, required this.ownerUid})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mã mời',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    try {
                      final inviteCode = await _inviteCodeService
                          .createInviteCode(projectId, user.uid);
                      await Clipboard.setData(
                        ClipboardData(text: inviteCode.code),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã tạo và copy mã mời: ${inviteCode.code}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi tạo mã mời: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo mã mời mới'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<InviteCode>>(
              stream: _inviteCodeService.getProjectInviteCodes(projectId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Có lỗi xảy ra: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final inviteCodes = snapshot.data!;

                if (inviteCodes.isEmpty) {
                  return const Center(child: Text('Chưa có mã mời nào'));
                }

                return Column(
                  children:
                      inviteCodes.map((inviteCode) {
                        final isExpired = inviteCode.expiresAt.isBefore(
                          DateTime.now(),
                        );
                        return Card(
                          child: ListTile(
                            title: Text(
                              inviteCode.code,
                              style: TextStyle(
                                color: isExpired ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Hết hạn: ${_formatDateTime(inviteCode.expiresAt)}',
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.grey,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed:
                                      isExpired
                                          ? null
                                          : () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: inviteCode.code,
                                              ),
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đã copy mã mời',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed:
                                      isExpired
                                          ? null
                                          : () async {
                                            try {
                                              await _inviteCodeService
                                                  .deleteInviteCode(
                                                    inviteCode.code,
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Đã xóa mã mời',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Lỗi: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
