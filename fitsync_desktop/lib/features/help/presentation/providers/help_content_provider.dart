import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/help_remote_data_source.dart';
import '../../data/models/faq_model.dart';
import '../../data/models/support_contact_model.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_contact.dart';

/// Help content the administrator owns: the FAQ list and the gym's support
/// details. Both used to be constants inside the mobile app's source, so the only
/// way to correct a wrong phone number was to ship a new build.
class HelpContentProvider extends ChangeNotifier {
  final HelpRemoteDataSource dataSource;

  HelpContentProvider({required this.dataSource});

  List<Faq> _faqs = const [];
  List<Faq> get faqs => _faqs;

  SupportContact? _contact;
  SupportContact? get contact => _contact;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error], so the screen can print the rule in the
  /// user's language rather than the server's English sentence.
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

    try {
      // Both halves of the screen, in parallel: neither depends on the other.
      final results = await Future.wait([
        dataSource.getFaqs(),
        dataSource.getContact(),
      ]);
      _faqs = results[0] as List<Faq>;
      _contact = results[1] as SupportContact;
    } on Failure catch (f) {
      _error = f.message;
      _errorCode = f.code;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveFaq({
    int? id,
    required String question,
    required String answer,
    required int sortOrder,
    required bool isActive,
  }) =>
      _mutate(() async {
        final model = FaqModel(
          id: id ?? 0,
          question: question,
          answer: answer,
          sortOrder: sortOrder,
          isActive: isActive,
        );
        if (id == null) {
          await dataSource.createFaq(model);
        } else {
          await dataSource.updateFaq(id, model);
        }
      });

  Future<bool> deleteFaq(int id) => _mutate(() => dataSource.deleteFaq(id));

  Future<bool> saveContact({
    required String email,
    required String phoneNumber,
    required String workingHours,
    String? address,
  }) =>
      _mutate(() async {
        await dataSource.updateContact(SupportContactModel(
          email: email,
          phoneNumber: phoneNumber,
          workingHours: workingHours,
          address: address,
        ));
      });

  /// Every write reloads afterwards, so the screen always shows what the server
  /// actually stored rather than what the form hoped it stored.
  Future<bool> _mutate(Future<void> Function() action) async {
    _isSaving = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    var ok = true;
    try {
      await action();
    } on Failure catch (f) {
      _error = f.message;
      _errorCode = f.code;
      ok = false;
    }

    _isSaving = false;
    if (ok) {
      await load();
    } else {
      notifyListeners();
    }
    return ok;
  }
}
