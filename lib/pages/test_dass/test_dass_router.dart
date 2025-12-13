import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/pages/test_dass/test_dass_page.dart';

class TestDassRouter {
  static List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: '/test_dass',
        name: 'test_dass',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TestDassPage(),
        ),
      ),
    ];
  }
}