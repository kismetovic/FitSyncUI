import 'package:equatable/equatable.dart';

/// The gym's support details, shown to clients on the mobile help screen.
class SupportContact extends Equatable {
  final String email;
  final String phoneNumber;
  final String workingHours;
  final String? address;

  const SupportContact({
    required this.email,
    required this.phoneNumber,
    required this.workingHours,
    this.address,
  });

  @override
  List<Object?> get props => [email, phoneNumber, workingHours, address];
}
