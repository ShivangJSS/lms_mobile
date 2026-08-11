import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasource/local/dummy_dashboard_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DummyDashboardDataSource dataSource;

  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<DashboardStats> getDashboardStats(String userId) async {
    return await dataSource.getDashboardStats(userId);
  }
}
