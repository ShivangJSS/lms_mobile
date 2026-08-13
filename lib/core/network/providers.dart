import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../data/datasource/remote/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';

import '../../data/datasource/remote/module_remote_datasource.dart';
import '../../data/repositories/module_repository_impl.dart';
import '../../domain/repositories/module_repository.dart';

import '../../data/datasource/remote/feedback_remote_datasource.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/repositories/feedback_repository.dart';

import '../../data/datasource/remote/assessment_remote_datasource.dart';
import '../../data/repositories/module_assessment_repository_impl.dart';
import '../../domain/repositories/module_assessment_repository.dart';

import '../../data/datasource/remote/password_remote_datasource.dart';
import '../../data/repositories/password_repository_impl.dart';
import '../../domain/repositories/password_repository.dart';

import '../../data/datasource/local/dummy_assessment_data_source.dart';
import '../../data/repositories/assessment_repository_impl.dart';
import '../../domain/repositories/assessment_repository.dart';

/// ===============================
/// AUTH (REAL API)
/// ===============================

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(dataSource);
});

/// ===============================
/// DASHBOARD (REAL API)
/// ===============================

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(dashboardRemoteDataSourceProvider);

  return DashboardRepositoryImpl(dataSource);
});

/// ===============================
/// MODULE (REAL API)
/// ===============================

final moduleRemoteDataSourceProvider =
    Provider<ModuleRemoteDataSource>((ref) {
  return ModuleRemoteDataSource();
});

final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  final dataSource = ref.watch(moduleRemoteDataSourceProvider);

  return ModuleRepositoryImpl(dataSource);
});

/// ===============================
/// FEEDBACK (REAL API)
/// ===============================

final feedbackRemoteDataSourceProvider =
    Provider<FeedbackRemoteDataSource>((ref) {
  return FeedbackRemoteDataSource();
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final dataSource = ref.watch(feedbackRemoteDataSourceProvider);

  return FeedbackRepositoryImpl(dataSource);
});

/// ===============================
/// PASSWORD RESET (REAL API)
/// ===============================

final passwordRemoteDataSourceProvider =
    Provider<PasswordRemoteDataSource>((ref) {
  return PasswordRemoteDataSource();
});

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  final dataSource = ref.watch(passwordRemoteDataSourceProvider);

  return PasswordRepositoryImpl(dataSource);
});

/// ===============================
/// MODULE ASSESSMENT / MCQ (REAL API)
/// ===============================

final moduleAssessmentRemoteDataSourceProvider =
    Provider<ModuleAssessmentRemoteDataSource>((ref) {
  return ModuleAssessmentRemoteDataSource();
});

final moduleAssessmentRepositoryProvider =
    Provider<ModuleAssessmentRepository>((ref) {
  final dataSource = ref.watch(moduleAssessmentRemoteDataSourceProvider);

  return ModuleAssessmentRepositoryImpl(dataSource);
});

/// ===============================
/// STANDALONE ASSESSMENT SCREEN (PLACEHOLDER DATA)
///
/// The only screen still not on the real API — there is no mobile assessment
/// endpoint yet. Swap these two providers for a remote data source once
/// /mobile/assessment exists.
/// ===============================

final dummyAssessmentDataSourceProvider =
    Provider<DummyAssessmentDataSource>((ref) {
  return DummyAssessmentDataSource();
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final dataSource = ref.watch(dummyAssessmentDataSourceProvider);

  return AssessmentRepositoryImpl(dataSource);
});
