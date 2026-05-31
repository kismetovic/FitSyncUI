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

  /// Bottom nav: home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// Bottom nav: calendar
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Bottom nav: profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

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

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Value not set placeholder
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Change password label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Help and support label
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Logout label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// Book training page title
  ///
  /// In en, this message translates to:
  /// **'Book Training'**
  String get bookTraining;

  /// Select date section header
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Reservation type section header
  ///
  /// In en, this message translates to:
  /// **'Reservation Type'**
  String get reservationType;

  /// Outside availability toggle label
  ///
  /// In en, this message translates to:
  /// **'Request outside availability'**
  String get requestOutsideAvailability;

  /// Outside availability hint text
  ///
  /// In en, this message translates to:
  /// **'Requires trainer approval. Additional charge may apply.'**
  String get outsideAvailabilityHint;

  /// Additional services section header
  ///
  /// In en, this message translates to:
  /// **'Additional Services'**
  String get additionalServices;

  /// Additional services subtitle
  ///
  /// In en, this message translates to:
  /// **'Enhance your training experience'**
  String get enhanceExperience;

  /// No additional services message
  ///
  /// In en, this message translates to:
  /// **'No additional services available'**
  String get noAdditionalServices;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// One-time reservation type
  ///
  /// In en, this message translates to:
  /// **'One-time Session'**
  String get oneTimeSession;

  /// Monthly reservation type
  ///
  /// In en, this message translates to:
  /// **'Monthly Package'**
  String get monthlyPackage;

  /// One-time session description
  ///
  /// In en, this message translates to:
  /// **'Single training session'**
  String get singleSession;

  /// Monthly package description
  ///
  /// In en, this message translates to:
  /// **'Recurring monthly training'**
  String get recurringMonthly;

  /// Confirm reservation page title
  ///
  /// In en, this message translates to:
  /// **'Confirm Reservation'**
  String get confirmReservation;

  /// Review booking heading
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewBooking;

  /// Confirm details subtitle
  ///
  /// In en, this message translates to:
  /// **'Please confirm the details below'**
  String get confirmDetails;

  /// Pending approval badge
  ///
  /// In en, this message translates to:
  /// **'Pending Trainer Approval'**
  String get pendingTrainerApproval;

  /// Outside hours warning message
  ///
  /// In en, this message translates to:
  /// **'This session is outside regular hours. The trainer must approve it before it is confirmed. An additional charge may apply.'**
  String get outsideHoursWarning;

  /// Date and time label
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Base price label
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// Total price label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Confirm and continue button
  ///
  /// In en, this message translates to:
  /// **'Confirm & Continue'**
  String get confirmAndContinue;

  /// Go back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// My reservations page title
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get myReservations;

  /// No reservations empty state
  ///
  /// In en, this message translates to:
  /// **'No reservations yet'**
  String get noReservations;

  /// Cancel reservation button
  ///
  /// In en, this message translates to:
  /// **'Cancel Reservation'**
  String get cancelReservation;

  /// Cancel reservation confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this reservation?'**
  String get cancelReservationConfirm;

  /// Empty notifications state
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Search trainings placeholder
  ///
  /// In en, this message translates to:
  /// **'Search trainings...'**
  String get searchTrainings;

  /// Recommendations section header
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommended;

  /// All trainings section header
  ///
  /// In en, this message translates to:
  /// **'All Trainings'**
  String get allTrainings;

  /// Time conflict error message
  ///
  /// In en, this message translates to:
  /// **'You already have a reservation at this time. Enable \'outside availability\' to request an exception pending trainer approval.'**
  String get timeConflict;

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

  /// My payments page title
  ///
  /// In en, this message translates to:
  /// **'My Payments'**
  String get myPayments;

  /// Empty payment history message
  ///
  /// In en, this message translates to:
  /// **'No payment history yet'**
  String get noMyPayments;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Training label
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;
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
