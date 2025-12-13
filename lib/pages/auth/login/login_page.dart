import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';
import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:te4st_proj_flut/models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _login() async {
    if (_username.isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите логин');
      return;
    }

    if (_password.isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите пароль');
      return;
    }

    if (_password.length < 6) {
      _showErrorSnackBar('Пароль должен быть не менее 6 символов');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        username: _username,
        password: _password,
      );

      UserModel? user = await StorageService.getUser();

      if (context.mounted) {
        user?.isManager == true ? context.go('/manager_summary') : context.go('/employee_summary');
      }
    } catch (e) {
      if (context.mounted) {
        if (e.toString().contains('Unauthorized')) {
          _showErrorSnackBar('Неверный логин или пароль');
        } else {
          _showErrorSnackBar('Ошибка входа: $e');
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
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
                        'Авторизация',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4D4D4D),
                        ),
                      ),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Введите ваш логин',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) => _username = value,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Введите ваш пароль',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade500,
                              ),
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          obscureText: _obscurePassword,
                          onChanged: (value) => _password = value,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
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
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text('Войти', style: TextStyle(fontWeight: FontWeight.w400)),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 4.0,
                        children: [
                          const Text(
                            'Нету аккаунта?',
                            style: TextStyle(fontSize: 16),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(5),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              overlayColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory, // Убирает эффект сплэша
                            ),
                            child: const Text(
                              'Зарегистрироваться',
                              style: TextStyle(
                                color: Color(0xFF7029CC),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}