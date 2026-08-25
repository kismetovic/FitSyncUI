import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/additional_service_model.dart';

abstract class AdditionalServicesRemoteDataSource {
  Future<List<AdditionalServiceModel>> getAll();
  Future<AdditionalServiceModel> create(String name, double price);
  Future<AdditionalServiceModel> update(int id, String name, double price);
  Future<void> delete(int id);
}

class AdditionalServicesRemoteDataSourceImpl implements AdditionalServicesRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  AdditionalServicesRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _auth() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<AdditionalServiceModel>> getAll() async {
    try {
      final response = await dio.get('$baseUrl/AdditionalServices', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => AdditionalServiceModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get additional services');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<AdditionalServiceModel> create(String name, double price) async {
    try {
      final response = await dio.post('$baseUrl/AdditionalServices',
          data: {'name': name, 'price': price}, options: await _auth());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AdditionalServiceModel.fromJson(response.data);
      }
      throw const ServerFailure('Failed to create additional service');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<AdditionalServiceModel> update(int id, String name, double price) async {
    try {
      final response = await dio.put('$baseUrl/AdditionalServices/$id',
          data: {'name': name, 'price': price}, options: await _auth());
      if (response.statusCode == 200) return AdditionalServiceModel.fromJson(response.data);
      throw const ServerFailure('Failed to update additional service');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final response = await dio.delete('$baseUrl/AdditionalServices/$id', options: await _auth());
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to delete additional service');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }
}
