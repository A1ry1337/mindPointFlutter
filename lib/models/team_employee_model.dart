class TeamWithEmployees {
  final Team team;
  final List<Employee> employees;

  TeamWithEmployees({
    required this.team,
    required this.employees,
  });
}

class Employee {
  final String id;
  final String username;
  final String fullname;
  final List<Team> teams;

  Employee({
    required this.id,
    required this.username,
    required this.fullname,
    required this.teams,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      teams: (json['teams'] as List<dynamic>? ?? [])
          .map((team) => Team.fromJson(team as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Team {
  final String id;
  final String name;
  final bool isTeamlead;

  Team({
    required this.id,
    required this.name,
    required this.isTeamlead,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isTeamlead: json['is_teamlead'] ?? false,
    );
  }
}