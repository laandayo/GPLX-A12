# PHỤ LỤC KỸ THUẬT — ỨNG DỤNG DI ĐỘNG GPLX
## "XÂY DỰNG ỨNG DỤNG DI ĐỘNG HỖ TRỢ ÔN TẬP LÝ THUYẾT SÁT HẠCH GPLX HẠNG A1 & A2"

*(Bổ sung kỹ thuật thay thế cho Chương 3 của đề tài chính — các phần khác giữ nguyên)*

---

## 1. PHÂN TÍCH YÊU CẦU HỆ THỐNG

### 1.1. Khác biệt so với phần mềm Desktop

| Tiêu chí | Phần mềm Desktop (Cũ) | Ứng dụng di động GPLX (Mới) |
|---|---|---|
| **Nền tảng** | Windows 7+, Desktop | Android, iOS (Mobile) |
| **Ngôn ngữ** | C# (.NET Framework) | Dart + Flutter Framework |
| **Dữ liệu** | Lớp tĩnh (static class) — cứng trong code | JSON files trong assets — tách rời code |
| **Quản lý trạng thái** | Không có | Provider (ChangeNotifier) |
| **Giao diện** | Windows Forms | Material 3, responsive |
| **Theme** | Không hỗ trợ | Light / Dark / System |
| **Lưu trữ** | Không lưu | SharedPreferences (bộ nhớ cục bộ) |
| **Hạng bằng** | Ô tô (B1, B2, C, D...) | Mô tô (A1, A2) |
| **Bộ câu hỏi** | 600 câu | 250 câu (A1) / ~400 câu (A2) |
| **Cấu trúc đề thi** | 25 câu | 30 câu, điểm đạt 23 |

### 1.2. Mục tiêu của ứng dụng
- Hỗ trợ học viên ôn tập **trên điện thoại di động**, học mọi lúc mọi nơi
- Dữ liệu câu hỏi **tách rời khỏi mã nguồn** (JSON), dễ cập nhật không cần build lại app
- Hỗ trợ **hai chế độ giao diện** (Sáng/Tối) theo hệ thống
- **Lưu tiến độ học tập** cục bộ: câu đã trả lời, câu sai, câu đánh dấu, kết quả thi
- Chế độ thi thử mô phỏng **đúng cấu trúc 30 câu / đạt 23**
- Hai chế độ chấm điểm: **ngay lập tức** (ôn tập) và **sau khi nộp bài** (thi)

### 1.3. Đối tượng sử dụng
- **Học viên** học bằng lái xe mô tô hạng A1 (dưới 175 cm³) và A2 (trên 175 cm³)
- **Giảng viên** sử dụng làm công cụ hỗ trợ giảng dạy

### 1.4. Yêu cầu chức năng
| Chức năng | Mô tả |
|---|---|
| Ôn tập theo câu hỏi | Duyệt tuần tự từng câu, xem giải thích ngay |
| Ôn tập theo chương | Lọc câu hỏi theo 5 chương kiến thức |
| Lọc câu hỏi | Theo: Đã đánh dấu, Câu sai, Chưa trả lời, Quan trọng |
| Thi thử | Chọn từ danh sách đề có sẵn hoặc ngẫu nhiên |
| Danh mục câu hỏi | Xem tất cả câu hỏi, tìm kiếm theo nội dung, lọc |
| Thống kê | Tiến độ theo chương, tỉ lệ chính xác, streak |
| Cài đặt | Chuyển theme, chế độ chấm điểm, tự động chuyển câu |
| Tra cứu nhanh | Tìm kiếm text trong nội dung câu hỏi |

### 1.5. Yêu cầu phi chức năng
| Yêu cầu | Mô tả |
|---|---|
| **Tốc độ** | Tải câu hỏi < 1 giây (dữ liệu local) |
| **Offline** | Hoạt động hoàn toàn không cần Internet |
| **Dung lượng** | Ứng dụng gọn nhẹ (< 50 MB sau khi cài đặt) |
| **Giao diện** | Material 3, responsive, hỗ trợ Dark Mode |
| **Tương thích** | Android 5.0+ (API 21+), iOS 12.0+ |
| **Dễ bảo trì** | Thêm/sửa câu hỏi chỉ cần chỉnh file JSON |
| **Bảo mật** | Không thu thập dữ liệu người dùng |

---

## 2. THIẾT KẾ HỆ THỐNG

### 2.1. Sơ đồ Use Case

```
┌─────────────────────────────────────────────────┐
│              Ứng dụng GPLX Mobile               │
│                                                 │
│  ┌─────────────┐     ┌──────────────────────┐   │
│  │  Học viên   │────▶│  Xem danh sách đề thi │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Ôn tập theo chương   │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Làm bài thi thử      │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Xem thống kê tiến độ │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Tra cứu câu hỏi      │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Chuyển đổi A1 ↔ A2   │   │
│  │             │     └──────────────────────┘   │
│  │             │     ┌──────────────────────┐   │
│  │             │────▶│  Đổi giao diện sáng/tối│   │
│  └─────────────┘     └──────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### 2.2. Kiến trúc phân lớp (Layered Architecture)

```
┌──────────────────────────────────────────────────┐
│                  Presentation Layer              │
│  ┌────────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  Screens   │  │ Widgets  │  │   Main.dart  │ │
│  │ (UI pages) │  │ (reusable│  │  (entry point│ │
│  │            │  │  comps)  │  │   + routing) │ │
│  └─────┬──────┘  └────┬─────┘  └──────┬───────┘ │
└────────┼──────────────┼───────────────┼─────────┘
         │              │               │
┌────────┼──────────────┼───────────────┼─────────┐
│        │    Provider Layer (State Management)    │
│  ┌─────┴──────┐  ┌───┴────┐  ┌────┴──────────┐  │
│  │AppProvider │  │Question│  │Statistics     │  │
│  │(theme,     │  │Provider│  │Provider       │  │
│  │ settings)  │  │(session│  │(analytics)    │  │
│  │            │  │ state) │  │               │  │
│  └─────┬──────┘  └───┬────┘  └────┬──────────┘  │
└────────┼──────────────┼────────────┼─────────────┘
         │              │            │
┌────────┼──────────────┼────────────┼─────────────┐
│        │       Data & Services Layer             │
│  ┌─────┴──────┐  ┌───┴────────┐ ┌┴────────────┐  │
│  │Question    │  │QuestionJson│ │ExamPersistence│ │
│  │Repository  │  │Service     │ │Service        │ │
│  │(gateway)   │  │(load JSON) │ │(save results) │ │
│  └─────┬──────┘  └────┬───────┘ └──┬───────────┘  │
└────────┼──────────────┼────────────┼──────────────┘
         │              │            │
┌────────┼──────────────┼────────────┼──────────────┐
│        │    Domain Layer (Models)                 │
│  ┌─────┴────┐  ┌────┴────┐  ┌───┴────┐  ┌──────┐  │
│  │Question  │  │ Chapter │  │  Exam  │  │Test  │  │
│  │          │  │         │  │        │  │Attempt│  │
│  └──────────┘  └─────────┘  └────────┘  └──────┘  │
└───────────────────────────────────────────────────┘
         │              │            │
┌────────┼──────────────┼────────────┼──────────────┐
│        │       External Resources                 │
│  ┌─────┴──────┐  ┌───┴────────┐ ┌┴─────────────┐  │
│  │ JSON files │  │  Images    │ │SharedPreferences│
│  │ (assets/   │  │(assets/    │ │ (local storage) │
│  │ questions/)│  │ images/)   │ │                 │
│  └────────────┘  └────────────┘ └────────────────┘
└────────────────────────────────────────────────────┘
```

### 2.3. Cấu trúc thư mục dự án

```
gplx_app/
├── lib/
│   ├── main.dart                          # Entry point, app initialization
│   ├── models/
│   │   ├── license_type.dart              # Enum: A1, A2
│   │   ├── question.dart                  # Question model + status
│   │   ├── chapter.dart                   # Chapter metadata
│   │   ├── exam.dart                      # Exam definition
│   │   └── test_attempt.dart             # Test attempt record
│   ├── providers/
│   │   ├── app_provider.dart             # Theme, settings, license type
│   │   ├── question_provider.dart        # Study session state
│   │   └── statistics_provider.dart      # Analytics & progress
│   ├── screens/
│   │   ├── home_screen.dart              # Main menu (3x3 grid)
│   │   ├── exam_list_screen.dart         # List of exams
│   │   ├── exam_info_screen.dart         # Exam details + scoring mode
│   │   ├── question_screen.dart          # Question study interface
│   │   ├── question_catalog_screen.dart  # All questions + search/filter
│   │   ├── chapter_list_screen.dart      # Browse by chapter
│   │   ├── statistics_screen.dart        # Progress & analytics
│   │   └── settings_screen.dart          # Theme & preferences
│   ├── widgets/
│   │   ├── menu_grid_item.dart           # Reusable grid card
│   │   ├── license_type_toggle.dart      # A1/A2 switcher
│   │   └── custom_bottom_nav_bar.dart    # Bottom navigation
│   ├── services/
│   │   ├── question_json_service.dart    # JSON loading from assets
│   │   ├── exam_persistence_service.dart # Save/load exam attempts
│   │   └── question_state_persistence.dart # Save/load question states
│   ├── data/
│   │   └── question_repository.dart      # Data gateway (uses JSON service)
│   └── utils/
│       ├── app_colors.dart               # Centralized color system
│       └── theme_config.dart             # ThemeData generation
├── assets/
│   ├── questions/
│   │   ├── questions_a1.json             # A1 questions + chapters + exams
│   │   └── questions_a2.json             # A2 questions + chapters + exams
│   └── images/                           # Question images (traffic signs, etc.)
└── pubspec.yaml                          # Dependencies & asset declarations
```

---

## 3. CÔNG NGHỆ VÀ MÔI TRƯỜNG PHÁT TRIỂN

### 3.1. Công nghệ sử dụng

| Thành phần | Công nghệ | Lý do |
|---|---|---|
| **Framework** | Flutter 3.x (Dart) | Cross-platform (Android + iOS từ 1 codebase), hot reload, hiệu năng native |
| **State Management** | Provider (ChangeNotifier) | Đơn giản, phù hợp quy mô app, không cần boilerplate như Riverpod/Bloc |
| **Local Storage** | SharedPreferences | Nhẹ, phù hợp lưu settings & tiến độ đơn giản |
| **UI Toolkit** | Material 3 | Giao diện hiện đại, hỗ trợ sẵn dark mode, animation mượt |
| **Dữ liệu** | JSON files trong assets | Tách rời code, dễ cập nhật câu hỏi không cần rebuild app |
| **IDE** | VS Code / Android Studio | Hỗ trợ tốt Flutter, Dart DevTools để debug |

### 3.2. Môi trường phát triển

```yaml
# pubspec.yaml — Dependencies chính
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2             # State management
  shared_preferences: ^2.3.3   # Local persistence
  flutter_animate: ^4.5.0      # Animations

environment:
  sdk: ^3.10.4

# Nền tảng mục tiêu:
# - Android: minSdkVersion 21 (Android 5.0 Lollipop)
# - iOS: minimum deployment target 12.0
```

### 3.3. Khác biệt kiến trúc so với phần mềm Desktop

| Khía cạnh | Desktop (C#) | Mobile (Flutter) |
|---|---|---|
| **Dữ liệu câu hỏi** | Hardcoded trong `static class DsCauhoiLT` | File JSON riêng biệt (`questions_a1.json`) |
| **Cập nhật câu hỏi** | Phải sửa code → rebuild → redistribute | Chỉ cần thay file JSON → build lại |
| **Quản lý trạng thái** | Biến instance trong Form | Provider (reactive, notifyListeners) |
| **Persistence** | Không có (mất dữ liệu khi đóng app) | SharedPreferences (giữ tiến độ giữa các lần mở) |
| **Giao diện** | Windows Forms (cứng nhắc) | Flutter widgets (responsive, animated) |
| **Theme** | Single theme | Light/Dark/System, đổi realtime |

---

## 4. CẤU TRÚC DỮ LIỆU

### 4.1. Mô hình Question

Khác với lớp `CauhoiLT` của phần mềm Desktop, Question trong app mobile có cấu trúc phản ánh đúng định dạng JSON:

```dart
class Question {
  // Dữ liệu tĩnh (từ JSON)
  final int id;                    // Số thứ tự câu hỏi
  final String chapter;            // Tên chương (vd: "Khái niệm và quy tắc giao thông")
  final String content;            // Nội dung câu hỏi
  final List<String> answers;      // Danh sách phương án (A, B, C)
  final int correctAnswer;         // Index của đáp án đúng (0, 1, 2)
  final String explanation;        // Giải thích đáp án
  final String? image;             // Tên file ảnh (nullable) — vd: "bien_bao_cam.png"
  final bool isImportant;          // Có phải câu quan trọng không

  // Trạng thái runtime (thay đổi khi người dùng tương tác)
  bool isAnswered;                 // Đã trả lời chưa
  int selectedAnswerIndex;         // Đáp án đã chọn (-1 = chưa chọn)
  int wrongCount;                  // Số lần trả lời sai
  int correctCount;                // Số lần trả lời đúng
  bool isMarked;                   // Có được đánh dấu không
  DateTime? lastAnsweredAt;        // Thời điểm trả lời gần nhất

  // Computed
  bool get isCorrect;              // Trả lời đúng hay sai
  QuestionStatus get status;       // unanswered | correct | wrong
}

enum QuestionStatus { unanswered, correct, wrong }
```

**So sánh với CauhoiLT (Desktop):**

| Thuộc tính | Desktop (CauhoiLT) | Mobile (Question) |
|---|---|---|
| ID | `int SttCauhoi` | `int id` |
| Nội dung | Không có field riêng | `String content` |
| Ảnh | `public Image Anh` (object) | `String? image` (tên file) |
| Phương án | `int SoPATraloi` + array ngầm | `List<String> answers` |
| Đáp án đúng | `int PaTraloiDung` | `int correctAnswer` (index) |
| Ghi chú | `String Ghichu` | `String explanation` |
| Điểm liệt | `bool CauDiemliet` | `bool isImportant` |
| Trạng thái | Không lưu | `isAnswered`, `selectedAnswerIndex`, `wrongCount`, `isMarked` |

### 4.2. Mô hình Chapter

```dart
class Chapter {
  final int id;           // ID chương (1, 2, 3...)
  final String title;     // Tên chương
  final String description; // Mô tả
  final String? icon;     // Emoji icon (vd: "📖", "🚦")
}
```

**Khác biệt:** Desktop không có lớp Chapter riêng — nội dung được phân loại bằng khoảng ID câu hỏi (vd: câu 1–180 = Chương I). Mobile dùng JSON nên mỗi câu hỏi tự khai báo thuộc chương nào.

### 4.3. Mô hình Exam

```dart
class Exam {
  final int id;                    // ID đề thi (1, 2, 3...)
  final String name;               // Tên đề (vd: "Đề thi 1")
  final List<int> questionIds;     // Danh sách ID câu hỏi trong đề
  final String licenseType;        // "A1" hoặc "A2"
}
```

**So sánh với Desktop:** Desktop dùng hàm `Taodethi(hangxe)` để tạo đề ngẫu nhiên từ static list. Mobile lưu sẵn danh sách đề trong JSON (có cấu trúc câu hỏi định trước), cộng thêm chức năng "Đề ngẫu nhiên" chọn ngẫu nhiên 1 đề từ danh sách.

### 4.4. Mô hình ExamAttemptRecord

```dart
class ExamAttemptRecord {
  final DateTime date;           // Thời điểm thi
  final int totalQuestions;      // Tổng số câu
  final int correctAnswers;      // Số câu đúng
  final int wrongAnswers;        // Số câu sai
  final int unansweredQuestions; // Số câu chưa trả lời
  final bool passed;             // Đạt hay không
}
```

Desktop không lưu lịch sử thi. Mobile lưu mỗi lần thi vào SharedPreferences để hiển thị "Số lần thi" và "Điểm tốt nhất" trên giao diện.

### 4.5. Định dạng JSON câu hỏi

```json
{
  "licenseType": "A1",
  "version": "1.0.0",
  "chapters": [
    {
      "id": 1,
      "title": "Khái niệm và quy tắc giao thông",
      "description": "Các khái niệm cơ bản và quy tắc tham gia giao thông",
      "icon": "📖"
    }
  ],
  "questions": [
    {
      "id": 1,
      "chapter": "Khái niệm và quy tắc giao thông",
      "content": "Khi điều khiển xe mô tô hai bánh...",
      "answers": [
        "Hạng A1",
        "Hạng A2",
        "Hạng B1"
      ],
      "correctAnswer": 0,
      "explanation": "Theo Thông tư 12/2017/TT-BGTVT...",
      "isImportant": true
    }
  ],
  "exams": [
    {
      "id": 1,
      "name": "Đề thi 1",
      "questionIds": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...]
    }
  ]
}
```

### 4.6. Hệ thống màu (Color System)

Khác hoàn toàn với Desktop (dùng màu mặc định của Windows Forms), app mobile có hệ thống màu tập trung theo 2 chế độ × 2 loại bằng:

| Palette | Primary | Accent | Background | Surface | Text |
|---|---|---|---|---|---|
| **A1 Light** | `#1E88E5` | `#42A5F5` | `#F5F9FF` | `#FFFFFF` | `#0D1B2A` |
| **A1 Dark** | `#1565C0` | `#64B5F6` | `#0B111A` | `#121A26` | `#E3F2FD` |
| **A2 Light** | `#2E7D32` | `#66BB6A` | `#F4FBF6` | `#FFFFFF` | `#102A13` |
| **A2 Dark** | `#1B5E20` | `#81C784` | `#0E1512` | `#16201A` | `#E8F5E9` |

Tất cả màu sắc được khai báo trong `AppColors` — không hardcode trong widget. Khi người dùng chuyển A1↔A2 hoặc Sáng↚Tối, toàn bộ giao diện tự đổi palette tương ứng.

### 4.7. Persistence (Lưu trữ cục bộ)

App lưu 3 loại dữ liệu vào SharedPreferences:

| Dữ liệu | Key pattern | Mục đích |
|---|---|---|
| **Settings** | `license_type`, `theme_mode`, `auto_advance`, ... | Nhớ tùy chọn người dùng |
| **Question state** | `question_state_A1_42` | Nhớ câu nào đã trả lời, đúng/sai, đánh dấu |
| **Exam attempts** | `attempts_A1_3` | Lưu lịch sử thi, tính best score |

---

## 5. THUẬT TOÁN & CÀI ĐẶT

### 5.1. Thuật toán tạo đề thi ngẫu nhiên

Khác với Desktop dùng thuật toán trộn (Fisher-Yates) trên static list, app mobile có 2 cách tạo đề:

**Cách 1: Chọn đề có sẵn từ JSON**
- Mỗi đề thi đã được soạn trước với cấu trúc đúng quy định
- Người dùng chọn đề → load đúng danh sách `questionIds` từ JSON

**Cách 2: Đề ngẫu nhiên**
- Random chọn 1 đề từ danh sách đề trong JSON
```dart
void loadRandomExam(LicenseType type) {
  final exams = _repository.getExams(type);
  exams.shuffle();                    // Trộn ngẫu nhiên
  final exam = exams.first;           // Lấy đề đầu tiên sau khi trộn
  loadExam(type, exam.id);            // Load đề đó
}
```

### 5.2. Cấu trúc đề thi A1/A2

| Thành phần | Số lượng |
|---|---|
| Quy định chung & quy tắc giao thông | 8 câu |
| Tình huống mất an toàn GT nghiêm trọng | 1 câu |
| Văn hóa giao thông, đạo đức người lái xe | 1 câu |
| Kỹ thuật lái xe hoặc cấu tạo sửa chữa | 1 câu |
| Báo hiệu đường bộ | 8 câu |
| Giải thế sa hình & xử lý tình huống | 6 câu |
| **Tổng** | **30 câu** |
| **Điểm đạt** | **23/30** |

### 5.3. Tính điểm và xét kết quả

```dart
class ExamResult {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unansweredQuestions;
  final bool passed;             // correctAnswers >= 23 → đạt

  double get accuracy => correctAnswers / totalQuestions;
}
```

**Quy trình:**
1. Người dùng trả lời xong → nhấn "Nộp bài"
2. Hệ thống duyệt từng câu: đúng → `correct++`, sai → `wrong++`, chưa trả lời → `unanswered++`
3. So sánh `correctAnswers >= 23` → `passed = true/false`
4. Lưu `ExamAttemptRecord` vào SharedPreferences
5. Hiển thị dialog kết quả

### 5.4. Cơ chế tìm kiếm câu hỏi

Khác với Desktop (không có chức năng tìm kiếm), app mobile cho phép tìm text trong nội dung câu hỏi:

```dart
List<Question> searchQuestions(LicenseType type, String query) {
  if (query.trim().isEmpty) return [];
  final lowerQuery = query.toLowerCase().trim();
  final questions = _questions[type] ?? [];
  return questions
      .where((q) => q.content.toLowerCase().contains(lowerQuery))
      .toList();
}
```

### 5.5. Cơ chế chấm điểm — 2 chế độ

| Chế độ | Mô tả |
|---|---|
| **Chấm ngay sau mỗi câu** | Chọn đáp án → hiện đúng/sai + giải thích ngay. Dùng để ôn tập. |
| **Chấm sau khi nộp bài** | Không hiện kết quả từng câu. Chỉ chấm khi nộp bài cuối cùng. Dùng để thi thử. |

Người dùng chọn chế độ tại màn Exam Info trước khi bắt đầu.

### 5.6. Quản lý trạng thái với Provider

```
AppProvider (ChangeNotifier)
├── selectedLicense: A1 | A2          → Đổi màu, tải dữ liệu đúng hạng
├── themeMode: light | dark | system  → MaterialApp.themeMode
├── autoAdvance: bool                 → Tự chuyển câu sau khi trả lời
├── showExplanation: bool             → Hiện giải thích hay không
└── gradeImmediately: bool            → Chấm điểm ngay hay sau nộp bài

QuestionProvider (ChangeNotifier)
├── currentQuestions: List<Question>  → Danh sách câu đang học
├── currentIndex: int                 → Câu đang xem
├── studyMode: all | wrong | marked | exam | ...
├── scoringMode: gradeAfterSubmission | gradeImmediately
├── isExamMode: bool                  → Đang ở chế độ thi hay ôn
└── submitExam() → ExamResult         → Nộp bài, tính điểm, lưu kết quả

StatisticsProvider (ChangeNotifier)
├── getOverallAccuracy() → double     → Tỉ lệ đúng chung
├── getChapterProgress() → Map        → Tiến độ từng chương
└── getStudyHeatmap() → List<int>     → Hoạt động 30 ngày
```

### 5.7. Luồng nạp dữ liệu

```
main()
  │
  ├─ QuestionRepository().initializeAsync()
  │     │
  │     ├─ rootBundle.loadString("assets/questions/questions_a1.json")
  │     ├─ jsonDecode() → chapters[], questions[], exams[]
  │     └─ QuestionStatePersistence.loadAllQuestionStates()
  │           └─ Khôi phục isAnswered, isMarked, wrongCount...
  │
  ├─ AppProvider().initialize(context)
  │     ├─ SharedPreferences: đọc license_type, theme_mode, settings
  │     └─ resolveBrightness() → xác định isDark
  │
  └─ runApp(GplxApp)
        │
        └─ MaterialApp(
             theme: AppProvider.lightTheme,     // Từ ThemeConfig
             darkTheme: AppProvider.darkTheme,   // Từ ThemeConfig
             themeMode: AppProvider.flutterThemeMode
           )
```

---

## 6. KIỂM THỬ

### 6.1. Kịch bản kiểm thử

| STT | Tên kịch bản | Các bước | Kết quả mong đợi |
|---|---|---|---|
| 1 | **Nạp câu hỏi từ JSON** | Mở app → vào "Danh sách câu hỏi" | Hiển thị đủ 30 câu A1, không lỗi |
| 2 | **Nạp đề thi từ JSON** | Mở app → "Thi thử" → "Chọn đề thi" | Hiển thị 5 đề thi + "Đề ngẫu nhiên" |
| 3 | **Tìm kiếm text** | Gõ "giấy phép" vào ô tìm kiếm | Lọc các câu có chữ "giấy phép" trong nội dung |
| 4 | **Chuyển A1↔A2** | Chuyển license type | Màu đổi xanh↔xanh lá, dữ liệu reload |
| 5 | **Dark mode** | Đổi theme → Dark | Toàn bộ giao diện dùng palette dark |
| 6 | **Lưu tiến độ** | Trả lời 3 câu → đóng app → mở lại | 3 câu vẫn trạng thái đã trả lời |
| 7 | **Lưu kết quả thi** | Làm đề thi → nộp bài → vào lại đề đó | Hiển thị "Số lần thi: 1" + "Tốt nhất: X" |
| 8 | **Chấm ngay** | Chế độ "Chấm ngay" → chọn đáp án | Hiện đúng/sai + giải thích ngay |
| 9 | **Chấm sau nộp** | Chế độ "Chấm sau" → chọn đáp án | Không hiện kết quả → nộp bài mới chấm |
| 10 | **Image loading** | Mở câu có `"image": "abc.png"` | Hiện ảnh hoặc placeholder "Image not found" |
| 11 | **Điểm đạt** | Làm đúng 23/30 câu → nộp bài | Kết quả: "Chúc mừng! Đạt" |
| 12 | **Không đạt** | Làm đúng 20/30 câu → nộp bài | Kết quả: "Chưa đạt — Cần 23/30" |

---

## 7. ƯU NHƯỢC ĐIỂM & HƯỚNG CẢI THIỆN

### 7.1. Ưu điểm (so với Desktop)

| Ưu điểm | Giải thích |
|---|---|
| **Dữ liệu tách rời code** | Thêm/sửa câu hỏi chỉ cần chỉnh JSON, không động vào Dart |
| **Chạy trên điện thoại** | Học viên ôn tập mọi lúc, không cần máy tính |
| **Dark Mode** | Bảo vệ mắt khi học ban đêm, tiết kiệm pin AMOLED |
| **Lưu tiến độ** | Không mất dữ liệu khi đóng app, khác hoàn toàn Desktop |
| **Tìm kiếm text** | Desktop không có — mobile cho phép tìm nhanh trong 30+ câu |
| **UI hiện đại** | Material 3, animation mượt, responsive |
| **Cross-platform** | 1 codebase → Android + iOS, không cần viết lại |

### 7.2. Nhược điểm & Hướng cải thiện

| Nhược điểm | Hướng cải thiện |
|---|---|
| **Chưa có đồng bộ cloud** | Tích hợp Firebase để lưu tiến độ online, học trên nhiều thiết bị |
| **Chưa có âm thanh** | Thêm Text-to-Speech đọc câu hỏi cho người khiếm thị |
| **Chưa có tính giờ thi** | Thêm countdown timer như phần mềm Desktop (hiện tại không giới hạn thời gian) |
| **Chưa có câu điểm liệt** | Bổ sung logic "sai câu điểm liệt = không đạt" |
| **Dữ liệu mẫu ít** | Hiện tại 30 câu mẫu — cần nhập đủ 250 câu A1 theo quy định |
| **Chưa có đăng nhập** | Thêm màn đăng nhập để phân biệt học viên, như phần mềm Desktop |
| **Chưa có export kết quả** | Cho phép xuất báo cáo học tập ra PDF |
