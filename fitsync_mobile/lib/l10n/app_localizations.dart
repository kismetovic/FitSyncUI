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

  /// PayPal refusal codes
  ///
  /// In en, this message translates to:
  /// **'PayPal refused this transaction. The payment was not taken. Try another payment method or contact us.'**
  String get errComplianceViolation;

  /// PayPal refusal codes
  ///
  /// In en, this message translates to:
  /// **'The gym PayPal account cannot accept this payment right now.'**
  String get errPayeeRestricted;

  /// PayPal refusal codes
  ///
  /// In en, this message translates to:
  /// **'PayPal does not support this currency for one of the accounts involved.'**
  String get errCurrencyNotSupported;

  /// PayPal refusal codes
  ///
  /// In en, this message translates to:
  /// **'PayPal refused this transaction. The payment was not taken.'**
  String get errTransactionRefused;

  /// Calendar empty state
  ///
  /// In en, this message translates to:
  /// **'No reservations yet.\nTap a day to see details.'**
  String get calendarEmpty;

  /// Pay an unpaid reservation from the bookings list
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed'**
  String get reservationConfirmed;

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'The \"{name}\" session is covered by your monthly package, so there is nothing to pay.\n\nOne session was drawn from the package.'**
  String coveredByPackageBody(String name);

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay'**
  String get nothingToPayTitle;

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'This reservation is fully covered by your monthly package.'**
  String get nothingToPayBody;

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get finish;

  /// Booking covered by a monthly package
  ///
  /// In en, this message translates to:
  /// **'My reservations'**
  String get viewMyReservations;

  /// Package overlap rule
  ///
  /// In en, this message translates to:
  /// **'You already have \"{name}\", which covers the same trainings.'**
  String alreadyCoveredBy(String name);

  /// Package overlap rule
  ///
  /// In en, this message translates to:
  /// **'You already have a package covering the same trainings. Use it up, let it expire or cancel it before buying another.'**
  String get errMembershipOverlap;

  /// Help screen section heading
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// Membership status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Membership status label
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Membership status label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Reservation'**
  String get reservation;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get packageAwaitingPayment;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Pay for package'**
  String get payPackage;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Cancel package'**
  String get cancelPackage;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Cancel this package?'**
  String get cancelPackageConfirm;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'The package was cancelled.'**
  String get packageCancelled;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'The package is paid for and active.'**
  String get packagePaid;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'This package is not paid for yet, so it cannot be used for bookings.'**
  String get packageUnpaidNotice;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get choosePaymentMethod;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Pay with PayPal'**
  String get payWithPayPalShort;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Pay in cash at the desk'**
  String get payWithCashShort;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Noted. The package activates once staff take the payment at the desk.'**
  String get cashSelectedPackage;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get helpContactUs;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'There are no published questions right now.'**
  String get helpNoFaqs;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Help content is unavailable right now.'**
  String get helpLoadFailed;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'A package with sessions already spent cannot be cancelled. Cancel the reservations that used it first.'**
  String get errMembershipInUse;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'A cancelled package cannot be paid for.'**
  String get errMembershipCancelled;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'This package is already cancelled.'**
  String get errAlreadyCancelled;

  /// Package payment, cancellation and help screen
  ///
  /// In en, this message translates to:
  /// **'This PayPal order belongs to a different package.'**
  String get errOrderPackageMismatch;

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

  /// Membership shop title
  ///
  /// In en, this message translates to:
  /// **'Monthly packages'**
  String get monthlyPackages;

  /// Section listing the packages the user owns
  ///
  /// In en, this message translates to:
  /// **'My packages'**
  String get myPackages;

  /// Empty state for owned packages
  ///
  /// In en, this message translates to:
  /// **'You do not own a monthly package yet'**
  String get noPackagesOwned;

  /// Purchase button
  ///
  /// In en, this message translates to:
  /// **'Buy package'**
  String get buyPackage;

  /// Short purchase confirmation button
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Snack bar after a successful purchase
  ///
  /// In en, this message translates to:
  /// **'Package purchased'**
  String get packagePurchased;

  /// Remaining sessions on an owned package
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} sessions left'**
  String sessionsLeft(int remaining, int total);

  /// Expiry date of an owned package
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String validUntil(String date);

  /// Package covers every training type
  ///
  /// In en, this message translates to:
  /// **'All training types'**
  String get allTrainingTypes;

  /// Package is restricted to one training type
  ///
  /// In en, this message translates to:
  /// **'Only {type}'**
  String onlyTrainingType(String type);

  /// Unit price of a package
  ///
  /// In en, this message translates to:
  /// **'{price} per session'**
  String perSession(String price);

  /// How long a package stays valid
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String packageDurationDays(int days);

  /// Purchase confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Buy {name} for {price}?'**
  String confirmPurchase(String name, String price);

  /// Shown when the user picks Monthly without a package
  ///
  /// In en, this message translates to:
  /// **'A monthly booking needs an active package with sessions left.'**
  String get needPackageForMonthly;

  /// Monthly booking is paid from the package
  ///
  /// In en, this message translates to:
  /// **'Covered by your package - no charge'**
  String get coveredByPackage;

  /// Label for the recommendation explanation
  ///
  /// In en, this message translates to:
  /// **'Why this?'**
  String get recommendedBecause;

  /// Loads the next page of older notifications
  ///
  /// In en, this message translates to:
  /// **'Load older'**
  String get loadOlder;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get versionLabel;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'© 2025 FitSync. All rights reserved.'**
  String get allRightsReserved;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Book a training to get started'**
  String get bookTrainingToStart;

  /// Availability legend - the slot has room
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get slotFree;

  /// Availability legend - the slot is nearly full
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get slotLimited;

  /// Availability legend - the slot is booked out
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get slotFull;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveReview;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Share your experience (optional)...'**
  String get shareExperience;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a review!'**
  String get beFirstToReview;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Find your perfect training'**
  String get findYourTraining;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'No trainings found'**
  String get noTrainingsFound;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'No trainings match your filters'**
  String get noTrainingsMatchFilters;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'View Reviews'**
  String get viewReviews;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Reservation #{id}'**
  String reservationLabel(int id);

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'{count} service(s) added'**
  String sessionsAdded(int count);

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'/ session'**
  String get perSessionSuffix;

  /// Added while removing hardcoded UI strings
  ///
  /// In en, this message translates to:
  /// **'Reviews – {training}'**
  String reviewsFor(String training);

  /// Capacity shown on a training card
  ///
  /// In en, this message translates to:
  /// **'{count} spots'**
  String spotsCount(int count);

  /// Calendar screen
  ///
  /// In en, this message translates to:
  /// **'My Calendar'**
  String get myCalendar;

  /// Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Upcoming Reservations'**
  String get upcomingReservations;

  /// Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get legendPending;

  /// Calendar screen
  ///
  /// In en, this message translates to:
  /// **'No reservations on {date}'**
  String noReservationsOn(String date);
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
