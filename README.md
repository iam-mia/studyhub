# StudyHub 📚

> **Hệ thống Quản lý Tài liệu Học tập Thông minh** xây dựng trên nền tảng **Flutter**, lấy cảm hứng từ triết lý kiến trúc **Local-First & Design System của Cashew App**.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Material 3](https://img.shields.io/badge/Design-Material%203-7C4DFF)](https://m3.material.io)
[![Architecture](https://img.shields.io/badge/Architecture-Cashew%20Local--First-2E7D32)](#kiến-trúc-hệ-thống)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 🌟 Tính năng Nổi bật

### 1. 📂 Quản lý Môn học & Phân nhóm
- Phân nhóm tài liệu theo từng môn học trực quan với bảng màu và icon đặc trưng.
- Theo dõi thống kê số lượng tài liệu theo từng môn.
- Tạo, chỉnh sửa tên và mã môn học linh hoạt.

### 2. 📄 Quản lý Tài liệu Đa định dạng & Tự động Nhận diện
- **Hỗ trợ đa định dạng:** PDF, Word (.docx, .doc), PowerPoint (.pptx, .ppt), và Liên kết trực tuyến (URL).
- **Nhận diện tự động:** Tự động phân tích đuôi tệp tải lên mà không cần chọn thủ công.
- **Phân loại danh mục chuyên sâu (Category):**
  - 📖 *Bài giảng*
  - 📑 *Tài liệu tham khảo*
  - 📝 *Bài tập*
  - 📊 *Đề kiểm tra*
- **Ghi chú & Metadata:** Lưu trữ ngày tạo, dung lượng, ghi chú tóm tắt nội dung tự động co giãn.

### 3. 👁️ Xem trước & Tải xuống Trực tiếp
- **PDF Viewer tích hợp:** Đọc tệp PDF trực tiếp trong ứng dụng mà không cần phần mềm bên ngoài.
- **Tải xuống nhanh chóng:** 1 chạm tải file về máy hoặc mở liên kết gốc trên trình duyệt.
- Hàng 4 nút thao tác chuẩn hoá, căn chỉnh hoàn hảo: `[Xem trước]`, `[Tải xuống]`, `[Sửa]`, `[Xoá]`.

### 4. 🔍 Tìm kiếm & Bộ lọc Nhanh
- Tìm kiếm tức thì (Real-time debounced) theo tên tài liệu, ghi chú và môn học.
- Lọc theo Môn học và Phân loại tài liệu.
- Đánh dấu tài liệu quan trọng (Gắn dấu sao ⭐) và lọc nhanh danh sách quan trọng.

### 5. ☁️ Kiến trúc Local-First & Đồng bộ Google Drive
- **Hoạt động Offline 100%:** Dữ liệu lưu cục bộ bằng Drift (SQLite) hiệu năng cao, phản hồi tức thì không có độ trễ mạng.
- **Đồng bộ Đám mây (Cloud Sync):** Tích hợp Google Sign-In và Google Drive API v3 để sao lưu và đồng bộ an toàn qua thư mục ẩn của ứng dụng (`appDataFolder`).

---

## 🏗️ Kiến trúc Hệ thống (Cashew Architecture)

Dự án áp dụng mô hình phân lớp rõ ràng theo tiêu chuẩn kiến trúc phần mềm hiện đại:

```
lib/
├── core/                       # Core utilities & constants
│   ├── constants/              # App strings, colors, dimensions
│   ├── theme/                  # Material 3 Theme & Typography
│   └── utils/                  # File helpers, date formatters
├── data/                       # Data Layer (Local-First)
│   ├── datasources/            # Local SQLite (Drift) & Remote API
│   │   └── local/              # Drift Database & Migrations
│   ├── models/                 # Drift tables & data models
│   └── repositories/           # Repository implementations
├── domain/                     # Domain Layer (Business Logic)
│   ├── entities/               # Pure business models
│   └── repositories/           # Abstract repository contracts
├── presentation/               # Presentation Layer
│   ├── providers/              # State management (Riverpod/Provider)
│   ├── screens/                # UI Screens (Dashboard, Viewer, Settings)
│   └── widgets/                # Reusable Material 3 Components
└── services/                   # Background & Third-party services
    └── sync/                   # Google Drive API Sync Service
```

---

## 📸 Tài liệu & Thiết kế Kỹ thuật

Tất cả tài liệu phân tích nghiệp vụ, kiến trúc, sơ đồ luồng dữ liệu (DFD), và bộ test case được biên soạn đầy đủ trong thư mục `docs/`:

- [Tài liệu Phân tích Yêu cầu Chức năng (SRS)](docs/TAI_LIEU_PHAN_TICH_YEU_CAU_CHUC_NANG.md) *(kèm bản `.docx` hoàn chỉnh)*
- [Báo cáo Giải trình Kiến trúc Cashew](docs/BAO_CAO_GIAI_TRINH_KIEN_TRUC_CASHEW.md) *(kèm bản `.docx` hoàn chỉnh)*
- [Sơ đồ Luồng Dữ liệu (DFD Level 0 & Level 1)](docs/SO_DO_LUONG_DU_LIEU_DFD.md)
- [Tài liệu Bộ Test Case Kiểm thử (10/10 PASS)](docs/TAI_LIEU_TESTCASE.md)

---

## 🚀 Cài đặt & Chạy Ứng dụng

### Yêu cầu Tiên quyết
- **Flutter SDK**: `>=3.3.0`
- **Dart SDK**: `>=3.3.0`
- Thiết bị thử nghiệm (Android/iOS) hoặc Chrome/Edge Browser

### Các bước cài đặt

1. **Clone repository:**
   ```bash
   git clone https://github.com/iam-mia/studyhub.git
   cd studyhub
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Tạo mã tự động (Drift & Mappers):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Chạy ứng dụng:**
   - Trên Chrome (Web):
     ```bash
     flutter run -d chrome
     ```
   - Trên Android Device/Emulator:
     ```bash
     flutter run
     ```

5. **Chạy kiểm thử:**
   ```bash
   flutter test
   ```

---

## 👥 Nhóm Tác giả & Đóng góp
Dự án được xây dựng và phát triển phục vụ học phần Phát triển Ứng dụng Thiết bị Di động (CSE441).
