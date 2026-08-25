import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_mobile/core/error/api_error_messages.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';

/// Pumps a throwaway widget just to obtain a BuildContext bound to [locale],
/// then reads the message for [code].
Future<String> _messageFor(
  WidgetTester tester,
  String? code, {
  String? serverMessage,
  Locale locale = const Locale('bs'),
}) async {
  late String result;
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) {
      result = apiErrorText(context, code, serverMessage);
      return const SizedBox();
    }),
  ));
  return result;
}

void main() {
  testWidgets('a known code is answered in the active language', (tester) async {
    expect(await _messageFor(tester, 'DATE_IN_PAST'),
        'Rezervacija se ne može napraviti za vrijeme koje je već prošlo.');

    expect(await _messageFor(tester, 'DATE_IN_PAST', locale: const Locale('en')),
        'A reservation cannot be made for a time that has already passed.');
  });

  testWidgets('the server sentence is ignored when the code is known',
      (tester) async {
    // This is the point of the whole layer: the API answers in English and the
    // user still reads Bosnian.
    final message = await _messageFor(tester, 'CAPACITY_FULL',
        serverMessage: 'This term is full (8/8 places taken).');

    expect(message, 'Ovaj termin je popunjen. Molimo odaberite drugo vrijeme.');
  });

  testWidgets('an unknown code falls back to the server sentence',
      (tester) async {
    // A rule added later must degrade to English, not to a blank box.
    expect(
      await _messageFor(tester, 'SOME_FUTURE_RULE',
          serverMessage: 'Something specific the server wants to say.'),
      'Something specific the server wants to say.',
    );
  });

  testWidgets('no code and no message still says something', (tester) async {
    expect(await _messageFor(tester, null),
        'Došlo je do neočekivane greške. Pokušajte ponovo.');
    expect(await _messageFor(tester, null, serverMessage: '   '),
        'Došlo je do neočekivane greške. Pokušajte ponovo.');
  });

  testWidgets('network failures are translated too', (tester) async {
    expect(await _messageFor(tester, 'NETWORK_UNREACHABLE'),
        'Nije moguće doći do servera. Provjerite mrežu ili da li API radi.');
  });
}
