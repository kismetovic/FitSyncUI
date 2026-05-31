import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/additional_service.dart';
import '../repositories/additional_services_repository.dart';

class GetAdditionalServices implements UseCase<List<AdditionalService>, NoParams> {
  final AdditionalServicesRepository repository;

  GetAdditionalServices(this.repository);

  @override
  Future<Either<Failure, List<AdditionalService>>> call(NoParams params) async {
    return await repository.getAdditionalServices();
  }
}
