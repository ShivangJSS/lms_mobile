import '../entities/dashboard_stats.dart';
import '../entities/dashboard_tip.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getDashboardStats();

  Future<List<DashboardTip>> getTips({required int languageId});
}
