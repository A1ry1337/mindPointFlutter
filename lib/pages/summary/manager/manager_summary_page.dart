import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/layout/AppLayout.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';
import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:te4st_proj_flut/models/user_model.dart';

class ManagerSummaryPage extends StatefulWidget {
  const ManagerSummaryPage({Key? key}) : super(key: key);

  @override
  _ManagerSummaryPageState createState() => _ManagerSummaryPageState();
}

class _ManagerSummaryPageState extends State<ManagerSummaryPage> {

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        child: Text('MANAGER')
    );
  }
}