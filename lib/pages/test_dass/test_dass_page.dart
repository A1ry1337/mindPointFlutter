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
        Image.asset('assets/images/test_dass/pucha_think.png'),
        const SizedBox(height: 25),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(index),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (isSelected) return const Color(0xFF722ED1).withOpacity(0.1);
                            return Colors.white;
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (isSelected) return const Color(0xFF722ED1);
                            return Colors.black;
                          }),
                          overlayColor: MaterialStateProperty.resolveWith((states) {
                            if (isSelected) return Colors.transparent;
                            if (states.contains(MaterialState.hovered)) return const Color(0xFF722ED1).withOpacity(0.05);
                            if (states.contains(MaterialState.pressed)) return const Color(0xFF722ED1).withOpacity(0.1);
                            return null;
                          }),
                          shape: MaterialStateProperty.resolveWith((states) {
                            return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF722ED1) : Colors.grey.shade300,
                                width: 1,
                              ),
                            );
                          }),
                          elevation: MaterialStateProperty.all(0),
                          minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.2,
                            ),
                          ),
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
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            foregroundColor: MaterialStateProperty.all(const Color(0xFF722ED1)),
                            overlayColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.hovered)) return const Color(0xFF722ED1).withOpacity(0.05);
                              if (states.contains(MaterialState.pressed)) return const Color(0xFF722ED1).withOpacity(0.1);
                              return null;
                            }),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade300),
                            )),
                            elevation: MaterialStateProperty.all(0),
                            minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                          ),
                          child: const Text('Назад'),
                        ),
                      ),
                    if (_currentQuestionIndex > 0)
                      const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF722ED1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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
                          _currentQuestionIndex == questions.length - 1
                              ? 'Завершить'
                              : 'Выбрать',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: Image.asset(
            'assets/images/test_dass/pucha_happy.png',
          ),
        ),
        SizedBox(height: 150),
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Белый контейнер
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB6B1BA),
                    blurRadius: 10,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24, left: 24, right: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Спасибо за прохождение теста!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4D4D4D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Результаты тестирования сохранены. Вы можете пройти тест снова завтра.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF722ED1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF722ED1).withOpacity(0.3),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Вернуться на главную'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Галочка поверх контейнера
            Positioned(
              top: -41.5,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/test_dass/complete.png',
                  width: 83,
                  height: 83,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
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