import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/presentation/pages/main_shell_page.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<LocaleProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()..checkAuth()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'FITSync',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('bs'),
          ],
          theme: ThemeData(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE8622A),
              secondary: Color(0xFF4A90D9),
              surface: Color(0xFF1E2A3A),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F1923),
            useMaterial3: true,
            textTheme: GoogleFonts.notoSansTextTheme(
              const TextTheme(
                headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E2A3A),
              labelStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F1923),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFE8622A))),
          );
        }

        if (auth.user == null) return const LoginPage();

        // This desktop build is the administration console. A signed-in client has a
        // valid account but no business here, so the admin shell is not shown at all.
        // The API enforces the same rule on every endpoint; this is the UI half of it.
        if (!auth.isAdministrator) return const _NotAuthorizedPage();

        return const MainShellPage();
      },
    );
  }
}

/// Shown when a non-administrator signs in to the desktop app.
class _NotAuthorizedPage extends StatelessWidget {
  const _NotAuthorizedPage();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFE8622A), size: 72),
                const SizedBox(height: 24),
                const Text(
                  'Pristup nije dozvoljen',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Desktop aplikacija je namijenjena administratorima teretane. '
                  'Vaš nalog nema administratorsku rolu.\n\n'
                  'Za rezervacije i plaćanja koristite FitSync mobilnu aplikaciju.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], height: 1.5),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Odjavi se'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
