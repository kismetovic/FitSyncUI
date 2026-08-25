import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/help_remote_data_source.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_contact.dart';

/// The help screen's content, which now comes from the API.
///
/// It used to be a `static const` list of English questions and an invented
/// support@fitsync.app address inside the widget, so nothing on that screen was
/// true and none of it could be corrected without a new build.
class HelpProvider extends ChangeNotifier {
  final HelpRemoteDataSource dataSource;

  HelpProvider({required this.dataSource});

  List<Faq> _faqs = const [];
  List<Faq> get faqs => _faqs;

  SupportContact? _contact;
  SupportContact? get contact => _contact;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    try {
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
}
