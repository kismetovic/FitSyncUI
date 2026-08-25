import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paged_result.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

/// One page of users, optionally filtered by name and by role. All three - the
/// name filter, the role filter and the page - are applied in SQL (review items
/// 14 and 22). The role filter is what keeps clients and staff on separate screens.
class GetUsers {
  final UsersRepository repository;

  GetUsers(this.repository);

  Future<Either<Failure, PagedResult<User>>> call({
    String? searchQuery,
    String? role,
    int page = 1,
    int pageSize = kDefaultPageSize,
  }) =>
      repository.getUsers(searchQuery: searchQuery, role: role, page: page, pageSize: pageSize);
}
