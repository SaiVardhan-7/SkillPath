import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/dsa_repository.dart';
import '../models/dsa_problem_model.dart';

final dsaRepositoryProvider = Provider<DSARepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DSARepository(apiClient: apiClient);
});

// Filter Notifiers with public state setter
class DSATopicFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

class DSADifficultyFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

class DSAStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

class DSASearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  @override
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

class DSABookmarkedFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  @override
  set state(bool val) => super.state = val;
  void toggle() => state = !state;
}

final dsaTopicFilterProvider = NotifierProvider<DSATopicFilterNotifier, String>(DSATopicFilterNotifier.new);
final dsaDifficultyFilterProvider = NotifierProvider<DSADifficultyFilterNotifier, String>(DSADifficultyFilterNotifier.new);
final dsaStatusFilterProvider = NotifierProvider<DSAStatusFilterNotifier, String>(DSAStatusFilterNotifier.new);
final dsaSearchQueryProvider = NotifierProvider<DSASearchQueryNotifier, String>(DSASearchQueryNotifier.new);
final dsaBookmarkedFilterProvider = NotifierProvider<DSABookmarkedFilterNotifier, bool>(DSABookmarkedFilterNotifier.new);

final userProblemsProvider = FutureProvider.autoDispose<UserProblemsResponse>((ref) async {
  final repo = ref.watch(dsaRepositoryProvider);
  final topic = ref.watch(dsaTopicFilterProvider);
  final difficulty = ref.watch(dsaDifficultyFilterProvider);
  final status = ref.watch(dsaStatusFilterProvider);
  final search = ref.watch(dsaSearchQueryProvider);
  final bookmarked = ref.watch(dsaBookmarkedFilterProvider);

  return await repo.getUserProblems(
    topic: topic,
    difficulty: difficulty,
    status: status,
    search: search,
    bookmarked: bookmarked ? true : null,
  );
});

final catalogProblemsProvider = FutureProvider.autoDispose<List<DSAProblemModel>>((ref) async {
  final repo = ref.watch(dsaRepositoryProvider);
  final topic = ref.watch(dsaTopicFilterProvider);
  final difficulty = ref.watch(dsaDifficultyFilterProvider);
  return await repo.getCatalogProblems(topic: topic, difficulty: difficulty);
});
