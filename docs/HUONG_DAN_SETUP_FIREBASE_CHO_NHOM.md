# HƯỚNG DẪN CHI TIẾT SETUP FIREBASE VÀ PHÂN QUYỀN CHO THÀNH VIÊN TRONG NHÓM

> **Tài liệu bàn giao kỹ thuật ứng dụng StudyHub (Flutter)**  
> **Dành cho:** Thành viên trong nhóm nhận trách nhiệm tạo Firebase Project mới & AI Assistant hỗ trợ thực hiện.  
> **Mục tiêu:** Tạo mới Firebase Project có đầy đủ Authentication, Cloud Storage, cấu hình vào source code và phân quyền lại cho Owner ban đầu.

---

## 1. TỔNG QUAN TÌNH HÌNH & LÝ DO CHUYỂN GIAO

- **Hiện trạng ứng dụng:** Đã hoàn thiện toàn bộ mã nguồn Flutter bao gồm:
  - Local-First SQLite Database (Drift ORM) quản lý môn học, tài liệu PDF/Word.
  - Tích hợp **Firebase Authentication** (Google Sign-In).
  - Tích hợp **Firebase Cloud Storage** để sao lưu tài liệu trực tiếp lên Cloud.
  - Hộp thoại đồng bộ đa nền tảng (`GoogleSyncDialog`).
- **Lý do chuyển giao:** Tài khoản Google hiện tại của thành viên phụ trách gặp vướng mắc về bước xác minh thẻ thanh toán khi kích hoạt Cloud Storage / Google Cloud. Do đó, chuyển giao việc khởi tạo Firebase Project cho bạn (thành viên có tài khoản sạch hoặc có thẻ để kích hoạt dự án).
- **Trách nhiệm của bạn:** Thực hiện theo các bước dưới đây trên Firebase Console, cập nhật file cấu hình vào code, sau đó thêm email của bạn kia làm **Owner** để cả 2 cùng quản lý.

---

## 2. QUY TRÌNH THỰC HIỆN TỪNG BƯỚC (STEP-BY-STEP)

### BƯỚC 1: TẠO FIREBASE PROJECT MỚI
1. Truy cập vào **[Firebase Console](https://console.firebase.google.com/)** bằng tài khoản Google của bạn.
2. Bấm nút **Add project** (Tạo dự án mới).
3. Đặt tên dự án (ví dụ: `studyhub-mobile` hoặc `studyhub-cloud`).
4. Bấm **Continue** $\rightarrow$ ở bước Google Analytics có thể bật hoặc tắt (tùy ý) $\rightarrow$ Bấm **Create project**.
5. Đợi Firebase khởi tạo xong, bấm **Continue** để vào màn hình Dashboard.

---

### BƯỚC 2: KÍCH HOẠT VÀ MỞ QUYỀN FIREBASE STORAGE (BẮT BUỘC)
> ⚠️ **LƯU Ý CỰC KỲ QUAN TRỌNG:** Đây là nguyên nhân gây lỗi *"Đã sao lưu 0 tài liệu"* nếu không làm đúng. Mặc định Firebase khóa toàn bộ quyền ghi (`if false;`).

1. Ở thanh menu bên trái, tìm mục **Build** $\rightarrow$ Chọn **Storage** (Lưu trữ).
2. Bấm **Get started** (Bắt đầu).
3. Chọn chế độ **Start in test mode** (hoặc cứ Next qua).
4. Chọn vị trí lưu trữ Cloud Storage location: chọn cụm châu Á gần Việt Nam (ví dụ: `asia-southeast1` - Singapore hoặc `asia-east1`). Bấm **Done**.
5. Sau khi tạo xong, chuyển ngay sang tab **Rules (Quy tắc)** ở phía trên:
   - Xóa bỏ rule mặc định và dán nội dung sau:
     ```javascript
     rules_version = '2';
     service firebase.storage {
       match /b/{bucket}/o {
         match /{allPaths=**} {
           allow read, write: if true; // Cho phép đọc và ghi trong quá trình test
         }
       }
     }
     ```
     *(Hoặc bảo mật hơn: `allow read, write: if request.auth != null;`)*
   - Bấm nút **Publish (Xuất bản)** để áp dụng.

---

### BƯỚC 3: KÍCH HOẠT GOOGLE SIGN-IN TRONG FIREBASE AUTHENTICATION
1. Ở menu bên trái, chọn **Build** $\rightarrow$ **Authentication**.
2. Bấm **Get started**.
3. Chọn tab **Sign-in method** $\rightarrow$ chọn nhà cung cấp **Google**.
4. Gạt công tắc sang **Enable** (Bật).
5. Nhập **Project public-facing name**: `StudyHub`.
6. Chọn **Project support email** là email Google của bạn.
7. Bấm **Save (Lưu)**.

---

### BƯỚC 4: THÊM ỨNG DỤNG ANDROID VÀ GẮN MÃ SHA-1
1. Vào **Project Settings** (Bấm icon Bánh răng ở góc trên bên trái menu $\rightarrow$ **Project settings**).
2. Cuộn xuống phần **Your apps** $\rightarrow$ bấm vào icon **Android** để thêm app.
3. Điền thông tin chính xác:
   - **Android package name (BẮT BUỘC):** `com.studyhub.studyhub`
   - **App nickname:** `StudyHub Android`
4. **Thêm mã chứng chỉ SHA-1 (Debug signing certificate SHA-1):**
   > ⚠️ **LỖI NGUY HIỂM:** Nếu không thêm SHA-1, ứng dụng sẽ dính ngay lỗi `ApiException: 10 (DEVELOPER_ERROR)` khi đăng nhập Google.

   - **Mã SHA-1 số 1 (Máy của bạn tạo app):** Dán mã SHA-1 của bạn ban đầu:
     ```text
     C8:7A:A5:3B:00:94:3A:81:7A:EF:0E:28:D9:04:D2:7D:DC:3F:D6:4A
     ```
   - **Mã SHA-1 số 2 (Máy tính của bạn - nếu bạn cũng chạy code trên máy bạn):**
     Mở terminal tại thư mục `android/` và chạy lệnh:
     ```bash
     ./gradlew signingReport
     ```
     Tìm dòng `SHA1` của biến thể `debug` (dạng `XX:XX:XX:...`), sao chép và bấm **Add fingerprint** để dán thêm vào Firebase.
5. Bấm **Register app**.

---

### BƯỚC 5: TẢI VÀ THAY THẾ FILE `google-services.json`
1. Sau khi đăng ký app Android, Firebase sẽ cho bạn tải file **`google-services.json`**. (Hoặc tải lại bất kỳ lúc nào tại **Project settings** $\rightarrow$ Your apps).
2. Tải file về và chép đè vào đúng đường dẫn sau trong dự án:
   ```text
   android/app/google-services.json
   ```
   *(Chú ý: Đặt vào `android/app/`, không đặt ở thư mục cha `android/`)*.

---

### BƯỚC 6: CẬP NHẬT CODE DỰ ÁN VỚI THÔNG SỐ PROJECT MỚI

Mở file `android/app/google-services.json` vừa tải để lấy các thông số, sau đó cập nhật 2 vị trí sau:

#### 1. Cập nhật Web Client ID trong `lib/core/services/firebase_service.dart`
- Trong file `google-services.json`, tìm mục `"oauth_client"` có `"client_type": 3`. Giá trị `"client_id"` ở đó chính là **Web Client ID** (có đuôi `.apps.googleusercontent.com`).
- Hoặc lấy trên Firebase Console: **Authentication** $\rightarrow$ **Sign-in method** $\rightarrow$ **Google** $\rightarrow$ mục **Web SDK configuration** $\rightarrow$ copy **Web client ID**.
- Mở file: `lib/core/services/firebase_service.dart`:
  ```dart
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: 'DÁN_WEB_CLIENT_ID_MỚI_VÀO_ĐÂY',
    scopes: ['email', 'profile'],
  );
  ```

#### 2. Cập nhật thông số trong `lib/firebase_options.dart`
Mở file `lib/firebase_options.dart`, cập nhật các trường trong `DefaultFirebaseOptions.android` bằng thông tin từ `google-services.json` mới:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'LẤY_TỪ_CURRENT_KEY_TRONG_JSON',
  appId: 'LẤY_TỪ_MOBIELSDK_APP_ID_TRONG_JSON',
  messagingSenderId: 'LẤY_TỪ_PROJECT_NUMBER_TRONG_JSON',
  projectId: 'TÊN_PROJECT_ID_MỚI',
  storageBucket: 'TÊN_PROJECT_ID_MỚI.firebasestorage.app',
);
```
*(Nếu máy có cài đặt FlutterFire CLI, bạn chỉ cần gõ lệnh `flutterfire configure` để nó tự sinh lại file này)*.

---

### BƯỚC 7: BẬT GOOGLE DRIVE API (TRÁNH LỖI 403 KHI ĐỒNG BỘ SONG SONG)
1. Truy cập vào **[Google Cloud Console](https://console.cloud.google.com/)**.
2. Ở thanh chọn dự án phía trên, chọn đúng Project Firebase bạn vừa tạo ở Bước 1.
3. Ở ô tìm kiếm trên cùng, gõ: `Google Drive API`.
4. Chọn kết quả **Google Drive API** $\rightarrow$ Bấm nút **Enable (Bật)**.
5. Điều này giúp tính năng đồng bộ tệp song song lên Google Drive hoạt động trơn tru không bị lỗi 403.

---

### BƯỚC 8: PHÂN QUYỀN CHO THÀNH VIÊN TRONG NHÓM (ADD OWNER)
Để bạn ban đầu (và các thành viên khác) cùng có quyền truy cập, quản lý và kiểm tra file tải lên:
1. Trên trang **Firebase Console** $\rightarrow$ bấm vào icon Bánh răng ⚙️ $\rightarrow$ **Project settings**.
2. Chuyển sang tab **Users and permissions** (Người dùng và quyền).
3. Bấm nút **Add member** (Thêm thành viên).
4. Nhập địa chỉ Gmail của bạn trong nhóm.
5. Tại mục **Role(s)** (Vai trò):
   - Chọn vai trò: **Owner** (Chủ sở hữu) để có toàn quyền quản trị và cấu hình.
   - (Hoặc **Editor** nếu chỉ cần xem và chỉnh sửa cơ sở dữ liệu/storage).
6. Bấm **Done** $\rightarrow$ **Add member**.
7. Người kia sẽ nhận được email thông báo và có thể truy cập dự án ngay lập tức từ tài khoản của mình.

---

## 3. BẢNG TỔNG HỢP CÁC LỖI ĐÃ TỪNG GẶP & CÁCH AI GIẢI QUYẾT NHANH

| Lỗi gặp phải | Nguyên nhân gốc rễ | Cách xử lý dứt điểm |
| :--- | :--- | :--- |
| **`ApiException: 10 (DEVELOPER_ERROR)`** khi đăng nhập Google | Chưa gắn mã vân tay SHA-1 của máy chạy debug vào Firebase Console, hoặc `serverClientId` không khớp. | 1. Chạy `./gradlew signingReport` lấy SHA-1.<br>2. Dán SHA-1 vào Firebase Project Settings $\rightarrow$ Android app.<br>3. Điền đúng Web Client ID vào `firebase_service.dart`. |
| **Báo "Đã sao lưu 0 tài liệu"** khi bấm sao lưu Storage | Rules của Firebase Storage mặc định bị khóa `allow read, write: if false;`, hoặc tài liệu chỉ lưu Base64 mà code cũ chưa trích xuất. | 1. Vào Firebase Storage $\rightarrow$ Tab **Rules** $\rightarrow$ đổi thành `allow read, write: if true;` (hoặc `if request.auth != null;`) $\rightarrow$ Publish.<br>2. Code hiện tại đã tích hợp fallback tự động giải mã Base64. |
| **Lỗi `403 Google Drive API disabled`** | Tài khoản có liên kết Google Drive nhưng project trên Google Cloud chưa bật thư viện API. | Vào Google Cloud Console $\rightarrow$ Tìm Google Drive API $\rightarrow$ Bấm **Enable**. |
| **Trùng lặp primary key tài liệu (`Value.absent()`)** | Trình tạo tài liệu trước đó gán nhầm chuỗi tĩnh. | Đã được khắc phục hoàn toàn trong code (sử dụng UUID clientDefault của Drift). |

---

## 4. CÁCH KIỂM TRA FILE ĐÃ LÊN FIREBASE STORAGE THÀNH CÔNG CHƯA
1. Mở ứng dụng StudyHub trên máy điện thoại / máy ảo.
2. Mở hộp thoại đồng bộ $\rightarrow$ Đăng nhập Google $\rightarrow$ Bấm **"Sao lưu tài liệu lên Firebase Storage"**.
3. Thông báo hiển thị: *"Đã sao lưu thành công X tài liệu lên Firebase Storage!"*.
4. Mở **Firebase Console** $\rightarrow$ **Storage** $\rightarrow$ tab **Files**:
   - Thư mục sẽ xuất hiện: `studyhub_users/{userId}/documents/{mã_tài_liệu}/{tên_file}.pdf`.
   - Bấm vào file PDF để xem kích thước, metadata và link tải trực tiếp.
