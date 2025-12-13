import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/layout/AppLayout.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';
import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:te4st_proj_flut/models/user_model.dart';
import 'package:te4st_proj_flut/core/services/dass_service.dart'; // Импортируйте DassService

class EmployeeSummaryPage extends StatefulWidget {
  const EmployeeSummaryPage({Key? key}) : super(key: key);

  @override
  _EmployeeSummaryPageState createState() => _EmployeeSummaryPageState();
}

class _EmployeeSummaryPageState extends State<EmployeeSummaryPage> {
  final DassService _dassService = DassService();
  bool _isLoading = true;
  bool _testCompletedToday = false;
  String? _lastCompletionTime;

  @override
  void initState() {
    super.initState();
    _checkTestStatus();
  }

  Future<void> _checkTestStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final completed = await _dassService.checkIfTestCompletedToday();

      setState(() {
        _testCompletedToday = completed;
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка при проверке статуса теста: $e');
      setState(() {
        _testCompletedToday = false;
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_testCompletedToday) {
      return _buildTestCompletedCard();
    }

    return _buildTestAvailableCard();
  }

  Widget _buildTestCompletedCard() {
    return Container(
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
          ]
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Тест уже пройден!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Вы уже прошли тестирование сегодня. Следующий тест будет доступен завтра.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Спасибо за ваше участие!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF722ED1),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Можно добавить переход на страницу с результатами
                  // context.go('/results');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Посмотреть результаты'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestAvailableCard() {
    return Container(
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
          ]
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Перед вами тест из 9 вопросов',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4D4D4D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Пожалуйста, отвечайте честно, исходя из того, что вы чувствовали со вчерашнего дня. Ваши ответы помогут системе лучше понять ваше самочувствие. Это займёт менее 1 минуты.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => context.go('/test_dass'),
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
                child: const Text('Пройти тестирование'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: Image.asset(
                    'assets/images/login/flower.png',
                  ),
                ),
                _buildContent(),
              ],
            ),
          ],
        )
    );
  }
}