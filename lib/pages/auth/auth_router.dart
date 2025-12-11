import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/pages/auth/register/register_page.dart';

import 'hello.dart';
import 'login/login_page.dart';


class AuthRouter {
  static List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'main',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HelloPage(),
        ),
      ),
    ];
  }
}