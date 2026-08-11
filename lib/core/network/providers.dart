import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../data/datasource/local/dummy_dashboard_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';

import '../../data/datasource/local/dummy_feedback_data_source.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../data/datasource/local/dummy_feedback_data_source.dart';
/// ===============================
/// AUTH (REAL API)
/// ===============================

final authRemoteDataSourceProvider =
Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider =
Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(dataSource);
});

/// ===============================
/// DASHBOARD (DUMMY)
/// ===============================

final dummyDashboardDataSourceProvider =
Provider<DummyDashboardDataSource>((ref) {
  return DummyDashboardDataSource();
});

final dashboardRepositoryProvider =
Provider<DashboardRepository>((ref) {
  final dataSource = ref.watch(dummyDashboardDataSourceProvider);

  return DashboardRepositoryImpl(dataSource);
});

/// ===============================
/// ASSESSMENT (DUMMY)
/// ===============================



final dummyFeedbackDataSourceProvider =
Provider<DummyFeedbackDataSource>((ref) {
  return DummyFeedbackDataSource();
});

final assessmentRepositoryProvider =
Provider<AssessmentRepository>((ref) {
  final dataSource = ref.watch(
    dummyFeedbackDataSourceProvider,
  );

  return AssessmentRepositoryImpl(dataSource);
});