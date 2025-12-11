import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/pages/auth/auth_router.dart';

class PagesRouter {
  static List<GoRoute> getAllRoutes() {
    final List<GoRoute> allRoutes = [];

    // Добавляем роуты из модуля авторизации
    allRoutes.addAll(AuthRouter.getRoutes());

    // Здесь можно добавлять роуты из других модулей
    // allRoutes.addAll(HomeRouter.getRoutes());
    // allRoutes.addAll(ProfileRouter.getRoutes());

    return allRoutes;
  }
}