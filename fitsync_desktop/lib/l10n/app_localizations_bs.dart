// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get errMembershipOverlap =>
      'Klijent već ima paket koji pokriva iste treninge.';

  @override
  String get errMembershipInUse =>
      'Paket iz kojeg je već potrošen termin ne može se otkazati.';

  @override
  String get errMembershipCancelled => 'Otkazani paket se ne može platiti.';

  @override
  String get errAlreadyCancelled => 'Ovaj paket je već otkazan.';

  @override
  String get errOrderPackageMismatch =>
      'Ova PayPal narudžba pripada drugom paketu.';

  @override
  String get phone => 'Telefon';

  @override
  String get navMonthlyPackages => 'Mjesečni paketi';

  @override
  String get navReports => 'Izvještaji';

  @override
  String get navStaff => 'Osoblje';

  @override
  String get navAdministrators => 'Administratori';

  @override
  String get navTrainersTab => 'Treneri';

  @override
  String get role => 'Uloga';

  @override
  String get navHelp => 'Pomoć i podrška';

  @override
  String get faqs => 'Česta pitanja';

  @override
  String get addFaq => 'Dodaj pitanje';

  @override
  String get editFaq => 'Izmijeni pitanje';

  @override
  String get deleteFaq => 'Obriši pitanje';

  @override
  String get question => 'Pitanje';

  @override
  String get answer => 'Odgovor';

  @override
  String get sortOrder => 'Redoslijed';

  @override
  String get visible => 'Vidljivo u aplikaciji';

  @override
  String get noFaqs => 'Još nema pitanja';

  @override
  String get supportContact => 'Kontakt podrške';

  @override
  String get supportContactHint =>
      'Ovi podaci se prikazuju klijentima na ekranu „Pomoć i podrška\".';

  @override
  String get workingHours => 'Radno vrijeme';

  @override
  String get address => 'Adresa';

  @override
  String get saved => 'Sačuvano';

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
  String get navDashboard => 'Nadzorna ploča';

  @override
  String get navTrainings => 'Treninzi';

  @override
  String get navReservations => 'Rezervacije';

  @override
  String get navClients => 'Klijenti';

  @override
  String get navReviews => 'Recenzije';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get logout => 'Odjava';

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
  String get reservations => 'Rezervacije';

  @override
  String get searchReservations => 'Pretraži po klijentu ili treningu...';

  @override
  String get client => 'Klijent';

  @override
  String get training => 'Trening';

  @override
  String get date => 'Datum';

  @override
  String get type => 'Vrsta';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Akcije';

  @override
  String get approve => 'Odobri';

  @override
  String get cancel => 'Otkaži';

  @override
  String get delete => 'Obriši';

  @override
  String get deleteReservation => 'Obriši rezervaciju';

  @override
  String get noReservationsFound => 'Nema pronađenih rezervacija';

  @override
  String get refresh => 'Osvježi';

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
  String get trainings => 'Treninzi';

  @override
  String get searchTrainings => 'Pretraži treninge...';

  @override
  String get noTrainingsFound => 'Nema pronađenih treninga';

  @override
  String get addTraining => 'Dodaj trening';

  @override
  String get editTraining => 'Uredi trening';

  @override
  String get deleteTraining => 'Obriši trening';

  @override
  String get users => 'Korisnici';

  @override
  String get searchUsers => 'Pretraži korisnike...';

  @override
  String get noUsersFound => 'Nema pronađenih korisnika';

  @override
  String get sendReminder => 'Pošalji podsjetnik za uplatu';

  @override
  String get deleteUser => 'Obriši korisnika';

  @override
  String get reviews => 'Recenzije';

  @override
  String get noReviewsFound => 'Nema pronađenih recenzija';

  @override
  String get deleteReview => 'Obriši recenziju';

  @override
  String get dashboard => 'Nadzorna ploča';

  @override
  String get totalUsers => 'Ukupno korisnika';

  @override
  String get totalReservations => 'Ukupno rezervacija';

  @override
  String get totalRevenue => 'Ukupan prihod';

  @override
  String get totalTrainings => 'Ukupno treninga';

  @override
  String get navTrainingTypes => 'Vrste treninga';

  @override
  String get navAdditionalServices => 'Dodatne usluge';

  @override
  String get addTrainingType => 'Dodaj vrstu treninga';

  @override
  String get addAdditionalService => 'Dodaj dodatnu uslugu';

  @override
  String get editUser => 'Uredi korisnika';

  @override
  String get navPayments => 'Uplate';

  @override
  String get searchPayments =>
      'Pretraži po klijentu, treningu ili ID-u transakcije...';

  @override
  String get totalTransactions => 'Ukupno transakcija';

  @override
  String get amount => 'Iznos';

  @override
  String get provider => 'Način plaćanja';

  @override
  String get transactionId => 'ID transakcije';

  @override
  String get cash => 'Gotovina';

  @override
  String get noPaymentsFound => 'Nema pronađenih uplata';

  @override
  String get myPayments => 'Moje uplate';

  @override
  String get noMyPayments => 'Još nema historije uplata';

  @override
  String get edit => 'Uredi';

  @override
  String get save => 'Sačuvaj';

  @override
  String get retry => 'Pokušaj ponovo';

  @override
  String get searchReviews => 'Pretraži recenzije...';

  @override
  String deleteConfirmNamed(String name) {
    return 'Obrisati \"$name\"?';
  }
}
