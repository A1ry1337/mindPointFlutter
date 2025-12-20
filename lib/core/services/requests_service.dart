import 'package:te4st_proj_flut/core/services/api_service.dart';
import 'package:te4st_proj_flut/models/manager_request_model.dart';

class RequestsService {
  final ApiService _apiService = ApiService();

  Future<List<ManagerRequest>> getMyRequests() async {
    final response = await _apiService.get(
      '/employee_settings/my_manager_requests',
      authRequired: true,
    );
    if (response is List) {
      return response
          .map((e) => ManagerRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Invalid response');
  }

  Future<void> sendManagerRequest(String managerUsername) async {
    await _apiService.post(
      '/employee_settings/request_manager_by_name',
      {'manager_username': managerUsername},
      authRequired: true,
    );
  }
}