import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
  });

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await loginUser(LoginParams(username: username, password: password));

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = _mapFailureToMessage(failure);
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

  Future<void> logout() async {
    _user = null;
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
