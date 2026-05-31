import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/additional_service.dart';
import '../../domain/repositories/additional_services_repository.dart';
import '../datasources/additional_services_remote_data_source.dart';

class AdditionalServicesRepositoryImpl implements AdditionalServicesRepository {
  final AdditionalServicesRemoteDataSource remoteDataSource;

  AdditionalServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdditionalService>>> getAdditionalServices() async {
    try {
      final result = await remoteDataSource.getAdditionalServices();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
