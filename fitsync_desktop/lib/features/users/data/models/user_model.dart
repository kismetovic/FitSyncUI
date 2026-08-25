import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.userName,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phoneNumber,
    super.address,
    required super.role,
    super.enabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      userName: json['userName'] ?? '',
      firstName: json['firstName'] ?? json['name'] ?? '',
      lastName: json['lastName'] ?? json['surname'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      role: (json['roles'] != null && (json['roles'] as List).isNotEmpty)
          ? (json['roles'] as List).first.toString()
          : json['role'] ?? "Client",
      // UserResponse.Enabled drives the account-locked badge in the list.
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'enabled': enabled,
    };
  }
}
