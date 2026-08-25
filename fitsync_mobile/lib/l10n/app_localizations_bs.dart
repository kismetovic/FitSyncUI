// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get errComplianceViolation =>
      'PayPal je odbio ovu transakciju. Uplata nije naplaćena. Pokušajte drugim načinom plaćanja ili nas kontaktirajte.';

  @override
  String get errPayeeRestricted =>
      'PayPal nalog teretane trenutno ne može primiti ovu uplatu.';

  @override
  String get errCurrencyNotSupported =>
      'PayPal ne podržava ovu valutu za jedan od uključenih naloga.';

  @override
  String get errTransactionRefused =>
      'PayPal je odbio ovu transakciju. Uplata nije naplaćena.';

  @override
  String get calendarEmpty =>
      'Još nemate rezervacija.\nDodirnite dan da vidite detalje.';

  @override
  String get payNow => 'Plati';

  @override
  String get reservationConfirmed => 'Rezervacija potvrđena';

  @override
  String coveredByPackageBody(String name) {
    return 'Trening „$name\" je pokriven vašim mjesečnim paketom, pa nema šta da se plati.\n\nPotrošen je jedan termin iz paketa.';
  }

  @override
  String get nothingToPayTitle => 'Nema šta da se plati';

  @override
  String get nothingToPayBody =>
      'Ova rezervacija je u cijelosti pokrivena vašim mjesečnim paketom.';

  @override
  String get finish => 'Završi';

  @override
  String get viewMyReservations => 'Moje rezervacije';

  @override
  String alreadyCoveredBy(String name) {
    return 'Već imate paket „$name\" koji pokriva iste treninge.';
  }

  @override
  String get errMembershipOverlap =>
      'Već imate paket koji pokriva iste treninge. Iskoristite ga, sačekajte da istekne ili ga otkažite prije kupovine novog.';

  @override
  String get faqTitle => 'Česta pitanja';

  @override
  String get active => 'Aktivan';

  @override
  String get expired => 'Istekao';

  @override
  String get cancelled => 'Otkazan';

  @override
  String get cash => 'Gotovina';

  @override
  String get reservation => 'Rezervacija';

  @override
  String get packageAwaitingPayment => 'Čeka uplatu';

  @override
  String get payPackage => 'Plati paket';

  @override
  String get cancelPackage => 'Otkaži paket';

  @override
  String get cancelPackageConfirm => 'Otkazati ovaj paket?';

  @override
  String get packageCancelled => 'Paket je otkazan.';

  @override
  String get packagePaid => 'Paket je plaćen i aktiviran.';

  @override
  String get packageUnpaidNotice =>
      'Paket još nije plaćen, pa se ne može koristiti za rezervacije.';

  @override
  String get choosePaymentMethod => 'Odaberite način plaćanja';

  @override
  String get payWithPayPalShort => 'Plati putem PayPal-a';

  @override
  String get payWithCashShort => 'Plati gotovinom na recepciji';

  @override
  String get cashSelectedPackage =>
      'Zabilježeno. Paket se aktivira kada osoblje naplati iznos na recepciji.';

  @override
  String get helpContactUs => 'Kontaktirajte nas';

  @override
  String get helpNoFaqs => 'Trenutno nema objavljenih pitanja.';

  @override
  String get helpLoadFailed => 'Sadržaj pomoći trenutno nije dostupan.';

  @override
  String get workingHours => 'Radno vrijeme';

  @override
  String get errMembershipInUse =>
      'Paket iz kojeg je već potrošen termin ne može se otkazati. Prvo otkažite rezervacije koje su ga koristile.';

  @override
  String get errMembershipCancelled => 'Otkazani paket se ne može platiti.';

  @override
  String get errAlreadyCancelled => 'Ovaj paket je već otkazan.';

  @override
  String get errOrderPackageMismatch =>
      'Ova PayPal narudžba pripada drugom paketu.';

  @override
  String get errNetworkTimeout =>
      'Server ne odgovara. Provjerite da li je pokrenut i pokušajte ponovo.';

  @override
  String get errNetworkUnreachable =>
      'Nije moguće doći do servera. Provjerite mrežu ili da li API radi.';

  @override
  String get errInvalidCredentials => 'Pogrešno korisničko ime ili lozinka.';

  @override
  String get errTimeConflict =>
      'Već imate rezervaciju u ovo vrijeme. Uključite „van rasporeda\" da zatražite izuzetak koji čeka odobrenje trenera.';

  @override
  String get errCapacityFull =>
      'Ovaj termin je popunjen. Molimo odaberite drugo vrijeme.';

  @override
  String get errDateInPast =>
      'Rezervacija se ne može napraviti za vrijeme koje je već prošlo.';

  @override
  String get errOutsideAvailability =>
      'Odabrani termin je izvan radnog vremena trenera. Uključite „van rasporeda\" da pošaljete zahtjev na odobrenje; naplaćuje se doplata.';

  @override
  String get errNoUsableMembership =>
      'Za mjesečnu rezervaciju treba aktivan paket sa preostalim terminima koji pokriva ovaj tip treninga.';

  @override
  String get errMembershipMismatch =>
      'Odabrani paket ne pokriva ovaj tip treninga.';

  @override
  String get errReservationClosed =>
      'Otkazana ili završena rezervacija se više ne može mijenjati.';

  @override
  String get errReservationCancelled =>
      'Otkazana rezervacija se ne može platiti.';

  @override
  String get errReasonRequired => 'Razlog otkazivanja je obavezan.';

  @override
  String get errTrainingNotFound => 'Odabrani trening ne postoji.';

  @override
  String get errInvalidService =>
      'Jedna ili više odabranih dodatnih usluga ne postoji.';

  @override
  String get errAlreadyPaid => 'Ova rezervacija je već plaćena.';

  @override
  String get errNothingToPay =>
      'Ova rezervacija nema iznos za naplatu — pokrivena je mjesečnim paketom.';

  @override
  String get errAwaitingApproval =>
      'Rezervacija još čeka odobrenje trenera i ne može se platiti.';

  @override
  String get errOrderMismatch =>
      'Ova PayPal narudžba pripada drugoj rezervaciji.';

  @override
  String get errVerificationFailed =>
      'Uplata nije prošla provjeru. Nijedan iznos nije evidentiran — pokušajte ponovo ili nas kontaktirajte.';

  @override
  String get errOrderNotApproved =>
      'Plaćanje još nije odobreno na PayPal-u. Dovršite odobrenje pa se vratite u aplikaciju.';

  @override
  String get errOrderAlreadyCaptured => 'Ova PayPal narudžba je već naplaćena.';

  @override
  String get errInstrumentDeclined =>
      'PayPal je odbio odabrani način plaćanja. Odaberite drugu karticu ili račun.';

  @override
  String get errPayerActionRequired =>
      'PayPal traži dodatnu potvrdu. Otvorite PayPal ponovo i dovršite plaćanje.';

  @override
  String get errTrainingNotAttended =>
      'Recenziju možete ostaviti samo za trening koji ste platili i odradili.';

  @override
  String get errAlreadyReviewed =>
      'Već ste ostavili recenziju za ovaj trening.';

  @override
  String get errPackageInactive => 'Ovaj paket više nije u prodaji.';

  @override
  String get errStartInPast => 'Članarina ne može početi u prošlosti.';

  @override
  String get errInvalidStatus =>
      'Rezervacija u trenutnom statusu ne može preći u traženi status.';

  @override
  String get errAvailabilityOverlap =>
      'Ovaj termin se preklapa sa postojećom dostupnošću trenera.';

  @override
  String get errUnexpected =>
      'Došlo je do neočekivane greške. Pokušajte ponovo.';

  @override
  String get appTitle => 'FITSync';

  @override
  String get loginTitle => 'FITSync Prijava';

  @override
  String get welcomeBack => 'Dobrodošli';

  @override
  String get username => 'Korisničko ime';

  @override
  String get password => 'Lozinka';

  @override
  String get loginButton => 'Prijavi se';

  @override
  String get registerLink => 'Nemate nalog? Registrujte se';

  @override
  String get pleaseEnterUsername => 'Unesite korisničko ime';

  @override
  String get pleaseEnterPassword => 'Unesite lozinku';

  @override
  String get navHome => 'Početna';

  @override
  String get navBookings => 'Rezervacije';

  @override
  String get navCalendar => 'Kalendar';

  @override
  String get navProfile => 'Profil';

  @override
  String get registerTitle => 'Registracija';

  @override
  String get createAccount => 'Kreiraj nalog';

  @override
  String get firstName => 'Ime';

  @override
  String get lastName => 'Prezime';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Broj telefona';

  @override
  String get confirmPassword => 'Potvrdi lozinku';

  @override
  String get required => 'Obavezno';

  @override
  String get passwordsDoNotMatch => 'Lozinke se ne poklapaju';

  @override
  String get language => 'Jezik';

  @override
  String get selectLanguage => 'Odaberi jezik';

  @override
  String get bosnian => 'Bosanski';

  @override
  String get english => 'English';

  @override
  String get profile => 'Profil';

  @override
  String get phone => 'Telefon';

  @override
  String get address => 'Adresa';

  @override
  String get notSet => 'Nije postavljeno';

  @override
  String get notifications => 'Notifikacije';

  @override
  String get changePassword => 'Promijeni lozinku';

  @override
  String get helpAndSupport => 'Pomoć i podrška';

  @override
  String get logout => 'Odjava';

  @override
  String get logoutConfirm => 'Jeste li sigurni da se želite odjaviti?';

  @override
  String get bookTraining => 'Zakaži trening';

  @override
  String get selectDate => 'Odaberi datum';

  @override
  String get reservationType => 'Vrsta rezervacije';

  @override
  String get requestOutsideAvailability => 'Zatraži van rasporeda';

  @override
  String get outsideAvailabilityHint =>
      'Zahtijeva odobrenje trenera. Može biti naplaćena dodatna naknada.';

  @override
  String get additionalServices => 'Dodatne usluge';

  @override
  String get enhanceExperience => 'Unaprijedi svoje iskustvo treninga';

  @override
  String get noAdditionalServices => 'Nema dostupnih dodatnih usluga';

  @override
  String get continueButton => 'Nastavi';

  @override
  String get oneTimeSession => 'Jednokratna sesija';

  @override
  String get monthlyPackage => 'Mjesečni paket';

  @override
  String get singleSession => 'Jedna trening sesija';

  @override
  String get recurringMonthly => 'Ponavljajući mjesečni trening';

  @override
  String get confirmReservation => 'Potvrdi rezervaciju';

  @override
  String get reviewBooking => 'Pregled rezervacije';

  @override
  String get confirmDetails => 'Molimo potvrdite detalje ispod';

  @override
  String get pendingTrainerApproval => 'Čeka odobrenje trenera';

  @override
  String get outsideHoursWarning =>
      'Ova sesija je van redovnih sati. Trener mora odobriti prije potvrde. Može se naplatiti dodatna naknada.';

  @override
  String get dateAndTime => 'Datum i vrijeme';

  @override
  String get type => 'Vrsta';

  @override
  String get basePrice => 'Osnovna cijena';

  @override
  String get total => 'Ukupno';

  @override
  String get confirmAndContinue => 'Potvrdi i nastavi';

  @override
  String get goBack => 'Nazad';

  @override
  String get myReservations => 'Moje rezervacije';

  @override
  String get noReservations => 'Nema rezervacija';

  @override
  String get cancelReservation => 'Otkaži rezervaciju';

  @override
  String get cancelReservationConfirm =>
      'Jeste li sigurni da želite otkazati ovu rezervaciju?';

  @override
  String get noNotificationsYet => 'Nema notifikacija';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get searchTrainings => 'Pretraži treninge...';

  @override
  String get recommended => 'Preporučeno za tebe';

  @override
  String get allTrainings => 'Svi treninzi';

  @override
  String get timeConflict =>
      'Već imate rezervaciju u ovo vrijeme. Uključite \'van rasporeda\' da zatražite izuzetak koji čeka odobrenje trenera.';

  @override
  String get statusInitial => 'Inicijalno';

  @override
  String get statusApproved => 'Odobreno';

  @override
  String get statusPaid => 'Plaćeno';

  @override
  String get statusCancelled => 'Otkazano';

  @override
  String get statusCompleted => 'Završeno';

  @override
  String get statusPendingApproval => 'Čeka odobrenje';

  @override
  String get myPayments => 'Moje uplate';

  @override
  String get noMyPayments => 'Još nema historije uplata';

  @override
  String get cancel => 'Otkaži';

  @override
  String get training => 'Trening';

  @override
  String get monthlyPackages => 'Mjesečni paketi';

  @override
  String get myPackages => 'Moji paketi';

  @override
  String get noPackagesOwned => 'Još nemate mjesečni paket';

  @override
  String get buyPackage => 'Kupi paket';

  @override
  String get buy => 'Kupi';

  @override
  String get packagePurchased => 'Paket je kupljen';

  @override
  String sessionsLeft(int remaining, int total) {
    return 'Preostalo $remaining od $total termina';
  }

  @override
  String validUntil(String date) {
    return 'Važi do $date';
  }

  @override
  String get allTrainingTypes => 'Svi tipovi treninga';

  @override
  String onlyTrainingType(String type) {
    return 'Samo $type';
  }

  @override
  String perSession(String price) {
    return '$price po terminu';
  }

  @override
  String packageDurationDays(int days) {
    return '$days dana';
  }

  @override
  String confirmPurchase(String name, String price) {
    return 'Kupiti $name za $price?';
  }

  @override
  String get needPackageForMonthly =>
      'Za mjesečnu rezervaciju treba aktivan paket sa preostalim terminima.';

  @override
  String get coveredByPackage => 'Plaćeno iz vašeg paketa - bez naplate';

  @override
  String get recommendedBecause => 'Zašto ovo?';

  @override
  String get loadOlder => 'Učitaj starije';

  @override
  String get passwordChangedSuccess => 'Lozinka je uspješno promijenjena';

  @override
  String get updatePassword => 'Sačuvaj lozinku';

  @override
  String get contactSupport => 'Kontaktirajte podršku';

  @override
  String get versionLabel => 'Verzija 1.0.0';

  @override
  String get allRightsReserved => '© 2025 FitSync. Sva prava zadržana.';

  @override
  String get bookTrainingToStart => 'Zakažite trening da započnete';

  @override
  String get slotFree => 'Slobodno';

  @override
  String get slotLimited => 'Ograničeno';

  @override
  String get slotFull => 'Popunjeno';

  @override
  String get availability => 'Dostupnost';

  @override
  String get leaveReview => 'Ostavi recenziju';

  @override
  String get rating => 'Ocjena';

  @override
  String get shareExperience => 'Podijelite svoje iskustvo (opcionalno)...';

  @override
  String get submitReview => 'Pošalji recenziju';

  @override
  String get noReviewsYet => 'Još nema recenzija';

  @override
  String get beFirstToReview => 'Budite prvi koji će ostaviti recenziju!';

  @override
  String get writeReview => 'Napiši recenziju';

  @override
  String get filters => 'Filteri';

  @override
  String get clearAll => 'Očisti sve';

  @override
  String get difficulty => 'Težina';

  @override
  String get sortBy => 'Sortiraj po';

  @override
  String get apply => 'Primijeni';

  @override
  String get findYourTraining => 'Pronađite svoj savršen trening';

  @override
  String get pick => 'Izbor';

  @override
  String get noTrainingsFound => 'Nema pronađenih treninga';

  @override
  String get noTrainingsMatchFilters => 'Nijedan trening ne odgovara filterima';

  @override
  String get clearFilters => 'Očisti filtere';

  @override
  String get about => 'O treningu';

  @override
  String get viewReviews => 'Pogledaj recenzije';

  @override
  String get bookNow => 'Rezerviši odmah';

  @override
  String get markAllRead => 'Označi sve';

  @override
  String get refresh => 'Osvježi';

  @override
  String reservationLabel(int id) {
    return 'Rezervacija #$id';
  }

  @override
  String sessionsAdded(int count) {
    return 'Dodano usluga: $count';
  }

  @override
  String get perSessionSuffix => '/ termin';

  @override
  String reviewsFor(String training) {
    return 'Recenzije – $training';
  }

  @override
  String spotsCount(int count) {
    return '$count mjesta';
  }

  @override
  String get myCalendar => 'Moj kalendar';

  @override
  String get upcomingReservations => 'Nadolazeće rezervacije';

  @override
  String get legendPending => 'Na čekanju';

  @override
  String noReservationsOn(String date) {
    return 'Nema rezervacija za $date';
  }
}
