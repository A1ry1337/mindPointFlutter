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
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: isLastEmployee
                                    ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                )
                                    : BorderRadius.zero,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onEditEmployee(e),
                                  borderRadius: isLastEmployee
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
    final teamsResponse = await service.getTeamMembers();
    final allTeams = teamsResponse.map((t) => t.team).toList();

    const Color brandColor = Color(0xFF722ED1);
    const Color moveColor = Colors.purple;
    const Color promoteColor = Colors.blue;
    const Color demoteColor = Colors.red;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Индикатор закрытия
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Действия с ${employee.fullname}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // === Назначить / Снять тимлида ===
                if (employee.teams.any((t) => t.id == team.id)) ...[
                  Material(
                    type: MaterialType.transparency,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
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
                            if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                            _load();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка: $e')),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: (employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead
                            ? demoteColor
                            : promoteColor)
                            .withOpacity(0.08),
                        splashColor: (employee.teams
                            .firstWhere((t) => t.id == team.id)
                            .isTeamlead
                            ? demoteColor
                            : promoteColor)
                            .withOpacity(0.15),
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                employee.teams
                                    .firstWhere((t) => t.id == team.id)
                                    .isTeamlead
                                    ? Icons.arrow_downward
                                    : Icons.leaderboard_outlined,
                                color: employee.teams
                                    .firstWhere((t) => t.id == team.id)
                                    .isTeamlead
                                    ? demoteColor
                                    : promoteColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                employee.teams
                                    .firstWhere((t) => t.id == team.id)
                                    .isTeamlead
                                    ? 'Снять с должности тимлида'
                                    : 'Назначить тимлидом',
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // === Переместить в другую команду ===
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await _showMoveToTeamSheet(
                          context: context,
                          employee: employee,
                          currentTeamId: team.id,
                          allTeams: allTeams,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: moveColor.withOpacity(0.08),
                      splashColor: moveColor.withOpacity(0.15),
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, color: moveColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Переместить в другую команду',
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // === Удалить из команды — КРАСНАЯ КНОПКА (как в эталоне) ===
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await _showConfirmationDialog(
                        context,
                        'Удалить из команды',
                        'Вы уверены, что хотите удалить ${employee.fullname} из команды "${team.name}"?',
                      );
                      if (confirm == true) {
                        try {
                          await service.removeMemberFromTeam(team.id, employee.id);
                          if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                          _load();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Удалить из команды'),
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

    const Color brandColor = Color(0xFF722ED1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
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
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Назначить участника "${employee.fullname}" в команду:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Кнопки: как во втором варианте, но с правильным ховером
                for (final team in allTeams) ...[
                  Material(
                    type: MaterialType.transparency,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          await _showRoleSelectionSheet(context, employee, team);
                        },
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: brandColor.withOpacity(0.08),   // ← фиолетовый ховер
                        splashColor: brandColor.withOpacity(0.15),  // ← фиолетовый сплеш
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.group, color: brandColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // ← отступ между кнопками
                ],

                const SizedBox(height: 8), // ← отступ между последней командой и кнопкой

                // Кнопка "Удалить из компании"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await _showConfirmationDialog(
                        context,
                        'Удалить из компании',
                        'Вы уверены, что хотите удалить ${employee.fullname} из компании навсегда?',
                      );
                      if (confirm == true) {
                        try {
                          await service.removeMemberFromCompany(employee.id);
                          if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                          _load();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Удалить из компании'),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRoleSelectionSheet(
      BuildContext context,
      Employee employee,
      Team team,
      ) async {
    const Color brandColor = Color(0xFF722ED1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
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
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Роль в команде "${team.name}"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // === Кнопка: Назначить участником ===
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          await ManagementService().addMembersToTeam(team.id, [employee.id]);
                          if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                          _load();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: Colors.grey[700]!.withOpacity(0.08), // серовато-фиолетовый ховер, как в оригинале
                      splashColor: Colors.grey[700]!.withOpacity(0.15),
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey[700], size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Назначить участником',
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // === Кнопка: Назначить тимлидом ===
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        try {
                          await ManagementService().addMembersToTeam(team.id, [employee.id]);
                          await Future.delayed(const Duration(milliseconds: 300));
                          await ManagementService().assignTeamLead(team.id, employee.id);
                          if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                          _load();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: brandColor.withOpacity(0.08),
                      splashColor: brandColor.withOpacity(0.15),
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.leaderboard_outlined, color: brandColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Назначить тимлидом',
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
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

// Вспомогательный метод для кнопок ролей (всё ещё внутри одного класса)
  Widget _buildRoleButton(
      BuildContext ctx,
      IconData icon,
      String label,
      Color iconColor,
      VoidCallback onPressed,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        hoverColor: iconColor.withOpacity(0.08),
        splashColor: iconColor.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateTeamBottomSheet(BuildContext context) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Дрэг-хендл (индикатор)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Заголовок
              Text(
                'Создать новую команду',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Поле ввода
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _createTeamAndClose(ctx, controller.text.trim(), context);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Название команды',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(Icons.group, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),

              // Кнопка создания
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _createTeamAndClose(ctx, controller.text.trim(), context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF722ED1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: const Color(0xFF722ED1).withOpacity(0.3),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Создать команду'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ).then((_) => controller.dispose()); // Автоматически освобождаем контроллер
  }

  Future<void> _createTeamAndClose(
      BuildContext sheetContext,
      String teamName,
      BuildContext originalContext,
      ) async {
    try {
      await ManagementService().createTeam(teamName);
      if (Navigator.canPop(sheetContext)) {
        Navigator.of(sheetContext).pop();
      }
      _load();
    } catch (e) {
      if (originalContext.mounted) {
        ScaffoldMessenger.of(originalContext).showSnackBar(
          SnackBar(
            content: Text('Не удалось создать команду: ${e.toString()}'),
            backgroundColor: Theme.of(originalContext).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showTeamActionsBottomSheet(BuildContext context, TeamWithEmployees team) async {
    const Color brandRed = Colors.red;
    const Color brandColor = Color(0xFF722ED1); // на случай, если захотите использовать фиолетовый для других действий

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Индикатор закрытия
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Действия с командой',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // === Кнопка: Удалить команду ===
                Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        final confirm = await _showConfirmationDialog(
                          context,
                          'Удалить команду',
                          'Вы уверены, что хотите удалить команду "${team.team.name}"?\nВсе участники будут перемещены в "Без команды".',
                        );
                        if (confirm == true) {
                          try {
                            await ManagementService().deleteTeam(team.team.id);
                            if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                            _load();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка: $e')),
                              );
                            }
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      hoverColor: brandRed.withOpacity(0.08),   // ← красный ховер (не серый!)
                      splashColor: brandRed.withOpacity(0.15),  // ← красный сплеш
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: brandRed, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Удалить команду',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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