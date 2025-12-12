import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/pages/auth/auth_router.dart';
import 'package:te4st_proj_flut/pages/summary/summary_router.dart';

class PagesRouter {
  static List<GoRoute> getAllRoutes() {
    final List<GoRoute> allRoutes = [];

    allRoutes.addAll([
        ...AuthRouter.getRoutes(),
        ...SummaryRouter.getRoutes()
    ]);

    return allRoutes;
  }
}