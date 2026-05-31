import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/additional_service.dart';
import '../../domain/repositories/additional_services_repository.dart';
import '../datasources/additional_services_remote_data_source.dart';

class AdditionalServicesRepositoryImpl implements AdditionalServicesRepository {
  final AdditionalServicesRemoteDataSource remoteDataSource;
  AdditionalServicesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdditionalService>>> getAll() async {
    try { return Right(await remoteDataSource.getAll()); }
    on Failure catch (e) { return Left(e); }
  }

  @override
  Future<Either<Failure, AdditionalService>> create(String name, double price) async {
    try { return Right(await remoteDataSource.create(name, price)); }
    on Failure catch (e) { return Left(e); }
  }

  @override
  Future<Either<Failure, AdditionalService>> update(int id, String name, double price) async {
    try { return Right(await remoteDataSource.update(id, name, price)); }
    on Failure catch (e) { return Left(e); }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try { await remoteDataSource.delete(id); return const Right(null); }
    on Failure catch (e) { return Left(e); }
  }
}
