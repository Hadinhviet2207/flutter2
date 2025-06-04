import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'invite_code_list.dart';
import 'join_with_invite_code.dart';

class InviteMemberButton extends StatelessWidget {
  final String projectId;
  final bool isTeamLeader;

  const InviteMemberButton({
    Key? key,
    required this.projectId,
    required this.isTeamLeader,
  }) : super(key: key);

  void _showInviteDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng chức năng này'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Mời thành viên',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isTeamLeader) ...[
                          InviteCodeList(
                            projectId: projectId,
                            ownerUid: user.uid,
                          ),
                        ] else ...[
                          JoinWithInviteCode(userId: user.uid),
                        ],
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showInviteDialog(context),
      icon: const Icon(Icons.person_add),
      label: Text(isTeamLeader ? 'Mời thành viên' : 'Tham gia project'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
