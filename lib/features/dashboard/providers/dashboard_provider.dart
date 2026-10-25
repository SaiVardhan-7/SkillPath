import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepository(apiClient: apiClient);
});

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardData();
});
