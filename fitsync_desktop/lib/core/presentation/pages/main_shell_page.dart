import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/locale_provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/dashboard/presentation/pages/dashboard_overview_page.dart';
import '../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../features/trainings/presentation/pages/trainings_page.dart';
import '../../../features/trainings/presentation/providers/trainings_provider.dart';
import '../../../features/reservations/presentation/pages/reservations_page.dart';
import '../../../features/reservations/presentation/providers/reservations_provider.dart';
import '../../../features/users/presentation/pages/users_page.dart';
import '../../../features/users/presentation/providers/users_provider.dart';
import '../../../features/reviews/presentation/pages/reviews_page.dart';
import '../../../features/reviews/presentation/providers/reviews_provider.dart';
import '../../../features/training_types/presentation/pages/training_types_page.dart';
import '../../../features/training_types/presentation/providers/training_types_provider.dart';
import '../../../features/additional_services/presentation/pages/additional_services_page.dart';
import '../../../features/additional_services/presentation/providers/additional_services_provider.dart';
import '../../../features/payments/presentation/pages/payments_page.dart';
import '../../../features/payments/presentation/providers/payments_provider.dart';
import '../../../injection_container.dart' as di;

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _selectedIndex = 0;

  void _onTabSelected(BuildContext innerContext, int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        innerContext.read<DashboardProvider>().loadStats();
        innerContext.read<AdminPaymentsProvider>().load();
      case 1: innerContext.read<TrainingsProvider>().loadTrainings();
      case 2: innerContext.read<TrainingTypesProvider>().load();
      case 3: innerContext.read<AdditionalServicesProvider>().load();
      case 4: innerContext.read<ReservationsProvider>().loadReservations();
      case 5: innerContext.read<UsersProvider>().loadUsers();
      case 6: innerContext.read<ReviewsProvider>().loadReviews();
      case 7: innerContext.read<AdminPaymentsProvider>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final navItems = [
      _NavItem(icon: Icons.dashboard, label: l.navDashboard),
      _NavItem(icon: Icons.fitness_center, label: l.navTrainings),
      _NavItem(icon: Icons.category, label: l.navTrainingTypes),
      _NavItem(icon: Icons.add_box_outlined, label: l.navAdditionalServices),
      _NavItem(icon: Icons.calendar_today, label: l.navReservations),
      _NavItem(icon: Icons.people, label: l.navClients),
      _NavItem(icon: Icons.star, label: l.navReviews),
      _NavItem(icon: Icons.receipt_long, label: l.navPayments),
    ];

    final user = context.watch<AuthProvider>().user;

    return MultiProvider(
      providers: [
        Provider.value(value: di.sl<SharedPreferences>()),
        ChangeNotifierProvider(create: (_) => di.sl<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TrainingsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TrainingTypesProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdditionalServicesProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReservationsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UsersProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReviewsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminPaymentsProvider>()),
      ],
      child: ChangeNotifierProvider.value(
        value: context.read<LocaleProvider>(),
        child: Builder(builder: (innerContext) => Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: Row(
            children: [
              _Sidebar(
                selectedIndex: _selectedIndex,
                navItems: navItems,
                user: user,
                adminPanelLabel: l.adminPanel,
                logoutTooltip: l.logout,
                onDestinationSelected: (i) => _onTabSelected(innerContext, i),
                onLogout: () => innerContext.read<AuthProvider>().logout(),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF0F1923),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      DashboardOverviewPage(),
                      TrainingsPage(),
                      TrainingTypesPage(),
                      AdditionalServicesPage(),
                      ReservationsPage(),
                      UsersPage(),
                      ReviewsPage(),
                      PaymentsPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          )),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final dynamic user;
  final String adminPanelLabel;
  final String logoutTooltip;
  final void Function(int) onDestinationSelected;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.user,
    required this.adminPanelLabel,
    required this.logoutTooltip,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF152030),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFFE8622A), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'FITSync',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              adminPanelLabel,
              style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, i) {
                final item = navItems[i];
                final selected = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onDestinationSelected(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFE8622A).withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected ? const Color(0xFFE8622A) : Colors.grey[500],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.grey[400],
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                final l = AppLocalizations.of(context)!;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showLanguageDialog(context, l, localeProvider),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(children: [
                        Icon(Icons.language, color: Colors.grey[500], size: 18),
                        const SizedBox(width: 10),
                        Text(
                          localeProvider.locale.languageCode == 'bs' ? l.bosnian : l.english,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                        const Spacer(),
                        Icon(Icons.swap_horiz, color: Colors.grey[600], size: 16),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.2),
                  child: Text(
                    user?.firstName?.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Color(0xFFE8622A), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.role ?? '',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.grey[500], size: 18),
                  onPressed: onLogout,
                  tooltip: logoutTooltip,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

void _showLanguageDialog(BuildContext context, AppLocalizations l, LocaleProvider localeProvider) {
  final prefs = context.read<SharedPreferences>();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E2A3A),
      title: Text(l.selectLanguage, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l.bosnian, style: const TextStyle(color: Colors.white)),
            trailing: localeProvider.locale.languageCode == 'bs'
                ? const Icon(Icons.check, color: Color(0xFFE8622A)) : null,
            onTap: () { localeProvider.setLocale(const Locale('bs'), prefs); Navigator.pop(context); },
          ),
          ListTile(
            title: Text(l.english, style: const TextStyle(color: Colors.white)),
            trailing: localeProvider.locale.languageCode == 'en'
                ? const Icon(Icons.check, color: Color(0xFFE8622A)) : null,
            onTap: () { localeProvider.setLocale(const Locale('en'), prefs); Navigator.pop(context); },
          ),
        ],
      ),
    ),
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

