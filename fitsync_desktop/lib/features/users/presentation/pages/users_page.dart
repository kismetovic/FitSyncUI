import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user.dart';
import '../providers/users_provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<UsersProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(l.navClients, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => provider.loadUsers(_searchController.text.isEmpty ? null : _searchController.text),
                  tooltip: l.refresh,
                ),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l.searchUsers,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: const Color(0xFF1E2A3A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (v) => provider.loadUsers(v.isEmpty ? null : v),
              ),
              const SizedBox(height: 20),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.users.isEmpty
                        ? _EmptyState(l: l)
                        : _UsersTable(
                            users: provider.users, l: l,
                            onEdit: (u) => _showEditDialog(context, provider, u),
                            onDelete: (u) => _confirmDelete(context, provider, u, l),
                            onSendReminder: (u) => _sendReminder(context, provider, u),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UsersProvider provider, User user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2535),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Uredi korisnika', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: _inputField('Ime', firstCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Prezime', lastCtrl)),
              ]),
              const SizedBox(height: 12),
              _inputField('Email', emailCtrl),
              const SizedBox(height: 12),
              _inputField('Telefon', phoneCtrl),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: const Color(0xFF1E2A3A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Uloga',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF243347),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'Client', child: Text('Client')),
                  DropdownMenuItem(value: 'Administrator', child: Text('Administrator')),
                ],
                onChanged: (v) => setDlgState(() => selectedRole = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Otkazi')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
              onPressed: () async {
                Navigator.pop(context);
                await provider.editUser(
                  id: user.id,
                  firstName: firstCtrl.text,
                  lastName: lastCtrl.text,
                  email: emailCtrl.text,
                  phoneNumber: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                  role: selectedRole,
                );
              },
              child: const Text('Sacuvaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) => TextFormField(
    controller: ctrl,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFF243347),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8622A))),
    ),
  );

  Future<void> _sendReminder(BuildContext context, UsersProvider provider, User user) async {
    final success = await provider.sendReminder(user.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Podsjetnik poslan na ${user.email}' : provider.error ?? 'Greska'),
      backgroundColor: success ? const Color(0xFF27AE60) : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _confirmDelete(BuildContext context, UsersProvider provider, User user, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: Text(l.deleteUser, style: const TextStyle(color: Colors.white)),
        content: Text('${l.delete} "${user.firstName} ${user.lastName}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async { Navigator.pop(context); await provider.remove(user.id); },
            child: Text(l.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final List<User> users;
  final AppLocalizations l;
  final void Function(User) onEdit;
  final void Function(User) onDelete;
  final void Function(User) onSendReminder;
  const _UsersTable({required this.users, required this.l, required this.onEdit, required this.onDelete, required this.onSendReminder});

  static const _p = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  Widget _h(String t) => Padding(padding: _p, child: Text(t, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)));
  Widget _d(Widget w) => Padding(padding: _p, child: w);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E2A3A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(color: Color(0xFF152030),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Expanded(flex: 3, child: _h('Ime i prezime')),
            Expanded(flex: 3, child: _h('Email')),
            Expanded(flex: 2, child: _h('Telefon')),
            Expanded(flex: 1, child: _h('Uloga')),
            Expanded(flex: 2, child: _h('Akcije')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
            itemBuilder: (ctx, i) {
              final u = users[i];
              return InkWell(
                hoverColor: const Color(0xFF243347),
                child: Row(children: [
                  Expanded(flex: 3, child: _d(Row(children: [
                    CircleAvatar(radius: 16,
                      backgroundColor: const Color(0xFF4A90D9).withValues(alpha: 0.2),
                      child: Text(u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.bold))),
                    const SizedBox(width: 10),
                    Expanded(child: Text('${u.firstName} ${u.lastName}',
                        style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                  ]))),
                  Expanded(flex: 3, child: _d(Text(u.email,
                      style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis))),
                  Expanded(flex: 2, child: _d(Text(u.phoneNumber ?? 'u2014',
                      style: const TextStyle(color: Colors.white70)))),
                  Expanded(flex: 1, child: _d(_RoleBadge(u.role))),
                  Expanded(flex: 2, child: _d(Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.email, color: Color(0xFF4A90D9), size: 18),
                      onPressed: () => onSendReminder(u),
                      tooltip: l.sendReminder,
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                      onPressed: () => onEdit(u),
                      tooltip: 'Uredi',
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    if (u.role != 'Administrator') ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () => onDelete(u),
                        tooltip: l.deleteUser,
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ],
                  ]))),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'Administrator';
    final color = isAdmin ? Colors.purple : const Color(0xFF4A90D9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(role, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyState({required this.l});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people, size: 64, color: Colors.grey[700]),
      const SizedBox(height: 16),
      Text(l.noUsersFound, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
