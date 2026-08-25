import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/presentation/pages/main_nav_page.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/trainings/presentation/providers/trainings_provider.dart';
import 'features/trainings/presentation/providers/recommendations_provider.dart';
import 'features/reservations/presentation/providers/reservations_provider.dart';
import 'features/reviews/presentation/providers/reviews_provider.dart';
import 'features/additional_services/presentation/providers/additional_services_provider.dart';
import 'features/memberships/presentation/providers/memberships_provider.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/payments/presentation/providers/payments_provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // DateFormat throws for a locale whose symbols were never loaded, and the app
  // formats dates in whichever language the user picked.
  await initializeDateFormatting('bs');
  await initializeDateFormatting('en');
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
        ChangeNotifierProvider(create: (_) => di.sl<TrainingsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<RecommendationsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReservationsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReviewsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdditionalServicesProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<MembershipsProvider>()),
        // Registered as a singleton in GetIt because it owns the single SignalR
        // connection, so it is provided by value: Provider must not dispose it.
        ChangeNotifierProvider.value(value: di.sl<NotificationsProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PaymentsProvider>()),
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
              const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF152030),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E2A3A),
              labelStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _notificationsRunning = false;

  /// The SignalR connection is tied to the session: it opens once the user is
  /// authenticated and is torn down on logout, so one user never receives another
  /// user's pushes.
  void _syncNotificationStream(AuthProvider auth) {
    final notifications = context.read<NotificationsProvider>();
    final signedIn = auth.user != null;

    if (signedIn && !_notificationsRunning) {
      _notificationsRunning = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifications.start());
    } else if (!signedIn && _notificationsRunning) {
      _notificationsRunning = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifications.stop());
    }
  }

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

        _syncNotificationStream(auth);

        if (auth.user != null) return const MainNavPage();
        return const LoginPage();
      },
    );
  }
}
