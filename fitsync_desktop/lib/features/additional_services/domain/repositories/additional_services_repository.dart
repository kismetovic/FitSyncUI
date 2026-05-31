import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/additional_service.dart';

abstract class AdditionalServicesRepository {
  Future<Either<Failure, List<AdditionalService>>> getAll();
  Future<Either<Failure, AdditionalService>> create(String name, double price);
  Future<Either<Failure, AdditionalService>> update(int id, String name, double price);
  Future<Either<Failure, void>> delete(int id);
}
