import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;

  /// Identity user name. Kept separate from [email]: the seeded administrator is
  /// `superadministrator`, and an update must not silently overwrite it.
  final String userName;

  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role; // "Administrator" or "Client"

  /// Whether the account may sign in. A disabled user is refused a JWT by
  /// AuthService, so this is the admin's switch for locking an account.
  final bool enabled;

  const User({
    required this.id,
    this.userName = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.role,
    this.enabled = true,
  });

  @override
  List<Object?> get props =>
      [id, userName, firstName, lastName, email, phoneNumber, address, role, enabled];
}
