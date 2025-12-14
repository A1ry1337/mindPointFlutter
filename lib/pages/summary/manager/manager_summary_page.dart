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
  void _onEditEmployee(Employee employee) {
    print('Редактирование сотрудника: ${employee.id}');
    // TODO: Реализовать редактирование
  }

  void _onDeleteEmployee(Employee employee) {
    print('Удаление сотрудника: ${employee.id}');
    // TODO: Реализовать удаление с подтверждением
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
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Списки команд',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
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
                              flex: 3,
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
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
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
                    'Назначить команду/удалить',
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
                                onPressed: () => _onDeleteEmployee(employee),
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
}