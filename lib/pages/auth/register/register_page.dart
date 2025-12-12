import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  // Определяем, какой таб активен
  int _selectedTab = 0; // 0 - компания, 1 - сотрудник

  // Общие поля
  String _username = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Поле только для сотрудника
  String _fullName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _switchTab(int tabIndex) {
    if (_selectedTab != tabIndex) {
      setState(() {
        _selectedTab = tabIndex;
      });
    }
  }

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

  Future<void> _register() async {
    // Валидация общих полей
    if (_username.isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите логин');
      return;
    }

    if (_email.isEmpty || !_email.contains('@')) {
      _showErrorSnackBar('Пожалуйста, введите корректный email');
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

    // Валидация для сотрудника
    if (_selectedTab == 1 && _fullName.isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите ФИО');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        username: _username,
        email: _email,
        password: _password,
        fullName: _fullName,
        isManager: _selectedTab == 0, // Компания = менеджер
      );

      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar('Ошибка регистрации: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String hintText,
    required Function(String) onChanged,
    bool obscureText = false,
    bool showVisibilityIcon = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: showVisibilityIcon
              ? IconButton(
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
          )
              : null,
        ),
        style: const TextStyle(fontSize: 16),
        obscureText: obscureText && _obscurePassword,
        onChanged: onChanged,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildCompanyForm() {
    return Column(
      key: const ValueKey('company_form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите логин',
          onChanged: (value) => _username = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите email',
          onChanged: (value) => _email = value,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите пароль',
          onChanged: (value) => _password = value,
          obscureText: true,
          showVisibilityIcon: true,
        ),
      ],
    );
  }

  Widget _buildEmployeeForm() {
    return Column(
      key: const ValueKey('employee_form'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите ФИО',
          onChanged: (value) => _fullName = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите логин',
          onChanged: (value) => _username = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите email',
          onChanged: (value) => _email = value,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hintText: 'Введите пароль',
          onChanged: (value) => _password = value,
          obscureText: true,
          showVisibilityIcon: true,
        ),
      ],
    );
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
                  'assets/images/login/flowerMini.png',
                ),
              ),
              SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
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
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 24, left: 24, right: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Регистрация',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4D4D4D),
                          ),
                        ),
                        // Анимированные табы
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 1,
                                  color: Color(0x10000000),
                                ),
                              ),
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                left: _selectedTab == 0 ? 0.0 : MediaQuery.of(context).size.width / 2 - 24,
                                bottom: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2 - 48,
                                  height: 3, // толщина линии
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF722ED1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _switchTab(0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          color: Colors.transparent,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Компания',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: _selectedTab == 0
                                                ? Color(0xFF722ED1)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _switchTab(1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          color: Colors.transparent,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Сотрудник',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: _selectedTab == 1
                                                ? Color(0xFF722ED1)
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Анимированный контент формы
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: _selectedTab == 0
                              ? _buildCompanyForm()
                              : _buildEmployeeForm(),
                        ),
                        const SizedBox(height: 16),
                        // Кнопка регистрации
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF722ED1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              shadowColor:
                              const Color(0xFF722ED1).withOpacity(0.3),
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
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : const Text(
                              'Зарегистрироваться',
                              style:
                              TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 4.0,
                          children: [
                            const Text(
                              'Уже есть аккаунт?',
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(5),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                overlayColor: Colors.transparent,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: const Text(
                                'Войти',
                                style: TextStyle(
                                  color: Color(0xFF7029CC),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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