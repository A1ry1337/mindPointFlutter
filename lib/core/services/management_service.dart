import 'package:te4st_proj_flut/core/services/api_service.dart';
import 'package:te4st_proj_flut/models/team_employee_model.dart';

class ManagementService {
  final ApiService _apiService = ApiService();

  // Получить всех сотрудников сгруппированных по командам
  Future<List<TeamWithEmployees>> getEmployeesGroupedByTeam() async {
    try {
      final response = await _apiService.get(
        '/management/get_all_employees',
        authRequired: true,
      );

      if (response is List) {
        final employees = response
            .map<Employee>((item) =>
            Employee.fromJson(item as Map<String, dynamic>))
            .toList();

        // Группируем сотрудников по командам
        return _groupEmployeesByTeam(employees);
      }

      throw Exception('Invalid response format');
    } catch (e, stackTrace) {
      print('❌ Ошибка в getEmployeesGroupedByTeam: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Группировка сотрудников по командам
  List<TeamWithEmployees> _groupEmployeesByTeam(List<Employee> employees) {
    final Map<String, TeamWithEmployees> teamMap = {};
    final List<Employee> employeesWithoutTeam = [];

    // Проходим по всем сотрудникам
    for (var employee in employees) {
      if (employee.teams.isEmpty) {
        employeesWithoutTeam.add(employee);
      } else {
        for (var team in employee.teams) {
          if (!teamMap.containsKey(team.id)) {
            teamMap[team.id] = TeamWithEmployees(
              team: team,
              employees: [],
            );
          }
          teamMap[team.id]!.employees.add(employee);
        }
      }
    }

    final List<TeamWithEmployees> result = teamMap.values.toList();

    // Добавляем группу "Без команды", если есть такие сотрудники
    if (employeesWithoutTeam.isNotEmpty) {
      result.add(TeamWithEmployees(
        team: Team(
          id: 'no_team',
          name: 'Без команды',
          isTeamlead: false,
        ),
        employees: employeesWithoutTeam,
      ));
    }

    // Сортируем: сначала команды с тимлидами, затем по алфавиту
    result.sort((a, b) {
      if (a.team.isTeamlead && !b.team.isTeamlead) return -1;
      if (!a.team.isTeamlead && b.team.isTeamlead) return 1;
      return a.team.name.compareTo(b.team.name);
    });

    return result;
  }

  // Получить список всех команд с участниками и тимлидами
  Future<List<TeamMembersResponse>> getTeamMembers() async {
    final response = await _apiService.get(
      '/management/get_team_members',
      authRequired: true,
    );
    if (response is List) {
      return response.map((item) => TeamMembersResponse.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid team members response');
  }

  // Создать команду
  Future<void> createTeam(String name) async {
    await _apiService.post(
      '/management/create_team',
      {'name': name},
      authRequired: true,
    );
  }

  //Удалить команду
  Future<void> deleteTeam(String teamId) async {
    await _apiService.delete(
      '/management/delete_team/$teamId',
      authRequired: true,
    );
  }

  // Назначить тимлида
  Future<void> assignTeamLead(String teamId, String userId) async {
    await _apiService.post(
      '/management/assign_team_lead_to_team',
      {'team_id': teamId, 'user_id': userId},
      authRequired: true,
    );
  }

  // Снять тимлида
  Future<void> revokeTeamLead(String teamId, String userId) async {
    await _apiService.post(
      '/management/revoke_team_lead_from_team',
      {'team_id': teamId, 'user_id': userId},
      authRequired: true,
    );
  }

  // Удалить участника из команды
  Future<void> removeMemberFromTeam(String teamId, String userId) async {
    await _apiService.post(
      '/management/remove_member_from_team',
      {'team_id': teamId, 'user_id': userId},
      authRequired: true,
    );
  }

  //Удалить участника из компании
  Future<void> removeMemberFromCompany(String userId) async {
    await _apiService.delete(
      '/management/remove_member_from_company/$userId',
      authRequired: true,
    );
  }

  // Переместить в другую команду
  Future<void> moveMemberToAnotherTeam({
    required String userId,
    required String fromTeamId,
    required String toTeamId,
  }) async {
    await _apiService.post(
      '/management/move_member_to_another_team',
      {'user_id': userId, 'from_team_id': fromTeamId, 'to_team_id': toTeamId},
      authRequired: true,
    );
  }

  // Добавить нескольких участников в команду
  Future<void> addMembersToTeam(String teamId, List<String> userIds) async {
    await _apiService.post(
      '/management/add_members_in_team',
      {'team_id': teamId, 'user_ids': userIds},
      authRequired: true,
    );
  }
}