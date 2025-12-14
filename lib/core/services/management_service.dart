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
}