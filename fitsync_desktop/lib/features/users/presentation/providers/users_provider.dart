import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/update_user.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/send_payment_reminder.dart';

class UsersProvider extends ChangeNotifier {
  final GetUsers getUsers;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;
  final SendPaymentReminder sendPaymentReminder;

  UsersProvider({
    required this.getUsers,
    required this.updateUser,
    required this.deleteUser,
    required this.sendPaymentReminder,
  });

  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadUsers([String? query]) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await getUsers(query);
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _users = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<bool> editUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String role,
  }) async {
    final result = await updateUser(UpdateUserParams(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
    ));
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (u) {
        final idx = _users.indexWhere((e) => e.id == id);
        if (idx != -1) _users[idx] = u;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteUser(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _users.removeWhere((u) => u.id == id); notifyListeners(); return true; },
    );
  }

  Future<bool> sendReminder(int userId) async {
    final result = await sendPaymentReminder(userId);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) => true,
    );
  }
}
