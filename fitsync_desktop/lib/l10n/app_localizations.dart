import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bs'),
    Locale('en'),
  ];

  /// Package business rules
  ///
  /// In en, this message translates to:
  /// **'The client already has a package covering the same trainings.'**
  String get errMembershipOverlap;

  /// Package business rules
  ///
  /// In en, this message translates to:
  /// **'A package with sessions already spent cannot be cancelled.'**
  String get errMembershipInUse;

  /// Package business rules
  ///
  /// In en, this message translates to:
  /// **'A cancelled package cannot be paid for.'**
  String get errMembershipCancelled;

  /// Package business rules
  ///
  /// In en, this message translates to:
  /// **'This package is already cancelled.'**
  String get errAlreadyCancelled;

  /// Package business rules
  ///
  /// In en, this message translates to:
  /// **'This PayPal order belongs to a different package.'**
  String get errOrderPackageMismatch;

  /// Contact field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Desktop navigation label
  ///
  /// In en, this message translates to:
  /// **'Monthly packages'**
  String get navMonthlyPackages;

  /// Desktop navigation label
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navStaff;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Administrators'**
  String get navAdministrators;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Trainers'**
  String get navTrainersTab;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get navHelp;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addFaq;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Edit question'**
  String get editFaq;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Delete question'**
  String get deleteFaq;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Visible in the app'**
  String get visible;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get noFaqs;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Support contact'**
  String get supportContact;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'These details are shown to clients on the help screen.'**
  String get supportContactHint;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Desktop admin: staff/clients split and help content management
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// API/network error, keyed by the error code
  ///
  /// In en, this message translates to:
  /// **'The server is not responding. Check that it is running and try again.'**
  String get errNetworkTimeout;

  /// API/network error, keyed by the error code
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your network or that the API is running.'**
  String get errNetworkUnreachable;

  /// API/network error, keyed by the error code
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get errInvalidCredentials;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'You already have a reservation at this time. Enable the out-of-hours option to request an exception.'**
  String get errTimeConflict;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This term is full. Please choose another time.'**
  String get errCapacityFull;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A reservation cannot be made for a time that has already passed.'**
  String get errDateInPast;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'The selected slot is outside the trainer\'s working hours. Enable the out-of-hours option to send a request for approval; an extra fee applies.'**
  String get errOutsideAvailability;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A monthly reservation needs an active package with sessions left that covers this training type.'**
  String get errNoUsableMembership;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'The selected package does not cover this training type.'**
  String get errMembershipMismatch;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A cancelled or completed reservation can no longer be edited.'**
  String get errReservationClosed;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A cancelled reservation cannot be paid.'**
  String get errReservationCancelled;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A cancellation reason is required.'**
  String get errReasonRequired;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'The selected training does not exist.'**
  String get errTrainingNotFound;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'One or more selected additional services do not exist.'**
  String get errInvalidService;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This reservation has already been paid.'**
  String get errAlreadyPaid;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This reservation has no outstanding amount; it is covered by a monthly package.'**
  String get errNothingToPay;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This reservation is still waiting for trainer approval and cannot be paid yet.'**
  String get errAwaitingApproval;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This PayPal order belongs to a different reservation.'**
  String get errOrderMismatch;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'The payment did not pass verification. Nothing was recorded; please try again or contact us.'**
  String get errVerificationFailed;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'The payment has not been approved on PayPal yet. Finish the approval, then return to the app.'**
  String get errOrderNotApproved;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This PayPal order has already been captured.'**
  String get errOrderAlreadyCaptured;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'PayPal declined the selected payment method. Choose another card or account.'**
  String get errInstrumentDeclined;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'PayPal requires an extra confirmation. Open PayPal again and finish the payment.'**
  String get errPayerActionRequired;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'You can only review a training you have paid for and attended.'**
  String get errTrainingNotAttended;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this training session.'**
  String get errAlreadyReviewed;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This membership package is no longer on sale.'**
  String get errPackageInactive;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A membership cannot start in the past.'**
  String get errStartInPast;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'A reservation in its current status cannot move to the requested status.'**
  String get errInvalidStatus;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'This window overlaps an availability slot the trainer already has.'**
  String get errAvailabilityOverlap;

  /// API business-rule error, keyed by the server error code
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errUnexpected;

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'FITSync'**
  String get appTitle;

  /// Login page app bar title
  ///
  /// In en, this message translates to:
  /// **'FITSync Login'**
  String get loginTitle;

  /// Welcome heading on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Link to registration page
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get registerLink;

  /// Username validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// Sidebar nav: dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Sidebar nav: trainings
  ///
  /// In en, this message translates to:
  /// **'Trainings'**
  String get navTrainings;

  /// Sidebar nav: reservations
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get navReservations;

  /// Sidebar nav: clients
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// Sidebar nav: reviews
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get navReviews;

  /// Admin panel subtitle in sidebar
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// Logout button tooltip
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Register page app bar title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// Create account heading
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Password mismatch validation
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Bosnian language option
  ///
  /// In en, this message translates to:
  /// **'Bosanski'**
  String get bosnian;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Reservations page title
  ///
  /// In en, this message translates to:
  /// **'Reservations'**
  String get reservations;

  /// Search reservations placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by client or training...'**
  String get searchReservations;

  /// Client column header
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// Training column header
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// Date column header
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Type column header
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Status column header
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Actions column header
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Approve action
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete reservation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Reservation'**
  String get deleteReservation;

  /// Empty state for reservations
  ///
  /// In en, this message translates to:
  /// **'No reservations found'**
  String get noReservationsFound;

  /// Refresh tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @statusInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial'**
  String get statusInitial;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPendingApproval;

  /// No description provided for @trainings.
  ///
  /// In en, this message translates to:
  /// **'Trainings'**
  String get trainings;

  /// No description provided for @searchTrainings.
  ///
  /// In en, this message translates to:
  /// **'Search trainings...'**
  String get searchTrainings;

  /// No description provided for @noTrainingsFound.
  ///
  /// In en, this message translates to:
  /// **'No trainings found'**
  String get noTrainingsFound;

  /// No description provided for @addTraining.
  ///
  /// In en, this message translates to:
  /// **'Add Training'**
  String get addTraining;

  /// No description provided for @editTraining.
  ///
  /// In en, this message translates to:
  /// **'Edit Training'**
  String get editTraining;

  /// No description provided for @deleteTraining.
  ///
  /// In en, this message translates to:
  /// **'Delete Training'**
  String get deleteTraining;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @sendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send Payment Reminder'**
  String get sendReminder;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviewsFound.
  ///
  /// In en, this message translates to:
  /// **'No reviews found'**
  String get noReviewsFound;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalReservations.
  ///
  /// In en, this message translates to:
  /// **'Total Reservations'**
  String get totalReservations;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalTrainings.
  ///
  /// In en, this message translates to:
  /// **'Total Trainings'**
  String get totalTrainings;

  /// No description provided for @navTrainingTypes.
  ///
  /// In en, this message translates to:
  /// **'Training Types'**
  String get navTrainingTypes;

  /// No description provided for @navAdditionalServices.
  ///
  /// In en, this message translates to:
  /// **'Additional Services'**
  String get navAdditionalServices;

  /// No description provided for @addTrainingType.
  ///
  /// In en, this message translates to:
  /// **'Add Training Type'**
  String get addTrainingType;

  /// No description provided for @addAdditionalService.
  ///
  /// In en, this message translates to:
  /// **'Add Additional Service'**
  String get addAdditionalService;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @searchPayments.
  ///
  /// In en, this message translates to:
  /// **'Search by client, training or transaction ID...'**
  String get searchPayments;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @noPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// No description provided for @myPayments.
  ///
  /// In en, this message translates to:
  /// **'My Payments'**
  String get myPayments;

  /// No description provided for @noMyPayments.
  ///
  /// In en, this message translates to:
  /// **'No payment history yet'**
  String get noMyPayments;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Search reviews...'**
  String get searchReviews;

  /// Delete confirmation for a named record
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteConfirmNamed(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
