import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../injection_container.dart' as di;
import '../../../trainers/presentation/pages/trainers_page.dart';
import '../../../users/presentation/pages/users_page.dart';
import '../../../users/presentation/providers/users_provider.dart';

/// Everyone who works at the gym, in one place.
///
/// Trainers and administrators are both staff, and the accounts screen used to
/// mix them in with clients under a tab labelled "Klijenti". They are two
/// different records — a trainer is a `Trainer` row with availability and a
/// surcharge, an administrator is a login — so they get a tab each rather than
/// being forced into one list.
class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              l.navStaff,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFFE8622A),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(icon: const Icon(Icons.sports, size: 18), text: l.navTrainersTab),
                Tab(icon: const Icon(Icons.shield_outlined, size: 18), text: l.navAdministrators),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                TrainersPage(),
                // Its own provider instance: this list is pinned to administrators
                // and must not fight with the clients screen over paging or filters.
                _AdministratorsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdministratorsTab extends StatelessWidget {
  const _AdministratorsTab();

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => di.sl<UsersProvider>(),
        child: const UsersPage(role: 'Administrator'),
      );
}
