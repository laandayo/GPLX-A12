import '../models/models.dart';

class SampleData {
  static List<Chapter> getChapters(LicenseType type) {
    if (type == LicenseType.a1) {
      return [
        Chapter(
          id: 1,
          title: 'Câu hỏi quan trọng',
          description: 'Các câu hỏi thường gặp trong kỳ thi',
          questionIds: List.generate(50, (i) => i + 1),
          icon: '⚠️',
        ),
        Chapter(
          id: 2,
          title: 'Lý thuyết giao thông',
          description: 'Quy tắc và luật giao thông đường bộ',
          questionIds: List.generate(100, (i) => i + 51),
          icon: '📖',
        ),
        Chapter(
          id: 3,
          title: 'Biển báo hiệu',
          description: 'Nhận biết các loại biển báo giao thông',
          questionIds: List.generate(80, (i) => i + 151),
          icon: '🚦',
        ),
        Chapter(
          id: 4,
          title: 'Sa hình & Kỹ năng',
          description: 'Câu hỏi về sa hình và kỹ năng lái xe',
          questionIds: List.generate(70, (i) => i + 231),
          icon: '🚗',
        ),
        Chapter(
          id: 5,
          title: 'Phạt nguội & Quy định',
          description: 'Mức phạt và các quy định mới',
          questionIds: List.generate(50, (i) => i + 301),
          icon: '⚖️',
        ),
      ];
    } else {
      return [
        Chapter(
          id: 1,
          title: 'Câu hỏi quan trọng',
          description: 'Các câu hỏi thường gặp trong kỳ thi A2',
          questionIds: List.generate(60, (i) => i + 1),
          icon: '⚠️',
        ),
        Chapter(
          id: 2,
          title: 'Lý thuyết giao thông nâng cao',
          description: 'Quy tắc và luật giao thông nâng cao',
          questionIds: List.generate(120, (i) => i + 61),
          icon: '📖',
        ),
        Chapter(
          id: 3,
          title: 'Biển báo hiệu nâng cao',
          description: 'Nhận biết các loại biển báo phức tạp',
          questionIds: List.generate(90, (i) => i + 181),
          icon: '🚦',
        ),
        Chapter(
          id: 4,
          title: 'Sa hình & Kỹ năng nâng cao',
          description: 'Câu hỏi về sa hình và kỹ năng lái xe A2',
          questionIds: List.generate(80, (i) => i + 271),
          icon: '🚙',
        ),
        Chapter(
          id: 5,
          title: 'Phạt nguội & Quy định nâng cao',
          description: 'Mức phạt và các quy định A2',
          questionIds: List.generate(50, (i) => i + 351),
          icon: '⚖️',
        ),
      ];
    }
  }

  static List<Question> getQuestions(LicenseType type) {
    final totalQuestions = type == LicenseType.a1 ? 450 : 400;
    final questions = <Question>[];

    for (int i = 1; i <= totalQuestions; i++) {
      int chapter;
      if (i <= 50 || (i > 300 && i <= 350)) {
        chapter = 1;
      } else if (i <= 150 || (i > 50 && i <= 170)) {
        chapter = 2;
      } else if (i <= 230 || (i > 170 && i <= 260)) {
        chapter = 3;
      } else {
        chapter = 4;
      }

      questions.add(Question(
        id: i,
        chapter: chapter,
        content: _getQuestionContent(i, type),
        answers: _getAnswers(i, type),
        explanation: _getExplanation(i, type),
        isImportant: i <= 50 || (type == LicenseType.a2 && i <= 60),
      ));
    }

    return questions;
  }

  static String _getQuestionContent(int index, LicenseType type) {
    final questions = [
      'Khi điều khiển xe mô tô hai bánh, xe mô tô ba bánh loại có dung tích xi lanh dưới 175 cm³, người điều khiển phải có giấy phép lái xe hạng gì?',
      'Trên đường bộ trong khu vực đông dân cư, xe mô tô hai bánh, xe mô tô ba bánh được phép chạy với tốc độ tối đa bao nhiêu?',
      'Khi tham gia giao thông, người điều khiển xe mô tô phải đội mũ bảo hiểm có cài quai đúng quy cách khi nào?',
      'Trên đường có dải phân cách cố định, người điều khiển xe mô tô được phép quay đầu xe ở đâu?',
      'Khi gặp biển báo hiệu cấm đi ngược chiều, người điều khiển xe mô tô phải làm gì?',
      'Khoảng cách an toàn giữa hai xe khi tham gia giao thông được quy định như thế nào?',
      'Khi điều khiển xe mô tô rẽ trái, rẽ phải, người lái xe phải làm gì?',
      'Trên đường cao tốc, xe mô tô hai bánh được phép chạy với tốc độ tối đa bao nhiêu?',
      'Khi gặp đèn tín hiệu giao thông màu vàng nhấp nháy, người điều khiển xe phải làm gì?',
      'Người điều khiển xe mô tô không được phép làm gì khi tham gia giao thông?',
      'Khi xảy ra tai nạn giao thông, người điều khiển xe phải làm gì đầu tiên?',
      'Biển báo hiệu nguy hiểm có dạng hình gì, màu sắc như thế nào?',
      'Vạch kẻ đường màu vàng nét đứt có ý nghĩa gì?',
      'Khi đang lên dốc, xe đi ngược chiều muốn xuống dốc, xe nào được ưu tiên đi trước?',
      'Người đủ bao nhiêu tuổi thì được thi giấy phép lái xe hạng A1?',
      'Xe mô tô hai bánh, xe mô tô ba bánh có được kéo đẩy xe khác không?',
      'Khi điều khiển xe mô tô, người lái xe có được sử dụng ô, điện thoại không?',
      'Trên đường một chiều có vạch kẻ đường, xe mô tô phải đi ở làn đường nào?',
      'Khi qua đường sắt không có rào chắn, người điều khiển xe phải làm gì?',
      'Biển báo hiệu lệnh có dạng hình gì, màu sắc như thế nào?',
    ];

    return questions[(index - 1) % questions.length];
  }

  static List<Answer> _getAnswers(int index, LicenseType type) {
    final answerSets = [
      [
        Answer(content: 'Hạng A1', isCorrect: true),
        Answer(content: 'Hạng A2', isCorrect: false),
        Answer(content: 'Hạng B1', isCorrect: false),
        Answer(content: 'Hạng C', isCorrect: false),
      ],
      [
        Answer(content: '40 km/h', isCorrect: false),
        Answer(content: '50 km/h', isCorrect: true),
        Answer(content: '60 km/h', isCorrect: false),
        Answer(content: '70 km/h', isCorrect: false),
      ],
      [
        Answer(content: 'Khi cảm thấy nguy hiểm', isCorrect: false),
        Answer(content: 'Khi trời mưa', isCorrect: false),
        Answer(content: 'Trong mọi trường hợp', isCorrect: true),
        Answer(content: 'Khi đi trên đường cao tốc', isCorrect: false),
      ],
      [
        Answer(content: 'Ở bất kỳ vị trí nào', isCorrect: false),
        Answer(content: 'Nơi đường giao nhau hoặc nơi có vạch kẻ đường cho phép quay đầu', isCorrect: true),
        Answer(content: 'Nơi có biển báo cho phép quay đầu', isCorrect: false),
        Answer(content: 'Không được phép quay đầu', isCorrect: false),
      ],
      [
        Answer(content: 'Tiếp tục đi', isCorrect: false),
        Answer(content: 'Giảm tốc độ và dừng lại', isCorrect: true),
        Answer(content: 'Tăng tốc để vượt qua', isCorrect: false),
        Answer(content: 'Tìm đường khác', isCorrect: false),
      ],
    ];

    return answerSets[(index - 1) % answerSets.length];
  }

  static String _getExplanation(int index, LicenseType type) {
    final explanations = [
      'Theo quy định tại Thông tư 12/2017/TT-BGTVT, giấy phép lái xe hạng A1 cấp cho người điều khiển xe mô tô hai bánh có dung tích xi lanh từ 50 cm³ đến dưới 175 cm³.',
      'Theo Quy chuẩn kỹ thuật quốc gia QCVN 41:2019/BGTVT, trong khu vực đông dân cư, tốc độ tối đa cho xe mô tô hai bánh là 50 km/h.',
      'Theo Luật Giao thông đường bộ 2008, người điều khiển xe mô tô phải đội mũ bảo hiểm có cài quai đúng quy cách trong mọi trường hợp khi tham gia giao thông.',
      'Người điều khiển xe chỉ được quay đầu xe ở nơi đường giao nhau hoặc nơi có vạch kẻ đường cho phép quay đầu, không được quay đầu ở đoạn đường bị cấm.',
      'Khi gặp biển báo cấm đi ngược chiều, người điều khiển xe phải giảm tốc độ và dừng lại, không được đi vào đường cấm.',
    ];

    return explanations[(index - 1) % explanations.length];
  }
}
