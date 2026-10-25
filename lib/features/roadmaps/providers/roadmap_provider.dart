import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/roadmap_repository.dart';
import '../models/roadmap_model.dart';

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoadmapRepository(apiClient: apiClient);
});

class SelectedRoadmapIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  set state(String? val) => super.state = val;
  void set(String? val) => state = val;
}

final selectedRoadmapIdProvider = NotifierProvider<SelectedRoadmapIdNotifier, String?>(SelectedRoadmapIdNotifier.new);

final allRoadmapsProvider = FutureProvider<List<RoadmapModel>>((ref) async {
  final repo = ref.watch(roadmapRepositoryProvider);
  return await repo.getRoadmaps();
});

final userRoadmapProvider = FutureProvider.autoDispose<UserRoadmapResponse>((ref) async {
  final repo = ref.watch(roadmapRepositoryProvider);
  final selectedId = ref.watch(selectedRoadmapIdProvider);
  return await repo.getUserRoadmap(roadmapId: selectedId);
});
