import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Turns a stable API error code into a sentence in the user's language.
///
/// The API is the contract, so it answers in English with a machine-readable
/// code (`TIME_CONFLICT`, `ORDER_NOT_APPROVED`, …). Only the client knows which
/// language the person in front of it reads, so the translation belongs here —
/// not in the service layer.
///
/// [serverMessage] is the fallback: a code we have not translated yet still
/// shows the server's own sentence rather than a blank or a generic apology.
String apiErrorText(BuildContext context, String? code, [String? serverMessage]) {
  final l = AppLocalizations.of(context);
  switch (code) {
    case 'TIME_CONFLICT':
      return l.errTimeConflict;
    case 'CAPACITY_FULL':
      return l.errCapacityFull;
    case 'DATE_IN_PAST':
      return l.errDateInPast;
    case 'OUTSIDE_AVAILABILITY':
      return l.errOutsideAvailability;
    case 'NO_USABLE_MEMBERSHIP':
      return l.errNoUsableMembership;
    case 'MEMBERSHIP_TYPE_MISMATCH':
      return l.errMembershipMismatch;
    case 'RESERVATION_CLOSED':
      return l.errReservationClosed;
    case 'RESERVATION_CANCELLED':
      return l.errReservationCancelled;
    case 'REASON_REQUIRED':
      return l.errReasonRequired;
    case 'TRAINING_NOT_FOUND':
      return l.errTrainingNotFound;
    case 'INVALID_ADDITIONAL_SERVICE':
      return l.errInvalidService;
    case 'ALREADY_PAID':
      return l.errAlreadyPaid;
    case 'NOTHING_TO_PAY':
      return l.errNothingToPay;
    case 'AWAITING_APPROVAL':
      return l.errAwaitingApproval;
    case 'ORDER_RESERVATION_MISMATCH':
      return l.errOrderMismatch;
    case 'PAYMENT_VERIFICATION_FAILED':
      return l.errVerificationFailed;
    case 'ORDER_NOT_APPROVED':
      return l.errOrderNotApproved;
    case 'ORDER_ALREADY_CAPTURED':
      return l.errOrderAlreadyCaptured;
    case 'INSTRUMENT_DECLINED':
      return l.errInstrumentDeclined;
    case 'PAYER_ACTION_REQUIRED':
      return l.errPayerActionRequired;
    case 'COMPLIANCE_VIOLATION':
      return l.errComplianceViolation;
    case 'PAYEE_ACCOUNT_RESTRICTED':
      return l.errPayeeRestricted;
    case 'CURRENCY_NOT_SUPPORTED':
      return l.errCurrencyNotSupported;
    case 'TRANSACTION_REFUSED':
      return l.errTransactionRefused;
    case 'TRAINING_NOT_ATTENDED':
      return l.errTrainingNotAttended;
    case 'ALREADY_REVIEWED':
      return l.errAlreadyReviewed;
    case 'PACKAGE_INACTIVE':
      return l.errPackageInactive;
    case 'START_IN_PAST':
      return l.errStartInPast;
    case 'INVALID_STATUS_TRANSITION':
      return l.errInvalidStatus;
    case 'AVAILABILITY_OVERLAP':
      return l.errAvailabilityOverlap;

    // Packages
    case 'MEMBERSHIP_OVERLAP':
      return l.errMembershipOverlap;
    case 'MEMBERSHIP_IN_USE':
      return l.errMembershipInUse;
    case 'MEMBERSHIP_CANCELLED':
      return l.errMembershipCancelled;
    case 'ALREADY_CANCELLED':
      return l.errAlreadyCancelled;
    case 'ORDER_MEMBERSHIP_MISMATCH':
      return l.errOrderPackageMismatch;

    // Not business rules — the request never reached the server.
    case 'NETWORK_TIMEOUT':
      return l.errNetworkTimeout;
    case 'NETWORK_UNREACHABLE':
      return l.errNetworkUnreachable;
    case 'INVALID_CREDENTIALS':
      return l.errInvalidCredentials;
    default:
      final fallback = serverMessage?.trim();
      return (fallback == null || fallback.isEmpty) ? l.errUnexpected : fallback;
  }
}
