

import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:te4st_proj_flut/models/user_model.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<UserModel> login({
    String? username,
    String? email,
    required String password,
    String? fullName,
    bool? isManager,
  }) async {
    print('🔐 Начало процесса логина...');

    final data = {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      'password': password,
      if (fullName != null) 'full_name': fullName,
      if (isManager != null) 'is_manager': isManager,
    };

    print('📤 Отправка данных для логина:');
    data.forEach((key, value) {
      if (key == 'password') {
        print('  $key: ********');
      } else {
        print('  $key: $value');
      }
    });

    try {
      final response = await _apiService.post('/auth/login', data);
      final user = UserModel.fromJson(response);

      print('✅ Логин успешен!');
      print('👤 Пользователь: ${user.username} (${user.email})');
      print('🔑 Токен получен: ${user.accessToken.substring(0, 20)}...');

      // Сохраняем данные
      await StorageService.saveToken(user.accessToken);
      await StorageService.saveUser(user);

      print('💾 Данные сохранены в локальное хранилище');

      return user;
    } catch (e) {
      print('❌ Ошибка при логине: $e');
      rethrow;
    }
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required bool isManager,
  }) async {
    print('📝 Начало процесса регистрации...');

    final data = {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'is_manager': isManager,
    };

    print('📤 Отправка данных для регистрации:');
    data.forEach((key, value) {
      if (key == 'password') {
        print('  $key: ********');
      } else {
        print('  $key: $value');
      }
    });

    try {
      final response = await _apiService.post('/auth/register', data);
      final user = UserModel.fromJson(response);

      print('✅ Регистрация успешна!');
      print('👤 Пользователь создан: ${user.username} (${user.email})');
      print('👔 Роль: ${user.isManager ? "Менеджер" : "Пользователь"}');

      // Сохраняем данные
      await StorageService.saveToken(user.accessToken);
      await StorageService.saveUser(user);

      print('💾 Данные сохранены в локальное хранилище');

      return user;
    } catch (e) {
      print('❌ Ошибка при регистрации: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    print('🚪 Начало процесса выхода...');
    await StorageService.clearStorage();
    print('✅ Выход выполнен. Данные очищены.');
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    final result = token != null && token.isNotEmpty;
    print('🔍 Проверка авторизации: ${result ? "✅ Авторизован" : "❌ Не авторизован"}');
    return result;
  }

  Future<UserModel?> getCurrentUser() async {
    print('👤 Получение данных текущего пользователя...');
    final user = await StorageService.getUser();
    if (user != null) {
      print('✅ Данные пользователя получены: ${user.username}');
    } else {
      print('❌ Пользователь не найден в хранилище');
    }
    return user;
  }

  Future<Map<String, dynamic>> hello() async {
    try {
      final response = await _apiService.get('/auth/hello', authRequired: true);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}