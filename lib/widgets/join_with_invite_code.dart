import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/invite_code_service.dart';

class JoinWithInviteCode extends StatefulWidget {
  final String userId;

  const JoinWithInviteCode({Key? key, required this.userId}) : super(key: key);

  @override
  State<JoinWithInviteCode> createState() => _JoinWithInviteCodeState();
}

class _JoinWithInviteCodeState extends State<JoinWithInviteCode> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _inviteCodeService = InviteCodeService();
  bool _isLoading = false;

  Future<void> _submitCode() async {
    if (!_formKey.currentState!.validate()) return;

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

    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim().toUpperCase();
      final inviteCode = await _inviteCodeService.getInviteCode(code);

      if (inviteCode == null) {
        throw 'Mã mời không tồn tại';
      }

      if (inviteCode.expiresAt.isBefore(DateTime.now())) {
        throw 'Mã mời đã hết hạn';
      }

      // Kiểm tra xem đã gửi yêu cầu chưa
      final existingRequest =
          await FirebaseFirestore.instance
              .collection('join_requests')
              .where('projectId', isEqualTo: inviteCode.projectId)
              .where('requesterId', isEqualTo: user.uid)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existingRequest.docs.isNotEmpty) {
        throw 'Bạn đã gửi yêu cầu tham gia project này rồi';
      }

      // Tạo yêu cầu tham gia
      await FirebaseFirestore.instance.collection('join_requests').add({
        'code': code,
        'projectId': inviteCode.projectId,
        'requesterId': user.uid,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'approvedBy': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yêu cầu tham gia đã được gửi'),
            backgroundColor: Colors.green,
          ),
        );
        _codeController.clear();
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
                'Tham gia project bằng mã mời',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Nhập mã mời',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã mời';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitCode,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Gửi yêu cầu tham gia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
