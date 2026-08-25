import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/membership_package.dart';
import '../../domain/entities/user_membership.dart';
import '../../domain/usecases/get_membership_packages.dart';
import '../../domain/usecases/get_my_memberships.dart';
import '../../domain/usecases/purchase_membership.dart';
import '../../domain/usecases/cancel_membership.dart';
import '../../domain/usecases/create_membership_paypal_order.dart';
import '../../domain/usecases/capture_membership_paypal.dart';
import '../../domain/usecases/select_membership_cash.dart';

class MembershipsProvider extends ChangeNotifier {
  final GetMembershipPackages getMembershipPackages;
  final GetMyMemberships getMyMemberships;
  final PurchaseMembership purchaseMembership;
  final CancelMembership cancelMembership;
  final CreateMembershipPayPalOrder createMembershipPayPalOrder;
  final CaptureMembershipPayPal captureMembershipPayPal;
  final SelectMembershipCash selectMembershipCash;

  MembershipsProvider({
    required this.getMembershipPackages,
    required this.getMyMemberships,
    required this.purchaseMembership,
    required this.cancelMembership,
    required this.createMembershipPayPalOrder,
    required this.captureMembershipPayPal,
    required this.selectMembershipCash,
  });

  List<MembershipPackage> _packages = [];
  List<MembershipPackage> get packages => _packages;

  List<UserMembership> _myMemberships = [];
  List<UserMembership> get myMemberships => _myMemberships;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Set while a purchase is in flight, so a single card can show a spinner
  /// without blanking the whole list.
  int? _purchasingPackageId;
  int? get purchasingPackageId => _purchasingPackageId;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error], so the screen can print it in the
  /// user's language instead of the server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// The packages that can pay for a booking right now, newest first.
  List<UserMembership> get usableMemberships =>
      _myMemberships.where((m) => m.isUsable).toList();

  /// The package that would cover a [trainingTypeId] booking, or null if the
  /// user has none. Mirrors the backend's own resolution order: a package tied
  /// to this training type wins over a general one, so a restricted package is
  /// spent before an unrestricted one.
  UserMembership? usableFor(int trainingTypeId) {
    final candidates =
        usableMemberships.where((m) => m.coversTrainingType(trainingTypeId)).toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final aSpecific = a.trainingTypeId == trainingTypeId ? 0 : 1;
      final bSpecific = b.trainingTypeId == trainingTypeId ? 0 : 1;
      if (aSpecific != bSpecific) return aSpecific.compareTo(bSpecific);
      return a.endDate.compareTo(b.endDate);
    });
    return candidates.first;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final packagesResult = await getMembershipPackages(NoParams());
    packagesResult.fold(
      (f) => _error = f.message,
      (list) => _packages = list.where((p) => p.isActive).toList(),
    );

    final mineResult = await getMyMemberships(NoParams());
    mineResult.fold(
      (f) => _error ??= f.message,
      (list) => _myMemberships = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Loads only the user's own packages. Used by screens that need to know
  /// whether a monthly booking is possible without showing the shop.
  Future<void> loadMine() async {
    final result = await getMyMemberships(NoParams());
    result.fold(
      (f) => _error = f.message,
      (list) => _myMemberships = list,
    );
    notifyListeners();
  }

  /// Returns the bought package on success, null on failure with [error] set.
  Future<UserMembership?> purchase(int packageId) async {
    _purchasingPackageId = packageId;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await purchaseMembership(packageId);
    return result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        _purchasingPackageId = null;
        notifyListeners();
        return null;
      },
      (membership) {
        _myMemberships = [membership, ..._myMemberships];
        _purchasingPackageId = null;
        notifyListeners();
        return membership;
      },
    );
  }

  /// Set while a package is being paid for or cancelled, so one card can show a
  /// spinner without blanking the list.
  int? _busyMembershipId;
  int? get busyMembershipId => _busyMembershipId;

  /// The PayPal approval url for the package currently being paid for, plus the
  /// order id the capture step needs. Held here so the screen can reopen PayPal
  /// and so returning to the app can trigger a check without asking the user.
  String? _pendingApprovalUrl;
  String? get pendingApprovalUrl => _pendingApprovalUrl;

  String? _pendingOrderId;
  int? _pendingMembershipId;
  int? get pendingMembershipId => _pendingMembershipId;

  /// True while the server says the order has not been approved yet. Drives the
  /// 'finish it in PayPal' message rather than an error.
  bool _notApprovedYet = false;
  bool get notApprovedYet => _notApprovedYet;

  bool get hasPendingPayPal => _pendingOrderId != null && _pendingMembershipId != null;

  void clearPendingPayPal() {
    _pendingApprovalUrl = null;
    _pendingOrderId = null;
    _pendingMembershipId = null;
    _notApprovedYet = false;
    notifyListeners();
  }

  Future<bool> cancel(int membershipId) async {
    _busyMembershipId = membershipId;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await cancelMembership(membershipId);
    final ok = result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        return false;
      },
      (updated) {
        _replace(updated);
        return true;
      },
    );

    _busyMembershipId = null;
    notifyListeners();
    return ok;
  }

  /// Opens a PayPal order and returns the url the browser should be sent to.
  Future<String?> startPayPal(int membershipId) async {
    _busyMembershipId = membershipId;
    _error = null;
    _errorCode = null;
    _notApprovedYet = false;
    notifyListeners();

    final result = await createMembershipPayPalOrder(membershipId);
    final url = result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        return null;
      },
      (payload) {
        _pendingOrderId = payload['orderId']?.toString();
        _pendingMembershipId = membershipId;
        _pendingApprovalUrl = payload['approvalUrl']?.toString();
        return _pendingApprovalUrl;
      },
    );

    _busyMembershipId = null;
    notifyListeners();
    return url;
  }

  /// Asks the server to capture and verify the pending order. Retries a few
  /// times because PayPal can take a moment to register an approval - the same
  /// shape the booking payment screen uses. The client never declares success.
  Future<bool> verifyPayPal({int attempts = 5}) async {
    if (!hasPendingPayPal) return false;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      final last = attempt == attempts;
      _busyMembershipId = _pendingMembershipId;
      notifyListeners();

      final result = await captureMembershipPayPal(
        orderId: _pendingOrderId!,
        membershipId: _pendingMembershipId!,
      );

      final done = result.fold(
        (f) {
          _notApprovedYet = f.code == 'ORDER_NOT_APPROVED';
          // Only surface an error on the final try, or when it is a real one.
          if (last || !_notApprovedYet) {
            _error = f.message;
            _errorCode = f.code;
          }
          return false;
        },
        (_) {
          _error = null;
          _errorCode = null;
          _notApprovedYet = false;
          return true;
        },
      );

      _busyMembershipId = null;

      if (done) {
        clearPendingPayPal();
        await loadMine();
        return true;
      }
      if (!_notApprovedYet) break;
      if (!last) await Future<void>.delayed(const Duration(seconds: 3));
    }

    notifyListeners();
    return false;
  }

  /// 'I will pay at the desk'. The package stays unusable until staff confirm.
  Future<bool> payWithCash(int membershipId) async {
    _busyMembershipId = membershipId;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await selectMembershipCash(membershipId);
    final ok = result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        return false;
      },
      (_) => true,
    );

    _busyMembershipId = null;
    notifyListeners();
    return ok;
  }

  void _replace(UserMembership updated) {
    _myMemberships = [
      for (final m in _myMemberships) if (m.id == updated.id) updated else m,
    ];
  }
}
