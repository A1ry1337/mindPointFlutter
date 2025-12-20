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

class TeamMembersResponse {
  final Team team;
  final List<Employee> members;
  final List<Employee> teamLeads;

  TeamMembersResponse({
    required this.team,
    required this.members,
    required this.teamLeads,
  });

  factory TeamMembersResponse.fromJson(Map<String, dynamic> json) {
    return TeamMembersResponse(
      team: Team.fromJson(json['team']),
      members: (json['members'] as List)
          .map((e) => Employee.fromJson(e as Map<String, dynamic>))
          .toList(),
      teamLeads: (json['team_leads'] as List)
          .map((e) => Employee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserJoinRequest {
  final String requestId;
  final String userId;
  final String fullName;
  final String username;
  final DateTime createdAt;

  UserJoinRequest({
    required this.requestId,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.createdAt,
  });

  factory UserJoinRequest.fromJson(Map<String, dynamic> json) {
    return UserJoinRequest(
      requestId: json['request_id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['full_name'] ?? json['username'] ?? 'Неизвестно',
      username: json['username'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}