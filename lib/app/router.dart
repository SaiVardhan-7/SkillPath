import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dsa/presentation/dsa_screen.dart';
import '../features/interview/presentation/interview_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/projects/presentation/project_detail_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/roadmaps/presentation/roadmap_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>();
final _shellNavigatorRoadmapKey = GlobalKey<NavigatorState>();
final _shellNavigatorDSAKey = GlobalKey<NavigatorState>();
final _shellNavigatorProjectsKey = GlobalKey<NavigatorState>();
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isDisposed = false;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        if (_isDisposed) return;
        if (previous?.status != next.status ||
            previous?.user?.isOnboarded != next.user?.isOnboarded ||
            previous?.user?.id != next.user?.id) {
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final status = authState.status;
    final isAuth = authState.isAuthenticated;
    final isOnboarded = authState.user?.isOnboarded == true;

    final location = state.uri.path;
    final isSplash = location == '/splash';
    final isAuthRoute = location == '/welcome' ||
        location == '/login' ||
        location == '/register' ||
        location == '/forgot-password';

    // 1. Initial app launch / auth check in progress
    if (status == AuthStatus.initial || (status == AuthStatus.loading && authState.user == null)) {
      return isSplash ? null : '/splash';
    }

    // 2. Unauthenticated user
    if (!isAuth) {
      if (isAuthRoute) {
        return null;
      }
      return '/welcome';
    }

    // 3. Authenticated user but not onboarded yet
    if (!isOnboarded) {
      if (location == '/onboarding') {
        return null;
      }
      return '/onboarding';
    }

    // 4. Authenticated & Onboarded user
    if (isSplash || isAuthRoute || location == '/onboarding') {
      return '/dashboard';
    }

    // Allow user to proceed to destination
    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/interview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const InterviewScreen(),
      ),

      // Bottom Navigation Stateful Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 0: Home (Dashboard)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // 1: Roadmap
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRoadmapKey,
            routes: [
              GoRoute(
                path: '/roadmap',
                builder: (context, state) => const RoadmapScreen(),
              ),
            ],
          ),

          // 2: DSA
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDSAKey,
            routes: [
              GoRoute(
                path: '/dsa',
                builder: (context, state) => const DSAScreen(),
              ),
            ],
          ),

          // 3: Projects
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProjectsKey,
            routes: [
              GoRoute(
                path: '/projects',
                builder: (context, state) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProjectDetailScreen(projectId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // 4: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
