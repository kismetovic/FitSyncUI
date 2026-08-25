import '../../../../core/pagination/paged_result.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/update_user.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/delete_user.dart';
import '../../domain/usecases/send_payment_reminder.dart';

class UsersProvider extends ChangeNotifier {
  final GetUsers getUsers;
  final UpdateUser updateUser;
  final CreateUser createUser;
  final DeleteUser deleteUser;
  final SendPaymentReminder sendPaymentReminder;

  UsersProvider({
    required this.getUsers,
    required this.updateUser,
    required this.createUser,
    required this.deleteUser,
    required this.sendPaymentReminder,
  });

  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// Page metadata from the API's PagedResult (review item 22).
  int _page = 1;
  int get page => _page;

  int _pageSize = kDefaultPageSize;
  int get pageSize => _pageSize;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// Held so that paging keeps the active filter.
  String? _query;

  /// Which kind of account this provider instance lists. Set once by the screen:
  /// the clients screen shows only clients, the staff screen only administrators.
  String? _role;
  String? get role => _role;

  /// Called by a screen before its first load to lock the provider to one role.
  void restrictToRole(String? role) => _role = role;

  /// A new search is a new result set, so it starts at page one.
  Future<void> search(String? query) => loadUsers(query ?? '', 1);

  Future<void> loadUsers([String? query, int? page]) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    // A null query on a plain reload means "keep the current filter"; searching
    // goes through search(), which passes the new term explicitly.
    if (query != null) _query = query.isEmpty ? null : query;
    notifyListeners();

    final result = await getUsers(
      searchQuery: _query,
      role: _role,
      page: page ?? _page,
      pageSize: _pageSize,
    );
    result.fold(
      (f) { _error = f.message; _errorCode = f.code; },
      (paged) {
        _users = paged.items;
        _page = paged.page;
        _pageSize = paged.pageSize;
        _totalCount = paged.totalCount;
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> editUser({
    required int id,
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    required String role,
    required bool enabled,
  }) async {
    final result = await updateUser(UpdateUserParams(
      id: id,
      userName: userName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      enabled: enabled,
    ));
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
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
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _users.removeWhere((u) => u.id == id); notifyListeners(); return true; },
    );
  }

  Future<bool> sendReminder(int userId) async {
    final result = await sendPaymentReminder(userId);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) => true,
    );
  }

  /// Creates an account from the admin panel. The API assigns the Identity role
  /// during creation, so a user made here is usable straight away.
  Future<bool> addUser({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    bool enabled = true,
  }) async {
    final result = await createUser(CreateUserParams(
      userName: userName,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
      enabled: enabled,
    ));
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (u) { _users = [u, ..._users]; _error = null;
    _errorCode = null; notifyListeners(); return true; },
    );
  }
}
