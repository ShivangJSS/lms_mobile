import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/dashboard_tip.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasource/remote/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource dataSource;

  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<DashboardStats> getDashboardStats() async {
    return await dataSource.getDashboardStats();
  }

  @override
  Future<List<DashboardTip>> getTips({required int languageId}) async {
    return await dataSource.getTips(languageId: languageId);
  }
}
