import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/layout/AppLayout.dart';
import 'package:te4st_proj_flut/core/services/dass_service.dart';

class TestDassPage extends StatefulWidget {
  const TestDassPage({Key? key}) : super(key: key);

  @override
  State<TestDassPage> createState() => _TestDassPageState();
}

class _TestDassPageState extends State<TestDassPage> {
  final DassService _dassService = DassService();

  List<DassQuestion>? _questions;
  List<int?> _answers = [];

  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isTestCompleted = false;

  final List<String> _answerOptions = const [
    'Совсем не было',
    'Немного, иногда',
    'Часто, значительную часть времени',
    'Почти все время',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _dassService.getRandomQuestions();
      setState(() {
        _questions = questions;
        _answers = List<int?>.filled(questions.length, null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Не удалось загрузить вопросы');
    }
  }

  void _answerQuestion(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_questions == null) return;

    if (_answers[_currentQuestionIndex] == null) {
      _showError('Пожалуйста, выберите ответ');
      return;
    }

    if (_currentQuestionIndex < _questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitTest();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitTest() async {
    if (_questions == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      int depressionScore = 0;
      int stressScore = 0;
      int anxietyScore = 0;

      for (int i = 0; i < _questions!.length; i++) {
        final answer = _answers[i];
        if (answer != null) {
          switch (_questions![i].type) {
            case 'depression':
              depressionScore += answer;
              break;
            case 'stress':
              stressScore += answer;
              break;
            case 'anxiety':
              anxietyScore += answer;
              break;
          }
        }
      }

      await _dassService.submitResults(
        depression: depressionScore,
        stress: stressScore,
        anxiety: anxietyScore,
      );

      setState(() {
        _isTestCompleted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showError('Не удалось отправить результаты');
    }
  }

  void _restartTest() {
    if (_questions == null) return;

    setState(() {
      _currentQuestionIndex = 0;
      _answers = List<int?>.filled(_questions!.length, null);
      _isTestCompleted = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildTestContent() {
    if (_isLoading || _questions == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF722ED1),
        ),
      );
    }

    if (_isTestCompleted) {
      return _buildCompletionScreen();
    }

    final questions = _questions!;
    final question = questions[_currentQuestionIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Image.asset('assets/images/test_dass/cloud.png'),
        Image.asset('assets/images/test_dass/pucha_think.png'),
        const SizedBox(height: 33),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFB6B1BA),
                blurRadius: 10,
                spreadRadius: -5,
                offset: Offset(0, 10),
              ),
            ],
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                        '${_currentQuestionIndex + 1}/${questions.length} ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      TextSpan(
                        text: question.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D4D4D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: _answerOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
                    final isSelected =
                        _answers[_currentQuestionIndex] == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _answerQuestion(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF722ED1).withOpacity(0.1)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? const Color(0xFF722ED1)
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF722ED1)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            elevation: 1,
                          ),
                          child: Text(text),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _previousQuestion,
                          child: const Text('Назад'),
                        ),
                      ),
                    if (_currentQuestionIndex > 0)
                      const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _nextQuestion,
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          _currentQuestionIndex ==
                              questions.length - 1
                              ? 'Завершить'
                              : 'Далее',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value:
                  (_currentQuestionIndex + 1) / questions.length.toDouble(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Color(0xFF722ED1)),
        const SizedBox(height: 20),
        const Text(
          'Спасибо за прохождение теста!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Вернуться на главную'),
        ),
        TextButton(
          onPressed: _restartTest,
          child: const Text('Пройти ещё раз'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _buildTestContent(),
        ],
      ),
    );
  }
}
