import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paged_result.dart';
import '../entities/training.dart';
import '../repositories/trainings_repository.dart';

/// One page of trainings, optionally filtered by name. Both are applied by the
/// API (review item 22).
class GetTrainings {
  final TrainingsRepository repository;

  GetTrainings(this.repository);

  Future<Either<Failure, PagedResult<Training>>> call({
    String? searchQuery,
    int page = 1,
    int pageSize = kDefaultPageSize,
  }) =>
      repository.getTrainings(searchQuery: searchQuery, page: page, pageSize: pageSize);
}
