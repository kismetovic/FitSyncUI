import '../../domain/entities/support_contact.dart';

class SupportContactModel extends SupportContact {
  const SupportContactModel({
    required super.email,
    required super.phoneNumber,
    required super.workingHours,
    super.address,
  });

  factory SupportContactModel.fromJson(Map<String, dynamic> json) => SupportContactModel(
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        workingHours: json['workingHours']?.toString() ?? '',
        address: json['address']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'phoneNumber': phoneNumber,
        'workingHours': workingHours,
        'address': address,
      };
}
