import 'package:flutter/material.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xfff4f5f7),
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
                    // Tiêu đề file
                    Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "1000029212_0x0_832x713.png",
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
                            "TEST",
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Atest",
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
                          "Bắt đầu: 24/05/2025",
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
                          "Hạn: 30/05/2025",
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Thao tác nhanh (Quick actions)
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
                        _quickActionButton(
                          Icons.check_box,
                          "Thêm Danh sách...",
                        ),
                        _quickActionButton(
                          Icons.attachment,
                          "Thêm Tệp đính kèm",
                        ),
                        _quickActionButton(Icons.person, "Thành viên"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Mô tả
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
                    TextField(
                      maxLines: 4,
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
                    Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.insert_drive_file,
                          color: Colors.blue,
                        ),
                        title: const Text("bao_cao_mau_da.pdf"),
                        subtitle: Text(
                          "120 KB • PDF",
                          style: textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                          tooltip: "Thao tác thêm",
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Danh sách công việc
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
                    ...[
                      "Chụp ảnh mẫu",
                      "Phân loại đá",
                      "Đính kèm tài liệu",
                    ].map((task) {
                      return CheckboxListTile(
                        value: false,
                        onChanged: (_) {},
                        title: Text(task, style: textTheme.bodyMedium),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),

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
                                onPressed: () {},
                                tooltip: "Gửi bình luận",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),
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
}
