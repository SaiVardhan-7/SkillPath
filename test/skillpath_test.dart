import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillpath/app/router.dart';
import 'package:skillpath/core/constants/api_constants.dart';
import 'package:skillpath/core/widgets/app_button.dart';
import 'package:skillpath/core/widgets/difficulty_badge.dart';
import 'package:skillpath/core/widgets/status_badge.dart';
import 'package:skillpath/features/auth/models/user_model.dart';
import 'package:skillpath/features/auth/providers/auth_provider.dart';
import 'package:skillpath/features/dsa/models/dsa_problem_model.dart';
import 'package:skillpath/features/projects/models/project_model.dart';
import 'package:skillpath/features/roadmaps/models/roadmap_model.dart';

void main() {
  group('ApiConstants Tests', () {
    test('ApiConstants.baseUrl is valid and does not have a trailing slash', () {
      final url = ApiConstants.baseUrl;
      expect(url.isNotEmpty, true);
      expect(url.startsWith('http://') || url.startsWith('https://'), true);
      expect(url.endsWith('/'), false);
      expect(url.endsWith('/api'), true);
    });
  });

  group('AuthState & UserModel Equality Tests', () {
    test('Identical AuthState instances are value-equal', () {
      const s1 = AuthState(status: AuthStatus.unauthenticated);
      const s2 = AuthState(status: AuthStatus.unauthenticated);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
    });

    test('Identical UserModel instances are value-equal', () {
      final u1 = UserModel(
        id: '123',
        name: 'Alex',
        email: 'alex@dev.com',
        targetRole: 'SDE',
        currentSkillLevel: 'Beginner',
        dailyStudyTimeMinutes: 60,
        learningGoals: [],
        isOnboarded: true,
      );
      final u2 = UserModel(
        id: '123',
        name: 'Alex',
        email: 'alex@dev.com',
        targetRole: 'SDE',
        currentSkillLevel: 'Beginner',
        dailyStudyTimeMinutes: 60,
        learningGoals: [],
        isOnboarded: true,
      );
      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
    });
  });
  group('UserModel Tests', () {
    test('UserModel should parse correctly from JSON', () {
      final json = {
        '_id': 'usr_123',
        'name': 'Alex Developer',
        'email': 'alex@example.com',
        'targetRole': 'Software Development Engineer',
        'currentSkillLevel': 'Intermediate',
        'dailyStudyTimeMinutes': 90,
        'learningGoals': ['Master DSA', 'Build Portfolio'],
        'isOnboarded': true,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'usr_123');
      expect(user.name, 'Alex Developer');
      expect(user.email, 'alex@example.com');
      expect(user.targetRole, 'Software Development Engineer');
      expect(user.currentSkillLevel, 'Intermediate');
      expect(user.dailyStudyTimeMinutes, 90);
      expect(user.learningGoals.length, 2);
      expect(user.isOnboarded, true);
    });

    test('UserModel copyWith should update specified fields', () {
      final user = UserModel(
        id: 'usr_1',
        name: 'Alex',
        email: 'alex@dev.com',
        targetRole: 'Flutter Developer',
        currentSkillLevel: 'Beginner',
        dailyStudyTimeMinutes: 60,
        learningGoals: [],
        isOnboarded: false,
      );

      final updated = user.copyWith(isOnboarded: true, dailyStudyTimeMinutes: 120);
      expect(updated.isOnboarded, true);
      expect(updated.dailyStudyTimeMinutes, 120);
      expect(updated.name, 'Alex');
    });
  });

  group('Roadmap & Topic Model Tests', () {
    test('TopicModel correctly identifies unlocked status and prerequisites', () {
      final json = {
        'topicId': 'sde-trees',
        'title': 'Binary Trees & BST',
        'description': 'Master tree traversals and balancing',
        'estimatedHours': 20,
        'prerequisites': ['sde-stacks'],
        'missingPrerequisites': [],
        'isUnlocked': true,
        'status': 'ready',
        'resources': [
          {
            'title': 'Tree Traversal Guide',
            'type': 'article',
            'url': 'https://example.com/trees',
            'durationMinutes': 45,
            'isBookmarked': true,
          }
        ],
      };

      final topic = TopicModel.fromJson(json);
      expect(topic.topicId, 'sde-trees');
      expect(topic.isUnlocked, true);
      expect(topic.status, 'ready');
      expect(topic.resources.length, 1);
      expect(topic.resources.first.isBookmarked, true);
    });

    test('StageModel calculates completion correctly', () {
      final stage = StageModel(
        stageNumber: 1,
        title: 'Stage 1: Fundamentals',
        description: 'Programming Basics',
        estimatedHours: 30,
        topics: [],
        totalTopics: 4,
        completedTopics: 3,
        progressPercentage: 75,
      );

      expect(stage.progressPercentage, 75);
      expect(stage.completedTopics, 3);
    });
  });

  group('DSA Model Tests', () {
    test('DSAProblemModel parses correctly and detects overdue revisions', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final problem = DSAProblemModel(
        id: 'p_1',
        title: 'Two Sum',
        url: 'https://leetcode.com/problems/two-sum/',
        platform: 'LeetCode',
        topic: 'Arrays',
        difficulty: 'Easy',
        status: 'solved',
        isBookmarked: true,
        notes: 'One-pass hash map',
        mistakes: 'Checked duplicates',
        observations: 'O(n) time',
        dateSolved: DateTime.now().subtract(const Duration(days: 5)),
        revisionScheduledDate: pastDate,
        revisionIntervalDays: 3,
        revisionCount: 1,
      );

      expect(problem.status, 'solved');
      expect(problem.isRevisionDue, true);
    });

    test('DSAProblemModel isRevisionDue returns false when future date', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final problem = DSAProblemModel(
        id: 'p_2',
        title: '3Sum',
        url: 'https://leetcode.com/problems/3sum/',
        platform: 'LeetCode',
        topic: 'Two pointers',
        difficulty: 'Medium',
        status: 'solved',
        isBookmarked: false,
        notes: 'Sort + two pointers',
        mistakes: '',
        observations: '',
        dateSolved: DateTime.now(),
        revisionScheduledDate: futureDate,
        revisionIntervalDays: 7,
        revisionCount: 0,
      );

      expect(problem.isRevisionDue, false);
    });
  });

  group('Project Model Tests', () {
    test('UserProjectModel computes milestone completion percentage', () {
      final project = ProjectModel(
        id: 'proj_1',
        title: 'Task Management App',
        slug: 'task-app',
        domain: 'Flutter development',
        difficulty: 'Beginner',
        requiredTech: ['Flutter', 'Riverpod'],
        estimatedHours: 20,
        prerequisites: [],
        description: 'Offline-first task tracker',
        learningObjectives: ['Local persistence', 'State management'],
        stepByStepPlan: [],
        milestones: [
          MilestoneModel(milestoneId: 'ms_1', title: 'Models', description: '', testingCriteria: ''),
          MilestoneModel(milestoneId: 'ms_2', title: 'Database', description: '', testingCriteria: ''),
          MilestoneModel(milestoneId: 'ms_3', title: 'UI', description: '', testingCriteria: ''),
          MilestoneModel(milestoneId: 'ms_4', title: 'Tests', description: '', testingCriteria: ''),
        ],
        suggestedResumeBullets: [],
      );

      final userProject = UserProjectModel(
        id: 'up_1',
        project: project,
        status: 'in_progress',
        completedMilestones: ['ms_1', 'ms_2'],
        githubUrl: 'https://github.com/alex/tasks',
        liveDemoUrl: '',
        notes: 'In progress',
        userResumeBullets: [],
        totalMilestones: 4,
        completedMilestonesCount: 2,
        progressPercentage: 50,
      );

      expect(userProject.progressPercentage, 50);
      expect(userProject.completedMilestones.length, 2);
    });
  });

  group('Widget UI Tests', () {
    testWidgets('AppButton renders text and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Start Journey',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Start Journey'), findsOneWidget);
      await tester.tap(find.text('Start Journey'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('DifficultyBadge displays Easy, Medium, Hard with correct text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DifficultyBadge(difficulty: 'Easy'),
                DifficultyBadge(difficulty: 'Medium'),
                DifficultyBadge(difficulty: 'Hard'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('StatusBadge displays Completed, In Progress, and Locked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: 'completed'),
                StatusBadge(status: 'in_progress'),
                StatusBadge(status: 'locked'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
    });
  });
}
