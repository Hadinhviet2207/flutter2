[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/iMsyzK08)
# Bài tập lớn - Phát triển ứng dụng nâng cao với Flutter

## Giảng viên hướng dẫn
- **Họ và tên**: GVC. TS. Trần Trung Chuyên  
- **Email**: trantrungchuyen@humg.edu.vn  
- **Số điện thoại**: 0983.344.8779  
- **Thời gian hỗ trợ**: Thứ 3 & Thứ 5, 14:00 - 16:00 (liên hệ qua email hoặc Zalo)

## Thông tin nhóm
- **Tên nhóm**: Nhóm 4  
- **Danh sách thành viên**:  
  - Họ và tên: Vũ Đức Quỳnh | MSSV: 2121050831 | Lớp: DCCTCLC66A2
  - Họ và tên: Hà Đình Việt | MSSV: 2121050974 | Lớp: DCCTCLC66A2  
**Lưu ý**: Nhóm cần điền đầy đủ thông tin này trước khi nộp bài.

## Hướng dẫn khởi tạo dự án sau khi nhận bài tập
Sau khi nhận bài tập từ GitHub Classroom, mỗi nhóm sẽ được tự động tạo một repository riêng dựa trên template này. Repository ban đầu chỉ chứa file `README.md`. Để bắt đầu, các bạn cần làm theo các bước sau:

1. **Clone repository của nhóm về máy**:  
   - Nhóm trưởng hoặc thành viên đầu tiên truy cập vào repository của nhóm trên GitHub Classroom.  
   - Sao chép URL của repository (ví dụ: `https://github.com/<organization>/flutter-final-project-group-X.git`).  
   - Mở terminal và chạy lệnh:  
     ```bash
     git clone <URL-của-repository>
     ```
   - Ví dụ:  
     ```bash
     git clone https://github.com/FlutterAdvanced2025/flutter-final-project-group-1.git
     ```
   - Di chuyển vào thư mục vừa clone:  
     ```bash
     cd flutter-final-project-group-1
     ```

2. **Khởi tạo dự án Flutter trong repository**:  
   - Trong thư mục vừa clone, chạy lệnh sau để tạo một dự án Flutter mới ngay trong chính thư mục này:  
     ```bash
     flutter create .
     ```
   - Lệnh này sẽ tạo các file và thư mục cần thiết cho một dự án Flutter (như `lib/`, `pubspec.yaml`, v.v.) mà không tạo thư mục mới.  
   - Đảm bảo bạn đã cài đặt Flutter và Dart trên máy. Nếu chưa, tham khảo [hướng dẫn cài đặt Flutter](https://flutter.dev/docs/get-started/install).

3. **Điền thông tin nhóm vào file `README.md`**:  
   - Mở file `README.md` trong thư mục dự án.  
   - Cập nhật phần **Thông tin nhóm** (ở trên) với đầy đủ thông tin của nhóm: tên nhóm, họ tên, MSSV, và lớp của từng thành viên.  
   - Ví dụ:  
     ```
     - **Tên nhóm**: Nhóm 1  
     - **Danh sách thành viên**:  
       - Họ và tên: Nguyễn Văn A | MSSV: 123456 | Lớp: K68CA-1  
       - Họ và tên: Trần Thị B | MSSV: 654321 | Lớp: K68CA-1  
       - Họ và tên: Lê Văn C | MSSV: 112233 | Lớp: K68CA-1  
       - Họ và tên: Phạm Thị D | MSSV: 445566 | Lớp: K68CA-1  
     ```

4. **Commit và đẩy thay đổi lên repository**:  
   - Sau khi khởi tạo dự án và điền thông tin nhóm, commit các thay đổi:  
     ```bash
     git add .
     git commit -m "Khởi tạo dự án Flutter và điền thông tin nhóm"
     git push origin main
     ```
   - Đảm bảo tất cả thành viên trong nhóm đều có thể truy cập repository và làm việc trên cùng nhánh `main`.

**Lưu ý**:  
- Các bước trên cần được thực hiện ngay sau khi nhận bài tập để đảm bảo dự án được khởi tạo đúng cách.  
- Nếu gặp lỗi khi chạy `flutter create .`, hãy kiểm tra xem Flutter đã được cài đặt đúng chưa bằng lệnh `flutter doctor`.

## Giới thiệu
Đây là yêu cầu của bài tập lớn (final project) cho môn học **7080327: Phát triển ứng dụng di động đa nền tảng 2**. Nhóm sinh viên sẽ xây dựng một ứng dụng di động phức tạp sử dụng **Flutter** và **Dart**, tập trung vào các kỹ năng nâng cao như quản lý trạng thái native, tối ưu hóa hiệu suất, xử lý dữ liệu thời gian thực, và triển khai CI/CD với GitHub Actions.  
**Thời gian thực hiện**: Từ ngày 23/04/2025 đến ngày 14/05/2025.

## Mục tiêu
Bài tập lớn nhằm:  
- Thành thạo lập trình giao diện người dùng (UI) phức tạp với Flutter và Dart.  
- Sử dụng các phương pháp quản lý trạng thái native như `InheritedWidget`, `ChangeNotifier`, `ValueListenableBuilder`, hoặc `ValueNotifier` thay vì các thư viện bên thứ ba.  
- Tích hợp ứng dụng với backend thời gian thực (Firebase, Amplify Gen 2) và xử lý dữ liệu phức tạp.  
- Thực hiện các thao tác CRUD (Create, Read, Update, Delete) với dữ liệu phân cấp (nested data).  
- Thực hiện các thao tác publish/subscribe với dữ liệu thời gian thực (ví dụ: tự động cập nhật danh sách task khi có người khác chỉnh sửa).  
- Viết kiểm thử nâng cao (unit test, widget test, integration test) và thiết lập CI/CD với GitHub Actions để tự động hóa kiểm thử và phân tích mã nguồn.  
- Tối ưu hóa hiệu suất ứng dụng (giảm thời gian render, quản lý tài nguyên).

## Yêu cầu ứng dụng
### 1. Chức năng CRUD và dữ liệu phân cấp
- Ứng dụng cần cung cấp đầy đủ các chức năng CRUD cho một đối tượng phức tạp có **dữ liệu phân cấp**. Ví dụ: Một ứng dụng quản lý công việc (Task Manager) với các đối tượng như:  
  - **Project**: (`id`, `title`, `description`, `createdAt`).  
  - **Task**: (`id`, `title`, `status`, `priority`, `dueDate`, `assignedTo`).  
  - **Subtask**: (`id`, `title`, `isCompleted`).  
- Yêu cầu:  
  - Thực hiện CRUD cho cả 3 cấp (Project, Task, Subtask).  
  - Hỗ trợ **tìm kiếm** và **lọc** dữ liệu (ví dụ: lọc task theo trạng thái hoặc ưu tiên).  
  - Xử lý xung đột dữ liệu khi nhiều người dùng cùng chỉnh sửa một task (ví dụ: hiển thị thông báo hoặc ưu tiên chỉnh sửa mới nhất).  
  - Có thể sử dụng `dart data class generator extension` để tạo các class model với các phương thức như `copyWith`, `toJson`, `fromJson`.

### 2. Giao diện người dùng (UI/UX nâng cao)
- Thiết kế giao diện tối ưu cho ứng dụng phức tạp, mượt mà, và thân thiện với người dùng.  
- Thiết kế giao diện theo hướng **responsive** (tương thích với điện thoại iOS/Android và máy tính bảng).  
- Yêu cầu các màn hình tối thiểu:  
  - **Danh sách project**: Hiển thị danh sách project với số lượng task và tiến độ hoàn thành (progress bar).  
  - **Chi tiết project**: Hiển thị danh sách task, hỗ trợ kéo thả (drag-and-drop) để thay đổi trạng thái task (ví dụ: từ "To Do" sang "In Progress").  
  - **Chi tiết task**: Hiển thị danh sách subtask, cho phép thêm/sửa/xóa subtask.  
  - **Màn hình profile**: Cập nhật thông tin cá nhân và thay đổi mật khẩu (sử dụng Firebase Authentication).  
- Yêu cầu tối ưu hóa UI:  
  - Sử dụng `const` widgets để giảm thời gian rebuild.  
  - Tải dữ liệu theo dạng **lazy loading** (chỉ tải task khi người dùng cuộn đến).  
  - Sử dụng `CustomPainter` để vẽ ít nhất một thành phần giao diện (ví dụ: progress bar tùy chỉnh).

### 3. Quản lý trạng thái (Native)
- **Không được sử dụng thư viện bên thứ ba** như `provider`, `bloc`, hoặc `riverpod`.  
- Sử dụng các phương pháp native của Flutter để quản lý trạng thái:  
  - **InheritedWidget** hoặc `InheritedModel` để truyền dữ liệu giữa các widget.  
  - **ChangeNotifier** kết hợp với `Consumer` để cập nhật UI khi trạng thái thay đổi.  
  - **ValueNotifier** và `ValueListenableBuilder` cho các trạng thái đơn giản (ví dụ: trạng thái loading).  
- Yêu cầu:  
  - Tối ưu hóa việc rebuild widget: Chỉ rebuild các widget bị ảnh hưởng bởi thay đổi trạng thái.  
  - Viết tài liệu giải thích cách triển khai quản lý trạng thái trong file `README.md`.

### 4. Tích hợp Firebase hoặc Amplify Gen 2 (Thời gian thực)
- **Firebase Authentication hoặc Cognito**:  
  - Hỗ trợ đăng nhập bằng email/mật khẩu và Google Sign-In.  
  - Yêu cầu phân quyền: Chỉ người tạo project mới được phép chỉnh sửa hoặc xóa project.  
- **Firestore hoặc Amplify Gen 2**:  
  - Lưu trữ dữ liệu phân cấp (Project -> Task -> Subtask).  
  - Hỗ trợ **thời gian thực**: Cập nhật giao diện ngay khi dữ liệu thay đổi (ví dụ: dùng `Stream` của Firestore hoặc `DataStore` của Amplify Gen 2).  
  - Tối ưu hóa truy vấn (sử dụng `where`, `limit`, hoặc `startAfter` để tải dữ liệu phân trang).  
- **Firebase Storage hoặc S3**:  
  - Hỗ trợ upload hình ảnh cho task (ví dụ: ảnh minh họa công việc).  
  - Xử lý lỗi upload (kết nối mạng, dung lượng file quá lớn).  
- Xử lý lỗi:  
  - Hiển thị thông báo lỗi thân thiện (ví dụ: "Không thể tải dữ liệu, vui lòng kiểm tra kết nối").  
  - Xử lý trường hợp ngoại tuyến (offline mode) với dữ liệu đã tải trước đó.

### 5. Tối ưu hóa hiệu suất
- Tối ưu hóa thời gian tải dữ liệu:  
  - Sử dụng `StreamBuilder` hoặc `FutureBuilder` để xử lý dữ liệu bất đồng bộ.  
  - Cache dữ liệu cục bộ (sử dụng `shared_preferences` để lưu dữ liệu tạm thời).  
- Tối ưu hóa giao diện:  
  - Sử dụng `ListView.builder` hoặc `GridView.builder` để tải dữ liệu động.  
  - Giảm số lượng widget rebuild bằng cách sử dụng `const` và chia nhỏ widget.  
- Quản lý bộ nhớ:  
  - Dispose các controller, stream subscriptions khi không sử dụng.  
- Phân tích hiệu suất:  
  - Sử dụng công cụ **Flutter DevTools** để đo thời gian render và số lần rebuild.  
  - Cung cấp báo cáo phân tích hiệu suất trong file `README.md`.

### 6. Kiểm thử tự động và CI/CD
- Viết các bài kiểm thử nâng cao:  
  - **Unit test**: Kiểm tra logic nghiệp vụ (ví dụ: tính toán tiến độ project).  
  - **Widget test**: Kiểm tra giao diện (ví dụ: hiển thị danh sách task, tương tác kéo thả).  
  - **Integration test**: Kiểm tra luồng người dùng (ví dụ: đăng nhập -> tạo project -> thêm task).  
- Thiết lập **GitHub Actions**:  
  - Tự động chạy kiểm thử khi có push hoặc pull request.  
  - Phân tích mã nguồn với `flutter analyze` để tìm lỗi tiềm ẩn.  
  - Đảm bảo workflow chạy thành công và không có lỗi.

## Công nghệ và Thư viện sử dụng
- **Flutter**: Xây dựng giao diện người dùng.  
- **Dart**: Ngôn ngữ lập trình chính.  
- **Firebase (firebase_core, cloud_firestore, firebase_auth, firebase_storage) hoặc AWS Amplify**: Tích hợp backend thời gian thực.  
- **shared_preferences**: Lưu trữ dữ liệu cục bộ.  
- **flutter_localizations**: Hỗ trợ đa ngôn ngữ.  
- **flutter_test**: Viết kiểm thử tự động.  
- **GitHub Actions**: Tự động hóa CI/CD.  
- **http** hoặc **dio**: Gọi API bên ngoài (nếu có).  
- **image_picker**: Hỗ trợ chọn và upload hình ảnh.  
- **Không được sử dụng thư viện quản lý trạng thái bên thứ ba** (provider, bloc, riverpod, v.v.).  
- Các thư viện khác tùy chọn theo nhu cầu (phải liệt kê và giải thích trong báo cáo).

## Báo cáo kết quả
Nhóm cần cung cấp tài liệu báo cáo kết quả và hướng dẫn cài đặt ứng dụng:  
1. Tải mã nguồn từ repository:  
    ```bash
    git clone <đường dẫn tới repo>
    ```
2. Cài đặt dependencies:  
    ```bash
    flutter pub get
    ```
3. Cấu hình cho Android/iOS:  
   - Cài đặt FlutterFire CLI: `dart pub global activate flutterfire_cli`.  
   - Chạy lệnh `flutterfire configure` để tạo file `firebase_options.dart`.  
   - Thêm file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) vào thư mục tương ứng.  
4. Phiên bản Flutter/Dart sử dụng:  
   - Flutter: [điền phiên bản, ví dụ: 3.16.0].  
   - Dart: [điền phiên bản, ví dụ: 3.2.0].  
5. Chạy ứng dụng:  
    ```bash
    flutter run
    ```
6. Kiểm thử tự động:  
    ```bash
    flutter test
    ```
7. Báo cáo bổ sung:  
   - Giải thích cách triển khai quản lý trạng thái native.  
   - Báo cáo phân tích hiệu suất (sử dụng Flutter DevTools).  
   - Screenshots hoặc video demo (tối đa 5 phút) về:  
     - Chức năng chính của ứng dụng.  
     - Quá trình kiểm thử tự động (unit test, widget test, integration test).

## Yêu cầu nộp bài
- **Source code**: Đẩy mã nguồn lên GitHub repository của nhóm sau khi nhận bài tập lớn của giảng viên cung cấp trong GitHub Classroom.  
- **Kiểm thử tự động**:  
  - Tổ chức các file kiểm thử trong thư mục `test` (hậu tố `_test.dart`).  
  - Đảm bảo kiểm thử toàn diện (unit test, widget test, integration test).  
- **Video demo** (tối đa 5 phút):  
  - Trình bày chức năng chính (CRUD, tìm kiếm, lọc, kéo thả).  
  - Quá trình kiểm thử tự động.  
- **Báo cáo kết quả**:  
  - Mô tả quá trình phát triển, cách triển khai quản lý trạng thái, và kết quả kiểm thử.  
  - Báo cáo hiệu suất (Flutter DevTools).  
- **GitHub Actions**:  
  - File cấu hình đặt trong `.github/workflows/ci.yml`.  
  - Đảm bảo workflow chạy thành công.  
- **Lưu ý**: Giảng viên sẽ kiểm tra commit history để đánh giá sự đóng góp của từng thành viên trong nhóm.

## Tiêu chí đánh giá
**5/10 điểm - Build thành công (GitHub Actions báo "Success")**  
- Build và kiểm thử cơ bản chạy được, ứng dụng khởi động không lỗi.  

**6/10 điểm - CRUD cơ bản với dữ liệu phân cấp**  
- Hoàn thành CRUD cho dữ liệu phân cấp (Project, Task, Subtask).  

**7/10 điểm - Quản lý trạng thái native và UI cơ bản**  
- Quản lý trạng thái bằng `InheritedWidget`, `ChangeNotifier`, hoặc `ValueNotifier`.  
- Giao diện cơ bản (danh sách project, task, subtask).  

**8/10 điểm - Tích hợp Firebase hoặc AWS Amplify, cập nhật thời gian thực và tối ưu UI**  
- Tích hợp Firebase (Authentication, Firestore, Storage) hoặc AWS Amplify với cập nhật thời gian thực.  
- Tối ưu UI (lazy loading, `const` widgets, giảm rebuild).  

**9/10 điểm - Kiểm thử toàn diện và hiệu suất tối ưu**  
- Kiểm thử đầy đủ (unit, widget, integration).  
- Báo cáo hiệu suất (Flutter DevTools) và tối ưu hóa tốt.  

**10/10 điểm - UI/UX mượt mà, tính năng nâng cao, CI/CD ổn định**  
- UI/UX hoàn hảo (kéo thả, tìm kiếm, lọc, push notifications hoặc tích hợp AI như gợi ý task thông minh).  
- Tích hợp Firebase offline mode hoặc AWS Amplify offline.  
- GitHub Actions chạy ổn định, không lỗi.  

**Tóm tắt các mức điểm:**  
- **5/10**: Build thành công.  
- **6/10**: CRUD dữ liệu phân cấp.  
- **7/10**: Quản lý trạng thái native, UI cơ bản.  
- **8/10**: Tích hợp Firebase hoặc AWS Amplify, tối ưu UI.  
- **9/10**: Kiểm thử toàn diện, hiệu suất tốt.  
- **10/10**: UI/UX mượt mà, tính năng nâng cao, CI/CD ổn định.

## Tự đánh giá điểm: X/10
Nhóm tự đánh giá dựa trên tiêu chí trên và giải thích lý do.

Chúc các bạn hoàn thành tốt bài tập lớn và học hỏi thêm nhiều kỹ năng nâng cao qua dự án này!
