// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get reservationConfirmed => 'Reservation confirmed';

  @override
  String coveredByPackageBody(String name) {
    return 'The \"$name\" session is covered by your monthly package, so there is nothing to pay.\n\nOne session was drawn from the package.';
  }

  @override
  String get nothingToPayTitle => 'Nothing to pay';

  @override
  String get nothingToPayBody =>
      'This reservation is fully covered by your monthly package.';

  @override
  String get finish => 'Done';

  @override
  String get viewMyReservations => 'My reservations';

  @override
  String alreadyCoveredBy(String name) {
    return 'You already have \"$name\", which covers the same trainings.';
  }

  @override
  String get errMembershipOverlap =>
      'You already have a package covering the same trainings. Use it up, let it expire or cancel it before buying another.';

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get active => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get cash => 'Cash';

  @override
  String get reservation => 'Reservation';

  @override
  String get packageAwaitingPayment => 'Awaiting payment';

  @override
  String get payPackage => 'Pay for package';

  @override
  String get cancelPackage => 'Cancel package';

  @override
  String get cancelPackageConfirm => 'Cancel this package?';

  @override
  String get packageCancelled => 'The package was cancelled.';

  @override
  String get packagePaid => 'The package is paid for and active.';

  @override
  String get packageUnpaidNotice =>
      'This package is not paid for yet, so it cannot be used for bookings.';

  @override
  String get choosePaymentMethod => 'Choose a payment method';

  @override
  String get payWithPayPalShort => 'Pay with PayPal';

  @override
  String get payWithCashShort => 'Pay in cash at the desk';

  @override
  String get cashSelectedPackage =>
      'Noted. The package activates once staff take the payment at the desk.';

  @override
  String get helpContactUs => 'Contact us';

  @override
  String get helpNoFaqs => 'There are no published questions right now.';

  @override
  String get helpLoadFailed => 'Help content is unavailable right now.';

  @override
  String get workingHours => 'Working hours';

  @override
  String get errMembershipInUse =>
      'A package with sessions already spent cannot be cancelled. Cancel the reservations that used it first.';

  @override
  String get errMembershipCancelled =>
      'A cancelled package cannot be paid for.';

  @override
  String get errAlreadyCancelled => 'This package is already cancelled.';

  @override
  String get errOrderPackageMismatch =>
      'This PayPal order belongs to a different package.';

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
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navProfile => 'Profile';

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
  String get profile => 'Profile';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get notSet => 'Not set';

  @override
  String get notifications => 'Notifications';

  @override
  String get changePassword => 'Change Password';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get bookTraining => 'Book Training';

  @override
  String get selectDate => 'Select Date';

  @override
  String get reservationType => 'Reservation Type';

  @override
  String get requestOutsideAvailability => 'Request outside availability';

  @override
  String get outsideAvailabilityHint =>
      'Requires trainer approval. Additional charge may apply.';

  @override
  String get additionalServices => 'Additional Services';

  @override
  String get enhanceExperience => 'Enhance your training experience';

  @override
  String get noAdditionalServices => 'No additional services available';

  @override
  String get continueButton => 'Continue';

  @override
  String get oneTimeSession => 'One-time Session';

  @override
  String get monthlyPackage => 'Monthly Package';

  @override
  String get singleSession => 'Single training session';

  @override
  String get recurringMonthly => 'Recurring monthly training';

  @override
  String get confirmReservation => 'Confirm Reservation';

  @override
  String get reviewBooking => 'Review your booking';

  @override
  String get confirmDetails => 'Please confirm the details below';

  @override
  String get pendingTrainerApproval => 'Pending Trainer Approval';

  @override
  String get outsideHoursWarning =>
      'This session is outside regular hours. The trainer must approve it before it is confirmed. An additional charge may apply.';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get type => 'Type';

  @override
  String get basePrice => 'Base Price';

  @override
  String get total => 'Total';

  @override
  String get confirmAndContinue => 'Confirm & Continue';

  @override
  String get goBack => 'Go Back';

  @override
  String get myReservations => 'My Reservations';

  @override
  String get noReservations => 'No reservations yet';

  @override
  String get cancelReservation => 'Cancel Reservation';

  @override
  String get cancelReservationConfirm =>
      'Are you sure you want to cancel this reservation?';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get retry => 'Retry';

  @override
  String get searchTrainings => 'Search trainings...';

  @override
  String get recommended => 'Recommended for you';

  @override
  String get allTrainings => 'All Trainings';

  @override
  String get timeConflict =>
      'You already have a reservation at this time. Enable \'outside availability\' to request an exception pending trainer approval.';

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
  String get myPayments => 'My Payments';

  @override
  String get noMyPayments => 'No payment history yet';

  @override
  String get cancel => 'Cancel';

  @override
  String get training => 'Training';

  @override
  String get monthlyPackages => 'Monthly packages';

  @override
  String get myPackages => 'My packages';

  @override
  String get noPackagesOwned => 'You do not own a monthly package yet';

  @override
  String get buyPackage => 'Buy package';

  @override
  String get buy => 'Buy';

  @override
  String get packagePurchased => 'Package purchased';

  @override
  String sessionsLeft(int remaining, int total) {
    return '$remaining of $total sessions left';
  }

  @override
  String validUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get allTrainingTypes => 'All training types';

  @override
  String onlyTrainingType(String type) {
    return 'Only $type';
  }

  @override
  String perSession(String price) {
    return '$price per session';
  }

  @override
  String packageDurationDays(int days) {
    return '$days days';
  }

  @override
  String confirmPurchase(String name, String price) {
    return 'Buy $name for $price?';
  }

  @override
  String get needPackageForMonthly =>
      'A monthly booking needs an active package with sessions left.';

  @override
  String get coveredByPackage => 'Covered by your package - no charge';

  @override
  String get recommendedBecause => 'Why this?';

  @override
  String get loadOlder => 'Load older';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get versionLabel => 'Version 1.0.0';

  @override
  String get allRightsReserved => '© 2025 FitSync. All rights reserved.';

  @override
  String get bookTrainingToStart => 'Book a training to get started';

  @override
  String get slotFree => 'Free';

  @override
  String get slotLimited => 'Limited';

  @override
  String get slotFull => 'Full';

  @override
  String get availability => 'Availability';

  @override
  String get leaveReview => 'Leave a review';

  @override
  String get rating => 'Rating';

  @override
  String get shareExperience => 'Share your experience (optional)...';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get beFirstToReview => 'Be the first to leave a review!';

  @override
  String get writeReview => 'Write Review';

  @override
  String get filters => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get sortBy => 'Sort by';

  @override
  String get apply => 'Apply';

  @override
  String get findYourTraining => 'Find your perfect training';

  @override
  String get pick => 'Pick';

  @override
  String get noTrainingsFound => 'No trainings found';

  @override
  String get noTrainingsMatchFilters => 'No trainings match your filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get about => 'About';

  @override
  String get viewReviews => 'View Reviews';

  @override
  String get bookNow => 'Book Now';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get refresh => 'Refresh';

  @override
  String reservationLabel(int id) {
    return 'Reservation #$id';
  }

  @override
  String sessionsAdded(int count) {
    return '$count service(s) added';
  }

  @override
  String get perSessionSuffix => '/ session';

  @override
  String reviewsFor(String training) {
    return 'Reviews – $training';
  }

  @override
  String spotsCount(int count) {
    return '$count spots';
  }

  @override
  String get myCalendar => 'My Calendar';

  @override
  String get upcomingReservations => 'Upcoming Reservations';

  @override
  String get legendPending => 'Pending';

  @override
  String noReservationsOn(String date) {
    return 'No reservations on $date';
  }
}
