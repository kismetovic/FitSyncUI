import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthProvider extends ChangeNotifier {
  /// Role name the backend uses for gym staff.
  static const String administratorRole = 'Administrator';

  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
    required this.logoutUser,
  });

  /// The desktop app is the admin console, so it checks the role before opening the
  /// admin shell. The backend enforces this independently; this only stops the UI
  /// offering an interface the user cannot actually use.
  bool get isAdministrator => _user?.role == administratorRole;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await loginUser(LoginParams(username: username, password: password));

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = _mapFailureToMessage(failure);
        _errorCode = failure.code;
        notifyListeners();
        return false;
      },
      (user) {
        _isLoading = false;
        _user = user;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await registerUser(RegisterParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    ));

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = _mapFailureToMessage(failure);
        _errorCode = failure.code;
        notifyListeners();
        return false;
      },
      (user) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) {
        _isLoading = false;
        _user = null;
        notifyListeners();
      },
      (user) {
        _isLoading = false;
        _user = user;
        notifyListeners();
      },
    );
  }

  /// Clears both the in-memory user and the persisted token. Dropping only the
  /// in-memory user left the JWT in secure storage, so the next launch restored the
  /// session and the user appeared to still be signed in.
  Future<void> logout() async {
    await logoutUser(NoParams());
    _user = null;
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else {
      return 'Unexpected error';
    }
  }
}
