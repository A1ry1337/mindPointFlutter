import 'package:flutter/material.dart';
import 'package:te4st_proj_flut/core/layout/AppLayout.dart';
import 'package:te4st_proj_flut/core/services/management_service.dart';
import 'package:te4st_proj_flut/models/team_employee_model.dart';

class ManagerSummaryPage extends StatefulWidget {
  const ManagerSummaryPage({Key? key}) : super(key: key);

  @override
  State<ManagerSummaryPage> createState() => _ManagerSummaryPageState();
}

class _ManagerSummaryPageState extends State<ManagerSummaryPage> {
  final ManagementService _service = ManagementService();

  static const double _hPadding = 16;
  static const double _rowHeight = 48;
  static const double _employeeIndent = 30;

  List<TeamWithEmployees> _teams = [];
  List<Employee> _employeesWithoutTeam = [];
  final Map<String, bool> _expanded = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getEmployeesGroupedByTeam();

    final List<TeamWithEmployees> filtered = [];
    final List<Employee> employeesWithoutTeam = [];

    for (var teamData in data) {
      if (teamData.team.name.toLowerCase() == 'без команды') {
        employeesWithoutTeam.addAll(teamData.employees);
      } else {
        filtered.add(teamData);
      }
    }

    setState(() {
      _teams = filtered;
      _employeesWithoutTeam = employeesWithoutTeam;
      _expanded
        ..clear()
        ..addEntries(
          filtered.map((t) => MapEntry(t.team.id, false)),
        );
      _loading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      _expanded[id] = !(_expanded[id] ?? false);
    });
  }

  // Заглушки для действий
  void _onEditEmployee(Employee employee) async {
    // Если сотрудник в "Без команды" — показываем специальный шит
    final isInNoTeam = _employeesWithoutTeam.contains(employee);

    if (isInNoTeam) {
      await _showNoTeamEmployeeActions(context, employee);
    } else {
      // Иначе — найдём его команду и покажем действия по команде
      for (var teamData in _teams) {
        if (teamData.employees.contains(employee)) {
          await _showEmployeeActionsBottomSheet(
            context: context,
            employee: employee,
            team: teamData.team,
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child: Scaffold(
        backgroundColor: const Color(0xFFDDEDFD),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔍 ПОИСК
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 📋 ТАБЛИЦА КОМАНД
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTeamsTable(),

                  const SizedBox(height: 24),

                  /// 📋 ТАБЛИЦА СОТРУДНИКОВ БЕЗ КОМАНДЫ
                  if (_employeesWithoutTeam.isNotEmpty) _buildNoTeamTable(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔵 ЗАГОЛОВОК ТАБЛИЦЫ КОМАНД
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF793CAE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text(
                  'Списки команд',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreateTeamBottomSheet(context),
                ),
              ],
            ),
          ),

          /// 🟢 ХЕДЕР СТОЛБЦОВ КОМАНД
          Container(
            height: _rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: _hPadding),
            color: Colors.teal[50],
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Название команды',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Кол-во',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Роль',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// 📄 ДАННЫЕ КОМАНД
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _teams.asMap().entries.map((entry) {
              final index = entry.key;
              final team = entry.value;
              final isOpen = _expanded[team.team.id] ?? false;
              final isLastTeam = index == _teams.length - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// КОМАНДА
                  Material(
                    color: const Color(0xFFB4CCEF),
                    borderRadius: isLastTeam && !isOpen
                        ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                        : BorderRadius.zero,
                    child: InkWell(
                      onTap: () => _toggle(team.team.id),
                      onLongPress: () => _showTeamActionsBottomSheet(context, team),
                      borderRadius: isLastTeam && !isOpen
                          ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )
                          : BorderRadius.zero,
                      child: Container(
                        height: _rowHeight,
                        padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    isOpen ? Icons.expand_less : Icons.expand_more,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    team.team.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${team.employees.length}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// СОТРУДНИКИ В КОМАНДЕ
                  if (isOpen)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: team.employees.asMap().entries.map((empEntry) {
                        final empIndex = empEntry.key;
                        final e = empEntry.value;
                        final isLastEmployee = empIndex == team.employees.length - 1;
                        final role = e.teams
                            .firstWhere((t) => t.id == team.team.id)
                            .isTeamlead
                            ? 'Тимлид'
                            : 'Сотрудник';

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _onEditEmployee(e), // <-- вызываем редактирование при нажатии
                              child: Container(
                                height: _rowHeight,
                                padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: _employeeIndent),
                                          Expanded(
                                            child: Text(
                                              e.fullname,
                                              style: const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Expanded(
                                      child: Text(
                                        role,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: role == 'Тимлид' ? Colors.amber[700] : Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Divider между сотрудниками, но не после последнего
                            if (!isLastEmployee) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),

                  // Divider между командами, но не после последней команды
                  if (!isLastTeam) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTeamTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔵 ЗАГОЛОВОК ТАБЛИЦЫ СОТРУДНИКОВ БЕЗ КОМАНДЫ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF793CAE),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Сотрудники без команд',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// 🟢 ХЕДЕР СТОЛБЦОВ СОТРУДНИКОВ БЕЗ КОМАНДЫ
          Container(
            height: _rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: _hPadding),
            color: Colors.teal[50],
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'ФИО',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Назначить/удалить',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// 📄 ДАННЫЕ СОТРУДНИКОВ БЕЗ КОМАНДЫ
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _employeesWithoutTeam.asMap().entries.map((entry) {
              final index = entry.key;
              final employee = entry.value;
              final isLastEmployee = index == _employeesWithoutTeam.length - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: _rowHeight,
                    padding: const EdgeInsets.symmetric(horizontal: _hPadding),
                    child: Row(
                      children: [
                        /// ФИО СОТРУДНИКА
                        Expanded(
                          flex: 3,
                          child: Text(
                            employee.fullname,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        /// КНОПКИ ДЕЙСТВИЙ
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /// КНОПКА РЕДАКТИРОВАНИЯ (карандашик)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () => _onEditEmployee(employee),
                              ),
                              const SizedBox(width: 16),

                              /// КНОПКА УДАЛЕНИЯ (крестик)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => _showDeleteConfirmationBottomSheet(context, employee),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider между сотрудниками, но не после последнего
                  if (!isLastEmployee) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Future<void> _showEmployeeActionsBottomSheet({
    required BuildContext context,
    required Employee employee,
    required Team team,
  }) async {
    final service = ManagementService();

    // Получим список всех команд для перемещения
    final teamsResponse = await service.getTeamMembers();
    final allTeams = teamsResponse.map((t) => t.team).toList();

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Действия с ${employee.fullname}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Сделать тимлидом / снять
                if (employee.teams.any((t) => t.id == team.id))
                  Material(
                    child: ListTile(
                      title: Text(
                        employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead
                            ? 'Снять с должности тимлида'
                            : 'Назначить тимлидом',
                      ),
                      leading: Icon(
                        employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead
                            ? Icons.arrow_downward
                            : Icons.leaderboard_outlined,
                        color: employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead
                            ? Colors.red
                            : Colors.blue,
                      ),
                      onTap: () async {
                        final isTeamlead = employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead;
                        try {
                          if (isTeamlead) {
                            await service.revokeTeamLead(team.id, employee.id);
                          } else {
                            await service.assignTeamLead(team.id, employee.id);
                          }
                          Navigator.of(ctx).pop();
                          _load(); // обновить данные
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка: $e')),
                          );
                        }
                      },
                    ),
                  ),

                const Divider(),

                // Переместить в другую команду
                Material(
                  child: ListTile(
                    title: const Text('Переместить в другую команду'),
                    leading: const Icon(Icons.swap_horiz, color: Colors.purple),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _showMoveToTeamSheet(
                        context: context,
                        employee: employee,
                        currentTeamId: team.id,
                        allTeams: allTeams,
                      );
                    },
                  ),
                ),

                const Divider(),

                // Удалить из команды
                Material(
                  child: ListTile(
                    title: const Text('Удалить из команды'),
                    leading: const Icon(Icons.remove_circle, color: Colors.orange),
                    onTap: () async {
                      final confirm = await _showConfirmationDialog(
                        context,
                        'Удалить из команды',
                        'Вы уверены, что хотите удалить ${employee.fullname} из команды "${team.name}"?',
                      );
                      if (confirm == true) {
                        try {
                          await service.removeMemberFromTeam(team.id, employee.id);
                          Navigator.of(ctx).pop();
                          _load();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMoveToTeamSheet({
    required BuildContext context,
    required Employee employee,
    required String currentTeamId,
    required List<Team> allTeams,
  }) async {
    final filteredTeams = allTeams.where((t) => t.id != currentTeamId).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите команду', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...filteredTeams.map((team) {
              return ListTile(
                title: Text(team.name),
                onTap: () async {
                  try {
                    final service = ManagementService();
                    await service.moveMemberToAnotherTeam(
                      userId: employee.id,
                      fromTeamId: currentTeamId,
                      toTeamId: team.id,
                    );
                    Navigator.of(ctx).pop();
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showNoTeamEmployeeActions(BuildContext context, Employee employee) async {
    final service = ManagementService();
    final teamsResponse = await service.getTeamMembers();
    final allTeams = teamsResponse.map((t) => t.team).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Назначить ${employee.fullname}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Назначить в команду как участник или тимлид
            ...allTeams.map((team) {
              return Column(
                children: [
                  ListTile(
                    title: Text('В команду "${team.name}" как участник'),
                    onTap: () async {
                      try {
                        await service.addMembersToTeam(team.id, [employee.id]);
                        Navigator.of(ctx).pop();
                        _load();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка: $e')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Сделать тимлидом в "${team.name}"'),
                    onTap: () async {
                      try {
                        await service.addMembersToTeam(team.id, [employee.id]);
                        await Future.delayed(const Duration(milliseconds: 300)); // дать время добавиться
                        await service.assignTeamLead(team.id, employee.id);
                        Navigator.of(ctx).pop();
                        _load();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка: $e')),
                        );
                      }
                    },
                  ),
                  const Divider(),
                ],
              );
            }).toList(),

            // Удалить из компании
            Material(
              child: ListTile(
                title: const Text('Удалить из компании', style: TextStyle(color: Colors.red)),
                leading: const Icon(Icons.delete, color: Colors.red),
                onTap: () async {
                  final confirm = await _showConfirmationDialog(
                    context,
                    'Удалить из компании',
                    'Вы уверены, что хотите удалить ${employee.fullname} из компании навсегда?',
                  );
                  if (confirm == true) {
                    try {
                      // await service.removeMemberFromCompany(employee.id);
                      Navigator.of(ctx).pop();
                      _load();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: $e')),
                      );
                    }
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateTeamBottomSheet(BuildContext context) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Создать новую команду', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Название команды',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  try {
                    await ManagementService().createTeam(controller.text.trim());
                    Navigator.of(ctx).pop();
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                }
              },
              child: const Text('Создать'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTeamActionsBottomSheet(BuildContext context, TeamWithEmployees team) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Действия с командой', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Удалить команду', style: TextStyle(color: Colors.red)),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () async {
                final confirm = await _showConfirmationDialog(
                  context,
                  'Удалить команду',
                  'Вы уверены, что хотите удалить команду "${team.team.name}"?\nВсе участники будут перемещены в "Без команды".',
                );
                if (confirm == true) {
                  try {
                    await ManagementService().deleteTeam(team.team.id);
                    Navigator.of(ctx).pop();
                    _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context,
      String title,
      String content,
      ) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Подтвердить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationBottomSheet(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Индикатор BottomSheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Заголовок
              Text(
                'Удалить ${employee.fullname}?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Сотрудник будет полностью удалён из компании. Это действие нельзя отменить.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Кнопка подтверждения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop(); // закрыть BottomSheet

                    try {
                      await _service.removeMemberFromCompany(employee.id);
                      if (context.mounted) {
                        _load();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Удалить навсегда'),
                ),
              ),

              const SizedBox(height: 12),

              // Кнопка отмены
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Отмена'),
              ),
            ],
          ),
        );
      },
    );
  }
}