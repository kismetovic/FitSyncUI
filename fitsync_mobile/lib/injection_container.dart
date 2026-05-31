import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/providers/locale_provider.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';

import 'features/trainings/presentation/providers/trainings_provider.dart';
import 'features/trainings/presentation/providers/recommendations_provider.dart';
import 'features/trainings/domain/usecases/get_trainings.dart';
import 'features/trainings/domain/usecases/get_recommendations.dart';
import 'features/trainings/domain/repositories/trainings_repository.dart';
import 'features/trainings/data/repositories/trainings_repository_impl.dart';
import 'features/trainings/data/datasources/trainings_remote_data_source.dart';

import 'features/reservations/presentation/providers/reservations_provider.dart';
import 'features/reservations/domain/usecases/get_my_reservations.dart';
import 'features/reservations/domain/usecases/create_reservation.dart';
import 'features/reservations/domain/usecases/cancel_reservation.dart';
import 'features/reservations/domain/repositories/reservations_repository.dart';
import 'features/reservations/data/repositories/reservations_repository_impl.dart';
import 'features/reservations/data/datasources/reservations_remote_data_source.dart';

import 'features/reviews/presentation/providers/reviews_provider.dart';
import 'features/reviews/domain/usecases/get_training_reviews.dart';
import 'features/reviews/domain/usecases/create_review.dart';
import 'features/reviews/domain/repositories/reviews_repository.dart';
import 'features/reviews/data/repositories/reviews_repository_impl.dart';
import 'features/reviews/data/datasources/reviews_remote_data_source.dart';

import 'features/additional_services/presentation/providers/additional_services_provider.dart';
import 'features/additional_services/domain/usecases/get_additional_services.dart';
import 'features/additional_services/domain/repositories/additional_services_repository.dart';
import 'features/additional_services/data/repositories/additional_services_repository_impl.dart';
import 'features/additional_services/data/datasources/additional_services_remote_data_source.dart';

import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/notifications/domain/usecases/get_my_notifications.dart';
import 'features/notifications/domain/usecases/mark_notification_read.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/notifications/data/datasources/notifications_remote_data_source.dart';

import 'features/payments/presentation/providers/payments_provider.dart';
import 'features/payments/domain/usecases/capture_paypal_order.dart';
import 'features/payments/domain/usecases/create_paypal_order.dart';
import 'features/payments/domain/usecases/confirm_payment.dart';
import 'features/payments/domain/usecases/confirm_cash_payment.dart';
import 'features/payments/domain/usecases/get_my_payments.dart';
import 'features/payments/domain/repositories/payments_repository.dart';
import 'features/payments/data/repositories/payments_repository_impl.dart';
import 'features/payments/data/datasources/payments_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => LocaleProvider(sharedPreferences));
  sl.registerLazySingleton(() => Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 10),
  )));

  sl.registerFactory(() => AuthProvider(loginUser: sl(), registerUser: sl(), getCurrentUser: sl(), changePasswordUseCase: sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()));

  sl.registerFactory(() => TrainingsProvider(getTrainings: sl()));
  sl.registerFactory(() => RecommendationsProvider(getRecommendations: sl()));
  sl.registerLazySingleton(() => GetTrainings(sl()));
  sl.registerLazySingleton(() => GetRecommendations(sl()));
  sl.registerLazySingleton<TrainingsRepository>(() => TrainingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TrainingsRemoteDataSource>(() => TrainingsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => ReservationsProvider(
    getMyReservations: sl(),
    createReservation: sl(),
    cancelReservation: sl(),
    repository: sl(),
  ));
  sl.registerLazySingleton(() => GetMyReservations(sl()));
  sl.registerLazySingleton(() => CreateReservation(sl()));
  sl.registerLazySingleton(() => CancelReservation(sl()));
  sl.registerLazySingleton<ReservationsRepository>(() => ReservationsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReservationsRemoteDataSource>(() => ReservationsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => ReviewsProvider(getTrainingReviews: sl(), createReview: sl()));
  sl.registerLazySingleton(() => GetTrainingReviews(sl()));
  sl.registerLazySingleton(() => CreateReview(sl()));
  sl.registerLazySingleton<ReviewsRepository>(() => ReviewsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReviewsRemoteDataSource>(() => ReviewsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => AdditionalServicesProvider(getAdditionalServices: sl()));
  sl.registerLazySingleton(() => GetAdditionalServices(sl()));
  sl.registerLazySingleton<AdditionalServicesRepository>(() => AdditionalServicesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AdditionalServicesRemoteDataSource>(() => AdditionalServicesRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => NotificationsProvider(
    getMyNotifications: sl(),
    markNotificationRead: sl(),
  ));
  sl.registerLazySingleton(() => GetMyNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationRead(sl()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));

  sl.registerFactory(() => PaymentsProvider(
    createPayPalOrder: sl(),
    capturePayPalOrder: sl(),
    confirmPayment: sl(),
    confirmCashPayment: sl(),
    getMyPayments: sl(),
  ));
  sl.registerLazySingleton(() => CreatePayPalOrder(sl()));
  sl.registerLazySingleton(() => CapturePayPalOrder(sl()));
  sl.registerLazySingleton(() => ConfirmPayment(sl()));
  sl.registerLazySingleton(() => ConfirmCashPayment(sl()));
  sl.registerLazySingleton(() => GetMyPayments(sl()));
  sl.registerLazySingleton<PaymentsRepository>(() => PaymentsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<PaymentsRemoteDataSource>(() => PaymentsRemoteDataSourceImpl(dio: sl(), localDataSource: sl()));
}

