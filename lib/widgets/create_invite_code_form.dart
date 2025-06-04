import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/invite_code_service.dart';

class CreateInviteCodeForm extends StatefulWidget {
  final String projectId;
  final bool isTeamLeader;

  const CreateInviteCodeForm({
    Key? key,
    required this.projectId,
    required this.isTeamLeader,
  }) : super(key: key);

  @override
  State<CreateInviteCodeForm> createState() => _CreateInviteCodeFormState();
}

class _CreateInviteCodeFormState extends State<CreateInviteCodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeService = InviteCodeService();
  bool _isLoading = false;

  Future<void> _createInviteCode() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tạo mã mời'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!widget.isTeamLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ trưởng nhóm mới có quyền tạo mã mời'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final code = await _inviteCodeService.createInviteCode(
        widget.projectId,
        user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mã mời đã được tạo: $code'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tạo mã mời',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _createInviteCode,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Tạo mã mời'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
