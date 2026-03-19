# Student Manager App (Flutter)

Ứng dụng quản lý sinh viên được xây dựng bằng Flutter và Firebase.

## Tính năng
- 🔐 Đăng nhập (Mặc định: admin / admin123)
- 📊 Dashboard thống kê tổng quan
- 👥 Quản lý danh sách sinh viên (Thêm, Sửa, Xóa, Tìm kiếm)
- 📈 Thống kê biểu đồ (fl_chart)
- ☁️ Lưu trữ dữ liệu thời gian thực (Cloud Firestore)

## Công nghệ sử dụng
- Flutter & Dart
- Firebase (Core, Firestore, Auth)
- Provider (State Management)
- fl_chart (Biểu đồ)
- Google Fonts (Giao diện)

## Cấu trúc thư mục
- `lib/models/`: Chứa các lớp dữ liệu (Student, Class, etc.)
- `lib/screens/`: Các màn hình giao diện ứng dụng
- `lib/services/`: Xử lý logic Database và Authentication
- `lib/widgets/`: Các thành phần giao diện dùng chung
- `lib/utils/`: Các hàm tiện ích (Validation, GPA calculation)
