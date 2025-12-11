import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/routers/pages_router.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';


class AppRouter {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    redirect: (context, state) async {
      // Проверяем авторизацию
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      final isAuthPage = state.location.startsWith('/login') ||
          state.location.startsWith('/register');

      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      ...PagesRouter.getAllRoutes(),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      ),
    ),
  );
}