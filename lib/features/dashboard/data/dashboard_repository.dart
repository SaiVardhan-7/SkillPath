import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient apiClient;

  DashboardRepository({required this.apiClient});

  Future<DashboardData> getDashboardData() async {
    final response = await apiClient.get(ApiConstants.dashboard);
    return DashboardData.fromJson(response['data']);
  }
}
