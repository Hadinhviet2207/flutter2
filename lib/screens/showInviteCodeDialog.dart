import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void showInviteCodeDialog(BuildContext context, String? inviteCode) {
  final TextEditingController _inputController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Mã mời',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              // Dùng Stack để đặt nút X lên trên cùng
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 36,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nhập mã mời',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.teal.shade900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _inputController,
                          maxLength: 12,
                          textCapitalization: TextCapitalization.characters,
                          autofocus: true,
                          cursorColor: Colors.teal.shade700,
                          decoration: InputDecoration(
                            hintText: 'Nhập mã mời bạn bè...',
                            filled: true,
                            fillColor: Colors.teal.shade50,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 28,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.teal.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.teal.shade600,
                                width: 3,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.teal.shade400,
                              ),
                              onPressed: () => _inputController.clear(),
                              splashRadius: 22,
                            ),
                            hintStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.teal.shade400,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            letterSpacing: 4,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.teal.shade900,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final code = _inputController.text.trim();
                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Vui lòng nhập mã mời!',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    backgroundColor: Colors.redAccent.shade400,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Mã mời "$code" đã được nhập!',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  backgroundColor: Colors.teal.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 18),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              elevation: MaterialStateProperty.all(10),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.pressed,
                                    )) {
                                      return Colors.teal.shade900;
                                    }
                                    return Colors.teal.shade700;
                                  }),
                              shadowColor: MaterialStateProperty.all(
                                Colors.teal.shade400,
                              ),
                            ),
                            child: Text(
                              'Xác nhận',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (inviteCode != null && inviteCode.isNotEmpty) ...[
                          const SizedBox(height: 48),
                          Divider(
                            thickness: 1.5,
                            color: Colors.teal.shade200,
                            height: 36,
                          ),
                          Text(
                            'Mã mời của bạn',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.teal.shade800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.teal.shade300,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade200.withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.teal.shade800,
                                      Colors.teal.shade400,
                                      Colors.teal.shade900,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(rect);
                                },
                                child: Text(
                                  inviteCode.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.copy_outlined,
                              size: 26,
                              color: Colors.white,
                            ), // màu trắng icon
                            label: Text(
                              'Sao chép mã mời',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: Colors.white, // chữ trắng
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 40,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                              shadowColor: Colors.teal.shade400,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: inviteCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã sao chép mã mời vào clipboard!',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.teal.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Nút X đóng dialog - ở góc trên bên phải
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 26,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(anim1),
        child: FadeTransition(opacity: anim1, child: child),
      );
    },
  );
}
