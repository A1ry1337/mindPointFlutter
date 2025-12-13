import 'package:te4st_proj_flut/core/services/api_service.dart';

class DassService {
  final ApiService _apiService = ApiService();

  // Получить 9 случайных вопросов
  Future<List<DassQuestion>> getRandomQuestions() async {
    try {
      final response = await _apiService.get('/dass9/random');

      return response
          .map<DassQuestion>((item) => DassQuestion.fromJson(item as Map<String, dynamic>))
          .toList();

    } catch (e, stackTrace) {
      print('❌ Ошибка в getRandomQuestions: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Отправить результаты теста
  Future<Map<String, dynamic>> submitResults({
    required int depression,
    required int stress,
    required int anxiety,
  }) async {
    try {
      final data = {
        'depression': depression,
        'stress': stress,
        'anxiety': anxiety,
      };

      final response = await _apiService.post(
        '/dass9/',
        data,
        authRequired: true,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Проверить, пройден ли тест сегодня
  Future<bool> checkIfTestCompletedToday() async {
    try {
      final response = await _apiService.get(
        '/dass9/check',
        authRequired: true,
      );

      // Предполагаем, что API возвращает булево значение или строку
      return response['passed_today'] == true;
    } catch (e) {
      print('❌ Ошибка при проверке статуса теста: $e');
      return false; // В случае ошибки показываем возможность пройти тест
    }
  }

}

class DassQuestion {
  final int id;
  final String text;
  final String type;
  final Map<String, String> answers;

  DassQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.answers,
  });

  factory DassQuestion.fromJson(Map<String, dynamic> json) {
    return DassQuestion(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      answers: Map<String, String>.from(json['answers'] ?? {}),
    );
  }
}