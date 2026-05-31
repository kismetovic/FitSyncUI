import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/providers/locale_provider.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';

import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';

import 'features/training_types/presentation/providers/training_types_provider.dart';
import 'features/training_types/domain/usecases/get_training_types.dart';
import 'features/training_types/domain/usecases/create_training_type.dart';
import 'features/training_types/domain/usecases/update_training_type.dart';
import 'features/training_types/domain/usecases/delete_training_type.dart';
import 'features/training_types/domain/repositories/training_types_repository.dart';
import 'features/training_types/data/repositories/training_types_repository_impl.dart';
import 'features/training_types/data/datasources/training_types_remote_data_source.dart';

import 'features/additional_services/presentation/providers/additional_services_provider.dart';
import 'features/additional_services/domain/repositories/additional_services_repository.dart';
import 'features/additional_services/data/repositories/additional_services_repository_impl.dart';
import 'features/additional_services/data/datasources/additional_services_remote_data_source.dart';

import 'features/trainings/presentation/providers/trainings_provider.dart';
import 'features/trainings/domain/usecases/get_trainings.dart';
import 'features/trainings/domain/usecases/create_training.dart';
import 'features/trainings/domain/usecases/update_training.dart';
import 'features/trainings/domain/usecases/delete_training.dart';
import 'features/trainings/domain/repositories/trainings_repository.dart';
import 'features/trainings/data/repositories/trainings_repository_impl.dart';
import 'features/trainings/data/datasources/trainings_remote_data_source.dart';

import 'features/reservations/presentation/providers/reservations_provider.dart';
import 'features/reservations/domain/usecases/approve_reservation.dart';
import 'features/reservations/domain/usecases/get_reservations.dart';
import 'features/reservations/domain/usecases/update_reservation.dart';
import 'features/reservations/domain/usecases/delete_reservation.dart';
import 'features/reservations/domain/repositories/reservations_repository.dart';
import 'features/reservations/data/repositories/reservations_repository_impl.dart';
import 'features/reservations/data/datasources/reservations_remote_data_source.dart';

import 'features/users/presentation/providers/users_provider.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/domain/usecases/update_user.dart';
import 'features/users/domain/usecases/delete_user.dart';
import 'features/users/domain/usecases/send_payment_reminder.dart';
import 'features/users/domain/repositories/users_repository.dart';
import 'features/users/data/repositories/users_repository_impl.dart';
import 'features/users/data/datasources/users_remote_data_source.dart';

import 'features/reviews/presentation/providers/reviews_provider.dart';
import 'features/payments/presentation/providers/payments_provider.dart';
import 'features/payments/data/datasources/payments_remote_data_source.dart';
import 'features/reviews/domain/usecases/get_reviews.dart';
import 'features/reviews/domain/usecases/delete_review.dart';
import 'features/reviews/domain/repositories/reviews_repository.dart';
import 'features/reviews/data/repositories/reviews_repository_impl.dart';
import 'features/reviews/data/datasources/reviews_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => LocaleProvider(sharedPreferences));

  sl.registerFactory(() => AuthProvider(loginUser: sl(), registerUser: sl(), getCurrentUser: sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()));

  sl.registerFactory(() => DashboardProvider(getDashboardStats: sl()));
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => TrainingTypesProvider(
    getTrainingTypes: sl(),
    createTrainingType: sl(),
    updateTrainingType: sl(),
    deleteTrainingType: sl(),
  ));
  sl.registerLazySingleton(() => GetTrainingTypes(sl()));
  sl.registerLazySingleton(() => CreateTrainingType(sl()));
  sl.registerLazySingleton(() => UpdateTrainingType(sl()));
  sl.registerLazySingleton(() => DeleteTrainingType(sl()));
  sl.registerLazySingleton<TrainingTypesRepository>(() => TrainingTypesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TrainingTypesRemoteDataSource>(() => TrainingTypesRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => AdditionalServicesProvider(repository: sl()));
  sl.registerLazySingleton<AdditionalServicesRepository>(() => AdditionalServicesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AdditionalServicesRemoteDataSource>(() => AdditionalServicesRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => TrainingsProvider(
    getTrainings: sl(),
    createTraining: sl(),
    updateTraining: sl(),
    deleteTraining: sl(),
  ));
  sl.registerLazySingleton(() => GetTrainings(sl()));
  sl.registerLazySingleton(() => CreateTraining(sl()));
  sl.registerLazySingleton(() => UpdateTraining(sl()));
  sl.registerLazySingleton(() => DeleteTraining(sl()));
  sl.registerLazySingleton<TrainingsRepository>(() => TrainingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TrainingsRemoteDataSource>(() => TrainingsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => ReservationsProvider(
    getReservations: sl(),
    updateReservation: sl(),
    approveReservation: sl(),
    deleteReservation: sl(),
  ));
  sl.registerLazySingleton(() => GetReservations(sl()));
  sl.registerLazySingleton(() => UpdateReservation(sl()));
  sl.registerLazySingleton(() => ApproveReservation(sl()));
  sl.registerLazySingleton(() => DeleteReservation(sl()));
  sl.registerLazySingleton<ReservationsRepository>(() => ReservationsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReservationsRemoteDataSource>(() => ReservationsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => UsersProvider(
    getUsers: sl(),
    updateUser: sl(),
    deleteUser: sl(),
    sendPaymentReminder: sl(),
  ));
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));
  sl.registerLazySingleton(() => SendPaymentReminder(sl()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<UsersRemoteDataSource>(() => UsersRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => AdminPaymentsProvider(dataSource: sl()));
  sl.registerLazySingleton(() => PaymentsRemoteDataSource(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => ReviewsProvider(getReviews: sl(), deleteReview: sl()));
  sl.registerLazySingleton(() => GetReviews(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));
  sl.registerLazySingleton<ReviewsRepository>(() => ReviewsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReviewsRemoteDataSource>(() => ReviewsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));
}

