import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te4st_proj_flut/core/services/auth_service.dart';
import 'package:te4st_proj_flut/core/services/requests_service.dart';
import 'package:te4st_proj_flut/models/manager_request_model.dart';
import 'package:te4st_proj_flut/models/user_model.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final bool showBackButton;

  const AppLayout({
    Key? key,
    required this.child,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final AuthService authService = AuthService();
  bool isHovering = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _openProfileSheet(BuildContext context) {
    // Скрываем клавиатуру перед открытием bottom sheet
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: FutureBuilder<List<ManagerRequest>>(
            future: RequestsService().getMyRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text('Ошибка загрузки заявок',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              }

              final requests = snapshot.data ?? [];

              return ProfileSheetContent(
                currentUser: _currentUser,
                requests: requests,
              );
            },
          ),
        );
      },
    ).then((_) {
      // При закрытии bottom sheet тоже скрываем клавиатуру
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(47),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                height: 37,
                color: Colors.white,
                child: Row(
                  children: [
                    if (widget.showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isHovering = true),
                        onExit: (_) => setState(() => isHovering = false),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openProfileSheet(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isHovering
                                  ? Colors.grey.shade100
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isHovering
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 10,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFDDEDFD),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}

class ProfileSheetContent extends StatefulWidget {
  final UserModel? currentUser;
  final List<ManagerRequest> requests;

  const ProfileSheetContent({
    Key? key,
    required this.currentUser,
    required this.requests,
  }) : super(key: key);

  @override
  State<ProfileSheetContent> createState() => _ProfileSheetContentState();
}

class _ProfileSheetContentState extends State<ProfileSheetContent> {
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageSize = 3;
    final pages = <List<ManagerRequest>>[];
    for (int i = 0; i < widget.requests.length; i += pageSize) {
      pages.add(widget.requests.sublist(
        i,
        i + pageSize < widget.requests.length
            ? i + pageSize
            : widget.requests.length,
      ));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (widget.currentUser != null) ...[
                // Аватар
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      widget.currentUser!.fullname.isNotEmpty
                          ? widget.currentUser!.fullname[0].toUpperCase()
                          : widget.currentUser!.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ФИО
                Center(
                  child: Text(
                    widget.currentUser!.fullname.isEmpty
                        ? widget.currentUser!.username
                        : widget.currentUser!.fullname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Логин
                Center(
                  child: Text(
                    '@${widget.currentUser!.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),

                if (widget.currentUser!.isManager) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Аккаунт менеджера',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                if (widget.currentUser!.email.isNotEmpty &&
                    widget.currentUser!.email != widget.currentUser!.username) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.currentUser!.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ] else ...[
                const Center(
                  child: Text(
                    'Профиль недоступен',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (!widget.currentUser!.isManager) ...[
                // Заголовок
                const Text(
                  'Мои заявки',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Таблица с пагинацией
                if (widget.requests.isEmpty)
                  const Text('Нет заявок', style: TextStyle(color: Colors.grey))
                else
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (ctx, index) {
                        return _buildRequestsTable(pages[index]);
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                // === КНОПКИ НАВИГАЦИИ + ТОЧКИ ===
                if (pages.length > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Кнопка "Назад"
                      IconButton(
                        onPressed: currentPage > 0
                            ? () {
                          pageController.animateToPage(
                            currentPage - 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                          setState(() => currentPage--);
                        }
                            : null,
                        icon: const Icon(Icons.chevron_left, size: 24),
                        color: currentPage > 0 ? Colors.blue : Colors.grey,
                      ),

                      // Точки по центру
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(pages.length, (i) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == currentPage
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                            ),
                          );
                        }),
                      ),

                      // Кнопка "Вперёд"
                      IconButton(
                        onPressed: currentPage < pages.length - 1
                            ? () {
                          pageController.animateToPage(
                            currentPage + 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                          );
                          setState(() => currentPage++);
                        }
                            : null,
                        icon: const Icon(Icons.chevron_right, size: 24),
                        color: currentPage < pages.length - 1
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Синяя кнопка "Отправить заявку"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSendRequestSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1890FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Отправить заявку'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Кнопка "Выйти"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Скрываем клавиатуру перед выходом
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    AuthService().logout();
                  },
                  child: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTable(List<ManagerRequest> requests) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовки
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                    child:
                    Text('Дата', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Компания',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child:
                    Text('Статус', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Строки
          ...requests.map((req) {
            String formatDate(String iso) {
              try {
                final dt = DateTime.parse(iso);
                return '${dt.day}.${dt.month}.${dt.year}';
              } catch (e) {
                return iso.split('T')[0];
              }
            }

            Color statusColor = Colors.grey;
            if (req.status == 'approved') statusColor = Colors.green;
            else if (req.status == 'rejected') statusColor = Colors.red;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formatDate(req.createdAt),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '@${req.managerUsername}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      req.displayStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showSendRequestSheet(BuildContext context) {
    // Сначала скрываем клавиатуру
    FocusScope.of(context).unfocus();

    // Добавляем небольшую задержку для гарантии скрытия клавиатуры
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return _SendRequestSheetContent(
            onRequestSent: (String message) {
              Navigator.of(ctx).pop();
              if (mounted) {
                _showSnackBar(context, message);
              }
            },
            onError: (String error) {
              Navigator.of(ctx).pop();
              if (mounted) {
                _showSnackBar(context, error, isError: true);
              }
            },
          );
        },
      );
    });
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (!context.mounted) return;

    // Скрываем клавиатуру перед показом snackbar
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _SendRequestSheetContent extends StatefulWidget {
  final Function(String) onRequestSent;
  final Function(String) onError;

  const _SendRequestSheetContent({
    required this.onRequestSent,
    required this.onError,
  });

  @override
  _SendRequestSheetContentState createState() =>
      _SendRequestSheetContentState();
}

class _SendRequestSheetContentState extends State<_SendRequestSheetContent> {
  late TextEditingController _controller;
  final RequestsService _requestsService = RequestsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Отправить заявку в компанию',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Логин менеджера',
                  hintText: 'Введите username менеджера',
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () {
                  // Предотвращаем всплытие события
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1890FF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    // Скрываем клавиатуру перед действием
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await _requestsService.sendManagerRequest(text);
                      setState(() {
                        _isLoading = false;
                      });
                      widget.onRequestSent('Заявка отправлена!');
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                      });
                      widget.onError('Данные неверны, заявка не отправлена');
                    }
                  },
                  child: const Text('Отправить'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus(); // Скрываем клавиатуру
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}