import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/layout/AppLayout.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';
import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:te4st_proj_flut/models/user_model.dart';

class EmployeeSummaryPage extends StatefulWidget {
  const EmployeeSummaryPage({Key? key}) : super(key: key);

  @override
  _EmployeeSummaryPageState createState() => _EmployeeSummaryPageState();
}

class _EmployeeSummaryPageState extends State<EmployeeSummaryPage> {

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login/background.png'),
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
                    ]
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
                  child: Column(
                    spacing: 16,
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
                      
                      Text(
                        'Пожалуйста, отвечайте честно, исходя из того, что вы чувствовали со вчерашнего дня.Ваши ответы помогут системе лучше понять ваше самочувствие.Это займёт менее 1 минуты.',
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: (){},
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
                            disabledBackgroundColor:
                            const Color(0xFF722ED1).withOpacity(0.5),
                          ),
                          child: const Text('Пройти тестирование', style: TextStyle(fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}