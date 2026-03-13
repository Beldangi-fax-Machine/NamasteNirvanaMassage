import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/supabase_config.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/booking_history_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route names
class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String bookingHistory = '/profile/bookings';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = SupabaseConfig.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.welcome ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword;

      // If user is authenticated and trying to access auth routes, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      // If user is not authenticated and trying to access protected routes
      // Allow access to welcome screen but redirect from protected routes
      if (!isAuthenticated && !isAuthRoute && state.matchedLocation != AppRoutes.welcome) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.services,
            name: 'services',
            builder: (context, state) => const ServicesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'serviceDetail',
                builder: (context, state) {
                  final serviceId = state.pathParameters['id']!;
                  return ServiceDetailScreen(serviceId: serviceId);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.booking,
            name: 'booking',
            builder: (context, state) => const BookingScreen(),
            routes: [
              GoRoute(
                path: 'confirmation',
                name: 'bookingConfirmation',
                builder: (context, state) => const BookingConfirmationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editProfile',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'bookings',
                name: 'bookingHistory',
                builder: (context, state) => const BookingHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
