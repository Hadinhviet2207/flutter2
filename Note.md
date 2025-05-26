# Task Manager App

## Giới thiệu
Ứng dụng quản lý công việc tương tự Trello, hỗ trợ làm việc cá nhân mà không cần đăng nhập, CRUD dữ liệu phân cấp (Task lồng Task), tích hợp Firebase thời gian thực, quản lý trạng thái native, đăng nhập/đăng ký, phân quyền chi tiết, và mời người dùng qua link.

## Cấu trúc dự án
- **lib/models/**: Chứa các model (Project, Task, User, Comment, TaskHistory, ProjectInvite)
- **lib/services/**: Chứa AuthService, FirestoreService, UserService
- **lib/screens/**: Chứa các màn hình (Login, Register, Project List, Kanban Board, Task Detail, Profile, Invite List)
- **lib/utils/**: Chứa EnumUtils để xử lý enum

## Các tính năng chính

### 1. Làm việc ẩn danh
- Tạo Project/Task với anonymousUserId lưu trong SharedPreferences
- Tự động thêm anonymousUserId vào memberIds của Project

### 2. Chuyển tài khoản thật
- Cập nhật ownerId và createdBy sang uid khi đăng nhập
- Lưu previousAnonymousId trong User

### 3. Task Model
- Hỗ trợ phân cấp sâu với parentTaskId (Dự kiến)
- TaskStatus: Mô phỏng Kanban với backlog, todo, inProgress, blocked, done, cancelled (Trạng thái task)

### 4. Comment Model
- Hỗ trợ @thành viên
- Đính kèm file

### 5. ProjectInvite Model
- Quản lý lời mời với trạng thái pending, accepted, rejected

### 6. Phân quyền
- Quản lý tạo/xóa/phân chia nhiệm vụ
- Thành viên chỉnh sửa task được giao/tự tạo/Chỉnh sửa task của abnr thân/Xem task khác trong project
- Validation: Mỗi model có hàm validate()

## Quản lý trạng thái
- **ChangeNotifier**: Quản lý danh sách project/task/user
- **ValueNotifier**: Quản lý trạng thái loading
- **InheritedWidget**: Truyền dữ liệu với AppStateWidget
- **Tối ưu hóa**: Chỉ rebuild widget bị ảnh hưởng

## Tích hợp Firebase

### Authentication
- Đăng nhập/đăng ký bằng email(sdt) và Google Sign-In
- Hỗ trợ ẩn danh(Không yêu cầu đăng nhập khi không cần thiết)

### Firestore
- Lưu trữ dữ liệu phân cấp (projects/{projectId}/tasks/{taskId})
- Thời gian thực với StreamBuilder

### Storage (Sử dụng cloudinary nếu không có firebase storage)
- Upload ảnh và file đính kèm

### Security Rules
- Hỗ trợ người dùng ẩn danh (ownerId == null hoặc createdBy == null)
- Tách create và update với request.resource.data
- Quyền dựa trên memberIds, ownerId, createdBy, assignedTo