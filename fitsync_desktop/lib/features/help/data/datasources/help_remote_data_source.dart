import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/faq_model.dart';
import '../models/support_contact_model.dart';

abstract class HelpRemoteDataSource {
  Future<List<FaqModel>> getFaqs();
  Future<FaqModel> createFaq(FaqModel faq);
  Future<FaqModel> updateFaq(int id, FaqModel faq);
  Future<void> deleteFaq(int id);

  Future<SupportContactModel> getContact();
  Future<SupportContactModel> updateContact(SupportContactModel contact);
}

class HelpRemoteDataSourceImpl implements HelpRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  final String baseUrl = AppConfig.baseUrl;

  HelpRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _auth() async => Options(
        headers: {'Authorization': 'Bearer ${await localDataSource.getToken()}'},
      );

  @override
  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await dio.get('$baseUrl/Faqs', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => FaqModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat pitanja nije uspio.');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<FaqModel> createFaq(FaqModel faq) async {
    try {
      final response = await dio.post('$baseUrl/Faqs',
          data: faq.toJson(), options: await _auth());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FaqModel.fromJson(response.data);
      }
      throw const ServerFailure('Kreiranje pitanja nije uspjelo.');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<FaqModel> updateFaq(int id, FaqModel faq) async {
    try {
      final response = await dio.put('$baseUrl/Faqs/$id',
          data: faq.toJson(), options: await _auth());
      if (response.statusCode == 200) return FaqModel.fromJson(response.data);
      throw const ServerFailure('Izmjena pitanja nije uspjela.');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<void> deleteFaq(int id) async {
    try {
      final response = await dio.delete('$baseUrl/Faqs/$id', options: await _auth());
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Brisanje pitanja nije uspjelo.');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
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
      throw failureFrom(e);
    }
  }

  @override
  Future<SupportContactModel> updateContact(SupportContactModel contact) async {
    try {
      final response = await dio.put('$baseUrl/Support/contact',
          data: contact.toJson(), options: await _auth());
      if (response.statusCode == 200) {
        return SupportContactModel.fromJson(response.data);
      }
      throw const ServerFailure('Izmjena kontakta nije uspjela.');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }
}
