import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role; // "Administrator" or "Client"

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.role,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, phoneNumber, address, role];
}
