// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errComplianceViolation =>
      'PayPal refused this transaction. The payment was not taken. Try another payment method or contact us.';

  @override
  String get errPayeeRestricted =>
      'The gym PayPal account cannot accept this payment right now.';

  @override
  String get errCurrencyNotSupported =>
      'PayPal does not support this currency for one of the accounts involved.';

  @override
  String get errTransactionRefused =>
      'PayPal refused this transaction. The payment was not taken.';

  @override
  String get errMembershipOverlap =>
      'The client already has a package covering the same trainings.';

  @override
  String get errMembershipInUse =>
      'A package with sessions already spent cannot be cancelled.';

  @override
  String get errMembershipCancelled =>
      'A cancelled package cannot be paid for.';

  @override
  String get errAlreadyCancelled => 'This package is already cancelled.';

  @override
  String get errOrderPackageMismatch =>
      'This PayPal order belongs to a different package.';

  @override
  String get phone => 'Phone';

  @override
  String get navMonthlyPackages => 'Monthly packages';

  @override
  String get navReports => 'Reports';

  @override
  String get navStaff => 'Staff';

  @override
  String get navAdministrators => 'Administrators';

  @override
  String get navTrainersTab => 'Trainers';

  @override
  String get role => 'Role';

  @override
  String get navHelp => 'Help & support';

  @override
  String get faqs => 'FAQs';

  @override
  String get addFaq => 'Add question';

  @override
  String get editFaq => 'Edit question';

  @override
  String get deleteFaq => 'Delete question';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Answer';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get visible => 'Visible in the app';

  @override
  String get noFaqs => 'No questions yet';

  @override
  String get supportContact => 'Support contact';

  @override
  String get supportContactHint =>
      'These details are shown to clients on the help screen.';

  @override
  String get workingHours => 'Working hours';

  @override
  String get address => 'Address';

  @override
  String get saved => 'Saved';

  @override
  String get errNetworkTimeout =>
      'The server is not responding. Check that it is running and try again.';

  @override
  String get errNetworkUnreachable =>
      'Cannot reach the server. Check your network or that the API is running.';

  @override
  String get errInvalidCredentials => 'Wrong username or password.';

  @override
  String get errTimeConflict =>
      'You already have a reservation at this time. Enable the out-of-hours option to request an exception.';

  @override
  String get errCapacityFull =>
      'This term is full. Please choose another time.';

  @override
  String get errDateInPast =>
      'A reservation cannot be made for a time that has already passed.';

  @override
  String get errOutsideAvailability =>
      'The selected slot is outside the trainer\'s working hours. Enable the out-of-hours option to send a request for approval; an extra fee applies.';

  @override
  String get errNoUsableMembership =>
      'A monthly reservation needs an active package with sessions left that covers this training type.';

  @override
  String get errMembershipMismatch =>
      'The selected package does not cover this training type.';

  @override
  String get errReservationClosed =>
      'A cancelled or completed reservation can no longer be edited.';

  @override
  String get errReservationCancelled =>
      'A cancelled reservation cannot be paid.';

  @override
  String get errReasonRequired => 'A cancellation reason is required.';

  @override
  String get errTrainingNotFound => 'The selected training does not exist.';

  @override
  String get errInvalidService =>
      'One or more selected additional services do not exist.';

  @override
  String get errAlreadyPaid => 'This reservation has already been paid.';

  @override
  String get errNothingToPay =>
      'This reservation has no outstanding amount; it is covered by a monthly package.';

  @override
  String get errAwaitingApproval =>
      'This reservation is still waiting for trainer approval and cannot be paid yet.';

  @override
  String get errOrderMismatch =>
      'This PayPal order belongs to a different reservation.';

  @override
  String get errVerificationFailed =>
      'The payment did not pass verification. Nothing was recorded; please try again or contact us.';

  @override
  String get errOrderNotApproved =>
      'The payment has not been approved on PayPal yet. Finish the approval, then return to the app.';

  @override
  String get errOrderAlreadyCaptured =>
      'This PayPal order has already been captured.';

  @override
  String get errInstrumentDeclined =>
      'PayPal declined the selected payment method. Choose another card or account.';

  @override
  String get errPayerActionRequired =>
      'PayPal requires an extra confirmation. Open PayPal again and finish the payment.';

  @override
  String get errTrainingNotAttended =>
      'You can only review a training you have paid for and attended.';

  @override
  String get errAlreadyReviewed =>
      'You have already reviewed this training session.';

  @override
  String get errPackageInactive =>
      'This membership package is no longer on sale.';

  @override
  String get errStartInPast => 'A membership cannot start in the past.';

  @override
  String get errInvalidStatus =>
      'A reservation in its current status cannot move to the requested status.';

  @override
  String get errAvailabilityOverlap =>
      'This window overlaps an availability slot the trainer already has.';

  @override
  String get errUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get appTitle => 'FITSync';

  @override
  String get loginTitle => 'FITSync Login';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerLink => 'Don\'t have an account? Register';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTrainings => 'Trainings';

  @override
  String get navReservations => 'Reservations';

  @override
  String get navClients => 'Clients';

  @override
  String get navReviews => 'Reviews';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get logout => 'Logout';

  @override
  String get registerTitle => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get required => 'Required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get bosnian => 'Bosanski';

  @override
  String get english => 'English';

  @override
  String get reservations => 'Reservations';

  @override
  String get searchReservations => 'Search by client or training...';

  @override
  String get client => 'Client';

  @override
  String get training => 'Training';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get approve => 'Approve';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteReservation => 'Delete Reservation';

  @override
  String get noReservationsFound => 'No reservations found';

  @override
  String get refresh => 'Refresh';

  @override
  String get statusInitial => 'Initial';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPendingApproval => 'Pending Approval';

  @override
  String get trainings => 'Trainings';

  @override
  String get searchTrainings => 'Search trainings...';

  @override
  String get noTrainingsFound => 'No trainings found';

  @override
  String get addTraining => 'Add Training';

  @override
  String get editTraining => 'Edit Training';

  @override
  String get deleteTraining => 'Delete Training';

  @override
  String get users => 'Users';

  @override
  String get searchUsers => 'Search users...';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get sendReminder => 'Send Payment Reminder';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviewsFound => 'No reviews found';

  @override
  String get deleteReview => 'Delete Review';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get totalReservations => 'Total Reservations';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalTrainings => 'Total Trainings';

  @override
  String get navTrainingTypes => 'Training Types';

  @override
  String get navAdditionalServices => 'Additional Services';

  @override
  String get addTrainingType => 'Add Training Type';

  @override
  String get addAdditionalService => 'Add Additional Service';

  @override
  String get editUser => 'Edit User';

  @override
  String get navPayments => 'Payments';

  @override
  String get searchPayments =>
      'Search by client, training or transaction ID...';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get amount => 'Amount';

  @override
  String get provider => 'Provider';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get cash => 'Cash';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String get myPayments => 'My Payments';

  @override
  String get noMyPayments => 'No payment history yet';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get searchReviews => 'Search reviews...';

  @override
  String deleteConfirmNamed(String name) {
    return 'Delete \"$name\"?';
  }
}
