import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/additional_service.dart';

abstract class AdditionalServicesRepository {
  Future<Either<Failure, List<AdditionalService>>> getAdditionalServices();
}
