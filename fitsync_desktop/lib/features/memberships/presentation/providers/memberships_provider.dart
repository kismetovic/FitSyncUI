import 'package:flutter/material.dart';
import '../../domain/entities/membership_package.dart';
import '../../domain/usecases/create_membership_package.dart';
import '../../domain/usecases/delete_membership_package.dart';
import '../../domain/usecases/get_membership_packages.dart';
import '../../domain/usecases/update_membership_package.dart';

class MembershipsProvider extends ChangeNotifier {
  final GetMembershipPackages getMembershipPackages;
  final CreateMembershipPackage createMembershipPackage;
  final UpdateMembershipPackage updateMembershipPackage;
  final DeleteMembershipPackage deleteMembershipPackage;

  MembershipsProvider({
    required this.getMembershipPackages,
    required this.createMembershipPackage,
    required this.updateMembershipPackage,
    required this.deleteMembershipPackage,
  });

  List<MembershipPackage> _packages = [];
  List<MembershipPackage> get packages => _packages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getMembershipPackages();
    result.fold(
      (f) { _error = f.message; _errorCode = f.code; },
      (list) => _packages = list,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add(MembershipPackage package) async {
    final result = await createMembershipPackage(package);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (p) { _packages = [..._packages, p]; _error = null;
    _errorCode = null; notifyListeners(); return true; },
    );
  }

  Future<bool> edit(int id, MembershipPackage package) async {
    final result = await updateMembershipPackage(id, package);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (p) {
        final idx = _packages.indexWhere((e) => e.id == id);
        if (idx != -1) _packages[idx] = p;
        _error = null;
    _errorCode = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteMembershipPackage(id);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _packages.removeWhere((e) => e.id == id); _error = null;
    _errorCode = null; notifyListeners(); return true; },
    );
  }
}
