import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservations_repository.dart';

/// Fetches one page of reservations, optionally filtered by a search term.
///
/// Both the paging and the text match happen on the server (review item 22), so
/// searching does not depend on how much of the table the client happens to hold.
class GetReservations {
  final ReservationsRepository repository;

  GetReservations(this.repository);

  Future<Either<Failure, PagedResult<Reservation>>> call({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) =>
      repository.getReservations(page: page, pageSize: pageSize, query: query);
}
