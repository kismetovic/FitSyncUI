import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/membership_package_model.dart';
import '../models/user_membership_model.dart';

abstract class MembershipsRemoteDataSource {
  /// The packages currently on sale.
  Future<List<MembershipPackageModel>> getPackages();

  /// The signed-in user's own packages. The server reads the owner from the
  /// token, so there is no user id to pass.
  Future<List<UserMembershipModel>> getMyMemberships();

  /// Buys [packageId] for the signed-in user. The server sets the price and the
  /// validity period from the package; the client only names the package.
  Future<UserMembershipModel> purchase(int packageId);

  /// Cancels a package the signed-in user owns.
  Future<UserMembershipModel> cancel(int membershipId);

  /// Opens a PayPal order for a bought package. Returns the raw payload; the
  /// payments feature owns the approval and capture steps.
  Future<Map<String, dynamic>> createPayPalOrder(int membershipId);

  Future<Map<String, dynamic>> capturePayPal(String orderId, int membershipId);

  /// Records "I will pay at the desk". Staff still have to confirm the cash.
  Future<void> selectCash(int membershipId);
}

class MembershipsRemoteDataSourceImpl implements MembershipsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  MembershipsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Surfaces the server's own error message and code, matching the pattern the
  /// reservations data source uses.
  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['error']?.toString();
      final message = data['message']?.toString();
      if (message != null) return ServerFailure(message, code);
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return ServerFailure(first.first.toString());
      }
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  @override
  Future<List<MembershipPackageModel>> getPackages() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Memberships/packages', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => MembershipPackageModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat paketa nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<List<UserMembershipModel>> getMyMemberships() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get(
        '$baseUrl/Memberships/mine',
        queryParameters: {'page': 1, 'pageSize': 50},
        options: opts,
      );
      if (response.statusCode == 200) {
        // This endpoint is paginated, so the packages sit under `items`.
        final items = response.data['items'] as List? ?? const [];
        return items.map((e) => UserMembershipModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat vaših paketa nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<UserMembershipModel> purchase(int packageId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Memberships/purchase',
        data: {'membershipPackageId': packageId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserMembershipModel.fromJson(response.data);
      }
      throw const ServerFailure('Kupovina paketa nije uspjela.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  /// Package payments live under /Payments, deliberately: they go through the
  /// same verification a booking payment does.
  String get _paymentsUrl => '$baseUrl/Payments';

  @override
  Future<UserMembershipModel> cancel(int membershipId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.patch(
        '$baseUrl/Memberships/mine/$membershipId/cancel',
        options: opts,
      );
      if (response.statusCode == 200) {
        return UserMembershipModel.fromJson(response.data);
      }
      throw const ServerFailure('Otkazivanje paketa nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createPayPalOrder(int membershipId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$_paymentsUrl/membership/paypal/create-order',
        data: {'membershipId': membershipId},
        options: opts,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<Map<String, dynamic>> capturePayPal(String orderId, int membershipId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$_paymentsUrl/membership/paypal/capture',
        data: {'orderId': orderId, 'membershipId': membershipId},
        options: opts,
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> selectCash(int membershipId) async {
    try {
      final opts = await _getAuthOptions();
      await dio.post(
        '$_paymentsUrl/membership/cash/select',
        data: {'membershipId': membershipId},
        options: opts,
      );
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
