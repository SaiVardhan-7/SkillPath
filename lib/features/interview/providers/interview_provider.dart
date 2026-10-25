import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/interview_repository.dart';
import '../models/interview_model.dart';

final interviewRepositoryProvider = Provider<InterviewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InterviewRepository(apiClient: apiClient);
});

class InterviewCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  set state(String val) => super.state = val;
  void set(String val) => state = val;
}

final interviewCategoryFilterProvider = NotifierProvider<InterviewCategoryFilterNotifier, String>(InterviewCategoryFilterNotifier.new);

final interviewQuestionsProvider = FutureProvider.autoDispose<List<InterviewQuestionModel>>((ref) async {
  final repo = ref.watch(interviewRepositoryProvider);
  final category = ref.watch(interviewCategoryFilterProvider);
  return await repo.getQuestions(category: category);
});
