import 'package:final_project_flutter_advanced_nhom_4/screens/main_screen.dart';
import 'package:final_project_flutter_advanced_nhom_4/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng quản lý công việc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder:
              (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
          child:
              isLogin
                  ? LoginForm(onSwitch: () => setState(() => isLogin = false))
                  : SignUpForm(onSwitch: () => setState(() => isLogin = true)),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final VoidCallback onSwitch;

  const LoginForm({super.key, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      key: const ValueKey('login'),
      title: 'Chào mừng',
      buttonText: 'Đăng nhập',
      switchText: 'Chưa có tài khoản? Đăng ký',
      onSwitch: onSwitch,
    );
  }
}

class SignUpForm extends StatelessWidget {
  final VoidCallback onSwitch;

  const SignUpForm({super.key, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      key: const ValueKey('signup'),
      title: 'Tạo tài khoản mới',
      buttonText: 'Đăng Ký',
      switchText: 'Đã có tài khoản? Đăng nhập',
      onSwitch: onSwitch,
      showConfirm: true,
    );
  }
}

class AuthCard extends StatefulWidget {
  final String title;
  final String buttonText;
  final String switchText;
  final VoidCallback onSwitch;
  final bool showConfirm;

  const AuthCard({
    super.key,
    required this.title,
    required this.buttonText,
    required this.switchText,
    required this.onSwitch,
    this.showConfirm = false,
  });

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  bool showPassword = false;
  bool isLoading = false;

  final _auth = firebase_auth.FirebaseAuth.instance;

  Future<void> _handleAuth() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    if (widget.showConfirm && password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (widget.showConfirm) {
        final currentUser = _authService.currentUser;

        if (currentUser != null && currentUser.isAnonymous) {
          await _authService.linkEmailPassword(email, password);
        } else {
          await _authService.registerWithEmailAndPassword(email, password);
        }
      } else {
        await _authService.signInWithEmailAndPassword(email, password);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.buttonText} thành công!')),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Có lỗi xảy ra!';

      if (e.code == 'email-already-in-use') {
        message = 'Email đã được sử dụng.';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không đúng.';
      } else if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng.';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi không xác định: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock_outline,
                obscure: !showPassword,
                togglePassword:
                    () => setState(() => showPassword = !showPassword),
              ),
              if (!widget.showConfirm)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              if (widget.showConfirm)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: confirmController,
                      label: 'Xác nhận mật khẩu',
                      icon: Icons.lock_reset_outlined,
                      obscure: true,
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303F9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleAuth,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            widget.buttonText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: widget.onSwitch,
                  child: Text(
                    widget.switchText,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? togglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        suffixIcon:
            togglePassword != null
                ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: togglePassword,
                )
                : null,
        labelText: label,
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khôi phục mật khẩu'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303F9F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi yêu cầu khôi phục!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Gửi yêu cầu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
