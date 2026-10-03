# 📊 SƠ ĐỒ LUỒNG DỮ LIỆU (DATA FLOW DIAGRAM - DFD)
## DỰ ÁN: STUDYHUB - HỆ THỐNG QUẢN LÝ TÀI LIỆU HỌC TẬP THÔNG MINH

---

## 1. SƠ ĐỒ NGỮ CẢNH HỆ THỐNG (DFD MỨC 0 - CONTEXT DIAGRAM)

Sơ đồ thể hiện tương tác dữ liệu tổng quan giữa Người dùng, Hệ thống StudyHub và các kho lưu trữ cục bộ.

```mermaid
flowchart TD
    User(["👤 Người dùng (Sinh viên / Giảng viên)"])
    
    subgraph System ["Hệ thống StudyHub (Local-First Application)"]
        StudyHub["Ứng dụng StudyHub\n(Flutter + Drift ORM + MultiExecutor)"]
    end

    FileSystem[("💾 Bộ nhớ tệp cục bộ\n(studyhub_files)")]
    DriftDB[("🗄️ CSDL SQLite Cục bộ\n(studyhub.sqlite)")]

    User -- "1. Nhập thông tin môn học, tài liệu, liên kết, tìm kiếm, gắn sao" --> StudyHub
    StudyHub -- "2. Hiển thị danh sách môn học, tài liệu, xem PDF, trạng thái sao" --> User
    
    StudyHub -- "3. Lưu tệp đính kèm (PDF, DOCX, PPTX)" --> FileSystem
    FileSystem -- "4. Trả về luồng byte dữ liệu tệp" --> StudyHub

    StudyHub -- "5. Ghi bản ghi (Background Isolate Write)" --> DriftDB
    DriftDB -- "6. Đọc phản ứng (Foreground Reactive Stream Read)" --> StudyHub
```

---

## 2. SƠ ĐỒ PHÂN RÃ CHỨC NĂNG (DFD MỨC 1 - SYSTEM PROCESSES)

Sơ đồ phân rã các tiến trình nghiệp vụ cốt lõi bên trong StudyHub.

```mermaid
flowchart TB
    User(["👤 Người dùng"])

    subgraph Processes ["Các Tiến trình Xử lý Chính"]
        P1["1.0 Quản lý Môn học\n(Subject CRUD)"]
        P2["2.0 Quản lý Tài liệu\n(Document CRUD)"]
        P3["3.0 Lưu trữ & Đọc Tệp\n(File Storage Engine)"]
        P4["4.0 Xem & Xuất Tệp\n(In-app PDF & Export)"]
        P5["5.0 Tìm kiếm & Sắp xếp\n(Reactive Query Engine)"]
        P6["6.0 Xử lý Tombstone\n(Safe Deletion Engine)"]
    end

    subgraph DataStores ["Kho Lưu Trữ Dữ Liệu"]
        D_Sub[("D1: Bảng Subjects")]
        D_Doc[("D2: Bảng Documents")]
        D_Log[("D3: Bảng DeleteLogs")]
        D_File[("D4: Thư mục Tệp App")]
    end

    %% Process 1
    User -->|"Thông tin môn học"| P1
    P1 -->|"Ghi/Cập nhật"| D_Sub
    D_Sub -->|"Danh sách môn học"| P1
    P1 -->|"Hiển thị thẻ môn học"| User

    %% Process 2
    User -->|"Chọn tệp/link tài liệu"| P2
    P2 -->|"Yêu cầu sao chép tệp"| P3
    P3 -->|"Lưu trữ tệp vật lý"| D_File
    P3 -->|"Trả về đường dẫn an toàn"| P2
    P2 -->|"Lưu metadata (kích thước, loại, ngày)"| D_Doc

    %% Process 3 & 4
    User -->|"Yêu cầu xem PDF / Tải xuống"| P4
    P4 -->|"Đọc tệp"| D_File
    P4 -->|"Hiển thị trang PDF / Xuất tệp"| User

    %% Process 5
    User -->|"Từ khóa, Môn học, Loại tệp, Thứ tự"| P5
    D_Doc -.->|"Stream phản ứng"| P5
    D_Sub -.->|"Thông tin liên kết"| P5
    P5 -->|"Danh sách tài liệu đã lọc/sắp xếp"| User

    %% Process 6
    User -->|"Yêu cầu xóa môn/tài liệu"| P6
    P6 -->|"Xóa bản ghi"| D_Doc
    P6 -->|"Xóa bản ghi môn"| D_Sub
    P6 -->|"Ghi nhật ký xóa (Tombstone)"| D_Log
```

---

## 3. SƠ ĐỒ CHI TIẾT CÁC LUỒNG DỮ LIỆU ĐẶC THÙ (DFD MỨC 2)

### 3.1. Luồng Thêm Mới Tài liệu (Add Document Flow)
```mermaid
sequenceDiagram
    autonumber
    actor U as Người dùng
    participant UI as AddEditDocumentSheet
    participant FS as FileStorageService
    participant LocalDisk as Thư mục Cục bộ
    participant DAO as DocumentDao
    participant MultiExec as MultiExecutor (Background Isolate)
    participant SQLite as studyhub.sqlite

    U->>UI: Chọn tệp từ máy (PDF/Word/PPT) hoặc nhập URL
    UI->>FS: pickDocumentFile()
    FS-->>UI: Trả về file, tên tệp, kích thước & loại tài liệu
    U->>UI: Nhập tên tài liệu, chọn môn học, nhấn "Thêm tài liệu"
    UI->>FS: copyFileToLocalStorage(sourcePath, name)
    FS->>LocalDisk: Ghi bản sao vào /studyhub_files/
    LocalDisk-->>FS: Hoàn tất sao chép
    FS-->>UI: Trả về savedPath
    UI->>DAO: insertOrUpdateDocument(DocumentsCompanion)
    DAO->>MultiExec: Chuyển lệnh Ghi sang Isolate ngầm
    MultiExec->>SQLite: INSERT ON CONFLICT DO UPDATE
    SQLite-->>MultiExec: Ghi đĩa thành công
    MultiExec-->>DAO: Hoàn tất Transaction
    DAO-->>UI: Cập nhật thành công, đóng Bottom Sheet
```

### 3.2. Luồng Phản ứng Truy vấn Dữ liệu (Reactive Watch Query Flow)
```mermaid
sequenceDiagram
    autonumber
    actor U as Người dùng
    participant Screen as DocumentsScreen (StreamBuilder)
    participant DAO as DocumentDao
    participant Foreground as NativeDatabase (Foreground)
    participant SQLite as studyhub.sqlite

    Screen->>DAO: watchFilteredDocuments(query, subjectPk, type, sortBy)
    DAO->>Foreground: Lắng nghe bảng Documents với điều kiện lọc
    Foreground->>SQLite: SELECT * FROM documents WHERE ...
    SQLite-->>Foreground: Trả về tập dữ liệu ban đầu
    Foreground-->>DAO: Phát sinh Stream<List<Document>>
    DAO-->>Screen: Snapshot cập nhật -> Render DocumentCard
    Note over Screen,SQLite: Khi có thao tác INSERT/UPDATE/DELETE xảy ra ở Isolate ngầm:
    SQLite-->>Foreground: Bắn tín hiệu Table-Modified
    Foreground->>SQLite: Tự động chạy lại câu SELECT
    SQLite-->>Foreground: Trả về tập dữ liệu mới
    Foreground-->>DAO: Tự động phát Emit mới vào Stream
    DAO-->>Screen: StreamBuilder tự vẽ lại UI tức thì (No-Refresh)
```

### 3.3. Luồng Xóa An Toàn & Cơ chế Tombstone (Cashew Deletion Architecture)
```mermaid
sequenceDiagram
    autonumber
    actor U as Người dùng
    participant UI as DocumentCard / Sheet
    participant DAO as DocumentDao / SubjectDao
    participant SQLite as studyhub.sqlite

    U->>UI: Chọn "Xoá tài liệu" -> Xác nhận Dialog
    UI->>DAO: deleteDocumentSafely(pk)
    Note over DAO,SQLite: Bắt đầu SQLite Transaction
    DAO->>SQLite: DELETE FROM documents WHERE document_pk = pk
    DAO->>SQLite: INSERT INTO delete_logs (entry_pk, type, date_time_modified) VALUES (pk, 'document', NOW())
    Note over DAO,SQLite: Hoàn tất Transaction (Commit)
    SQLite-->>DAO: Thành công
    DAO-->>UI: Cập nhật trạng thái
    Note over UI: UI tự động biến mất nhờ StreamBuilder nhận sự kiện xóa
```
