import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/project_repository.dart';
import '../models/project_model.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectRepository(apiClient: apiClient);
});

class ProjectDomainFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

class ProjectDifficultyFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

final projectDomainFilterProvider = NotifierProvider<ProjectDomainFilterNotifier, String>(ProjectDomainFilterNotifier.new);
final projectDifficultyFilterProvider = NotifierProvider<ProjectDifficultyFilterNotifier, String>(ProjectDifficultyFilterNotifier.new);

final allCatalogProjectsProvider = FutureProvider.autoDispose<List<ProjectModel>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  final domain = ref.watch(projectDomainFilterProvider);
  final difficulty = ref.watch(projectDifficultyFilterProvider);
  return await repo.getAllProjects(domain: domain, difficulty: difficulty);
});

final userProjectsProvider = FutureProvider.autoDispose<List<UserProjectModel>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return await repo.getUserProjects();
});

final projectDetailProvider = FutureProvider.autoDispose.family<ProjectModel, String>((ref, id) async {
  final repo = ref.watch(projectRepositoryProvider);
  return await repo.getProjectById(id);
});
