import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/pages/auth/register/register_page.dart';

import 'employee/employee_summary_page.dart';
import 'manager/manager_summary_page.dart';


class SummaryRouter {
  static List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: '/employee_summary',
        name: 'employee_summary',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const EmployeeSummaryPage(),
        ),
      ),
      GoRoute(
        path: '/manager_summary',
        name: 'manager_summary',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ManagerSummaryPage(),
        ),
      ),
    ];
  }
}