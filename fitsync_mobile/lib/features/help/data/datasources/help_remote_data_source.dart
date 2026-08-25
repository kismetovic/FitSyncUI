import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/faq_model.dart';
import '../models/support_contact_model.dart';

abstract class HelpRemoteDataSource {
  /// Only the entries the administrator has published.
  Future<List<FaqModel>> getFaqs();

  Future<SupportContactModel> getContact();
}

class HelpRemoteDataSourceImpl implements HelpRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  final String baseUrl = AppConfig.baseUrl;

  HelpRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _auth() async => Options(
        headers: {'Authorization': 'Bearer ${await localDataSource.getToken()}'},
      );

  ServerFailure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return ServerFailure(message, data['error']?.toString());
      }
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  @override
  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await dio.get('$baseUrl/Faqs/active', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => FaqModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat pitanja nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<SupportContactModel> getContact() async {
    try {
      final response = await dio.get('$baseUrl/Support/contact', options: await _auth());
      if (response.statusCode == 200) {
        return SupportContactModel.fromJson(response.data);
      }
      throw const ServerFailure('Dohvat kontakta nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
