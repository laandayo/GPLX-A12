# GPLX - Ứng Dụng Ôn Thi Bằng Lái Xe 🚗

Ứng dụng di động giúp ôn thi giấy phép lái xe (GPLX) hạng A1 và A2 cho người Việt Nam.

## 📱 Tính Năng

### Màn Hình Chính
- **Chuyển đổi A1/A2**: Toggle 50/50 để chuyển đổi giữa hai loại bằng lái với thay đổi theme màu sắc
  - A1: Blue theme 🚗
  - A2: Green theme 🚙
- **Thống kê nhanh**: Hiển thị số câu đã học hôm nay và streak
- **Menu lưới 3x3**: 9 chức năng chính với thông tin tiến độ
  - Thi thử
  - Ôn tập (theo chương)
  - Câu đánh dấu
  - Câu sai
  - Câu quan trọng
  - Ngẫu nhiên
  - Chưa trả lời
  - Ôn lại câu sai
  - Thi thật (có giờ)

### Màn Hình Câu Hỏi
- **Top Section**:
  - Hiển thị "Câu x / X" (số thự tự)
  - Progress bar trực quan
  - Bookmark icon (đánh dấu câu hỏi)
  - Status indicators: Đúng ✅, Sai ❌, Đánh dấu 🔖
  
- **Middle Section**:
  - Nội dung câu hỏi
  - 3-4 đáp án với highlighting
  - Sau khi chọn:
    - Đáp án đúng → màu xanh lá
    - Đáp án sai → màu đỏ
    - Luôn hiển thị đáp án đúng
    - Giải thích chi tiết (có thể có ảnh)

- **Bottom Section**:
  - Navigation: Trước, Danh sách câu hỏi, Sau
  - Setting: Tự động chuyển câu sau khi trả lời

### Màn Hình Chương (Study Flow)
- **Top Section**: Tiêu đề chương
- **Middle Section**:
  - Thống kê: Hoàn thành, Sai, Lần học cuối
  - Options: Ôn tất cả, Ôn chưa trả lời, Ôn câu sai
  - Start button → chuyển đến Question Screen

### Màn Hình Thống Kê
- **Overview Cards**:
  - Tỉ lệ chính xác (%)
  - Số câu đã trả lời
  - Tỉ lệ đậu dự kiến (%)
  - Số câu còn lại
  
- **Tiến độ theo chương**: Progress bars cho từng chương
- **Study Heatmap**: Hoạt động ôn tập 30 ngày

## 🏗️ Cấu Trúc Code

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── models.dart
│   ├── question.dart           # Question, Answer models
│   ├── chapter.dart            # Chapter model
│   ├── test_attempt.dart       # TestAttempt model
│   └── license_type.dart       # LicenseType enum
├── data/                        # Data layer
│   ├── data.dart
│   ├── sample_data.dart        # Sample questions & chapters
│   └── question_repository.dart # Questions CRUD operations
├── providers/                   # State management (Provider)
│   ├── providers.dart
│   ├── app_provider.dart       # App-wide state (license type, theme)
│   ├── question_provider.dart  # Question state & study modes
│   └── statistics_provider.dart # Statistics & progress
├── screens/                     # Main screens
│   ├── screens.dart
│   ├── home_screen.dart        # Home screen with 3x3 grid
│   ├── chapter_list_screen.dart # Chapter selection
│   ├── question_screen.dart     # Question & answers
│   └── statistics_screen.dart   # Statistics & progress
├── widgets/                     # Reusable widgets
│   ├── widgets.dart
│   ├── menu_grid_item.dart     # Grid menu items
│   ├── license_type_toggle.dart # A1/A2 toggle
│   ├── progress_card.dart      # Progress display cards
│   └── custom_bottom_nav_bar.dart # Bottom navigation
└── utils/                       # Utilities (future)
```

## 🧩 Data Model

### Question
```dart
- id: int                       // Real order index
- chapter: int                  // Chapter ID
- content: String               // Question content
- answers: List<Answer>         // Answer options
- explanation: String           // Explanation text
- image: String?                // Optional image
- isImportant: bool             // Critical question flag
- isAnswered: bool              // User answered
- selectedAnswerIndex: int      // User's selection
- wrongCount: int               // Times answered wrong
- correctCount: int             // Times answered correct
- isMarked: bool                // Bookmarked
- lastAnsweredAt: DateTime?     // Last answer timestamp
```

### Study Modes (Playlist Concept)
- **All**: Tất cả câu hỏi trong chương
- **Unanswered**: Chưa trả lời
- **Wrong**: Câu sai
- **Marked**: Câu đánh dấu
- **Random**: Ngẫu nhiên
- **Important**: Câu quan trọng

## 🎨 Theme & UI

- **A1 Theme**: Blue (#2196F3)
- **A2 Theme**: Green (#4CAF50)
- **Design**: Clean, modern, minimal
- **Animations**: Smooth transitions với flutter_animate
- **Layout**: 3-section structure (Header / Content / Bottom Nav)

## 🚀 Bắt Đầu

### Yêu Cầu
- Flutter SDK >= 3.10.4
- Dart SDK >= 3.10.4

### Cài Đặt

```bash
# Clone repository
cd gplx_app

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### Build cho Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (cho Google Play)
flutter build appbundle --release
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2           # State management
  shared_preferences: ^2.3.3 # Local storage (future)
  flutter_animate: ^4.5.0    # Animations
```

## 🔮 Tính Năng Tương Lai

- [ ] Real exam mode với timer
- [ ] Study heatmap hoàn chỉnh
- [ ] Local storage với SharedPreferences
- [ ] Import/export data
- [ ] Dark mode
- [ ] Multiple language support
- [ ] Cloud sync
- [ ] Social features (leaderboard, sharing)

## 📝 Ghi Chú

- Tất cả câu hỏi có ID cố định (thứ tự thật)
- App tạo dynamic "playlists" dựa trên chế độ học
- Progress được tracking per question
- Theme thay đổi theo loại bằng lái (A1/A2)

## 🛠️ Testing

```bash
# Chạy tests
flutter test

# Analyze code
flutter analyze
```

## 📄 License

Private project - All rights reserved

## 👨‍💻 Developer

Built with ❤️ for Vietnamese driving license exam preparation
