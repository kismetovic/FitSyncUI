import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/membership_package_model.dart';

/// Administration of the monthly packages. Every route here is
/// `Authorize(Roles = Administrator)` on the API; the client app only ever sees
/// `/Memberships/packages` and its own `/Memberships/mine`.
abstract class MembershipsRemoteDataSource {
  Future<List<MembershipPackageModel>> getPackages();
  Future<MembershipPackageModel> createPackage(MembershipPackageModel package);
  Future<MembershipPackageModel> updatePackage(int id, MembershipPackageModel package);
  Future<void> deletePackage(int id);
}

class MembershipsRemoteDataSourceImpl implements MembershipsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  MembershipsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _auth() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Surfaces the server's own validation message rather than raw JSON.
  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null) return message;
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return e.message ?? 'Request failed';
  }

  Map<String, dynamic> _body(MembershipPackageModel p) => {
        'name': p.name,
        'description': p.description,
        'durationDays': p.durationDays,
        'sessionCount': p.sessionCount,
        'price': p.price,
        'trainingTypeId': p.trainingTypeId,
        'isActive': p.isActive,
      };

  @override
  Future<List<MembershipPackageModel>> getPackages() async {
    try {
      final response = await dio.get('$baseUrl/Memberships', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => MembershipPackageModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat paketa nije uspio.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<MembershipPackageModel> createPackage(MembershipPackageModel package) async {
    try {
      final response = await dio.post(
        '$baseUrl/Memberships',
        data: _body(package),
        options: await _auth(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MembershipPackageModel.fromJson(response.data);
      }
      throw const ServerFailure('Kreiranje paketa nije uspjelo.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<MembershipPackageModel> updatePackage(int id, MembershipPackageModel package) async {
    try {
      final response = await dio.put(
        '$baseUrl/Memberships/$id',
        data: _body(package),
        options: await _auth(),
      );
      if (response.statusCode == 200) {
        return MembershipPackageModel.fromJson(response.data);
      }
      throw const ServerFailure('Izmjena paketa nije uspjela.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<void> deletePackage(int id) async {
    try {
      final response = await dio.delete('$baseUrl/Memberships/$id', options: await _auth());
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Brisanje paketa nije uspjelo.');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }
}
