import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/organizer.dart';
import '../../features/attendee/presentation/attendee_camera_screen.dart';
import '../../features/attendee/presentation/manual_code_entry_screen.dart';
import '../../features/attendee/presentation/photo_review_screen.dart';
import '../../features/attendee/presentation/qr_scanner_screen.dart';
import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/organizer_login_screen.dart';
import '../../features/auth/presentation/organizer_signup_screen.dart';
import '../../features/auth/presentation/attendee_login_screen.dart';
import '../../features/auth/presentation/attendee_signup_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/user/presentation/user_dashboard_screen.dart';
import '../../features/user/presentation/user_settings_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/create_event_pricing_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/gallery/presentation/photo_view_screen.dart';
import '../../features/organizer/presentation/organizer_dashboard_screen.dart';
import '../../features/organizer/presentation/organizer_events_screen.dart';
import '../../features/organizer/presentation/event_detail_screen.dart';
import '../../features/organizer/presentation/organizer_profile_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../../shared/widgets/shell/organizer_shell_scaffold.dart';
import '../../shared/widgets/shell/user_shell_scaffold.dart';

/// Central router for EventShot. Expand with shell routes and feature routes.
class AppRouter {
  static const String welcome = '/welcome';
  static const String organizerSignUp = '/auth/organizer-signup';
  static const String organizerLogin = '/auth/organizer-login';
  static const String attendeeSignUp = '/auth/attendee-signup';
  static const String attendeeLogin = '/auth/attendee-login';
  static const String organizerDashboard = '/organizer/dashboard';
  static const String userDashboard = '/user/dashboard';
  static const String emailVerification = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String organizerEvents = '/organizer/events';
  static const String organizerProfile = '/organizer/profile';
  static const String attendeeScan = '/attendee/scan';
  static const String attendeeManualCode = '/attendee/manual-code';
  static const String attendeeCamera = '/attendee/camera';
  static const String gallery = '/gallery';
  static const String checkout = '/checkout';
  static const String photoReview = '/photo-review';
  static const String createEvent = '/create-event';

  static String? redirectLogic({
    required String matchedLocation,
    required AsyncValue<Organizer?> authState,
    bool isAnon = false,
  }) {
    if (authState.isLoading) return null;

    final authUser = authState.valueOrNull;
    if (matchedLocation == '/organizer' || matchedLocation == '/organizer/') {
      return organizerDashboard;
    }

    final inAuthFlow = matchedLocation == welcome || matchedLocation.startsWith('/auth');
    final inOrganizerFlow = matchedLocation.startsWith('/organizer') || matchedLocation == createEvent;
    final inUserFlow = matchedLocation.startsWith('/user');

    if (authUser != null && inAuthFlow) {
      if (!isAnon) {
        return authUser.role == 'attendee' ? userDashboard : organizerDashboard;
      }
    }

    if (authUser != null && !isAnon) {
      if (authUser.role == 'attendee' && inOrganizerFlow) return userDashboard;
      if (authUser.role != 'attendee' && inUserFlow) return organizerDashboard;
    }

    if ((authUser == null || isAnon) && (inOrganizerFlow || inUserFlow)) {
      return welcome;
    }

    return null;
  }

  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: welcome,
      redirect: (context, state) {
        final authState = ref.watch(authStateProvider);
        final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
        return redirectLogic(
          matchedLocation: state.matchedLocation,
          authState: authState,
          isAnon: isAnon,
        );
      },
      routes: [
        GoRoute(
          path: welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: organizerSignUp,
          builder: (context, state) => const OrganizerSignUpScreen(),
        ),
        GoRoute(
          path: organizerLogin,
          builder: (context, state) => const OrganizerLoginScreen(),
        ),
        GoRoute(
          path: attendeeSignUp,
          builder: (context, state) => const AttendeeSignUpScreen(),
        ),
        GoRoute(
          path: attendeeLogin,
          builder: (context, state) => const AttendeeLoginScreen(),
        ),
        GoRoute(
          path: emailVerification,
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: createEvent,
          builder: (context, state) => const CreateEventPricingScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return OrganizerShellScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/dashboard',
                  builder: (context, state) => const OrganizerDashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/events',
                  builder: (context, state) => const OrganizerEventsScreen(),
                  routes: [
                    GoRoute(
                      path: ':eventId',
                      builder: (context, state) {
                        final eventId = state.pathParameters['eventId']!;
                        return EventDetailScreen(eventId: eventId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/profile',
                  builder: (context, state) => const OrganizerProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return UserShellScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/user/dashboard',
                  builder: (context, state) => const UserDashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/user/settings',
                  builder: (context, state) => const UserSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: attendeeScan,
          builder: (context, state) => const QrScannerScreen(),
        ),
        GoRoute(
          path: attendeeManualCode,
          builder: (context, state) => const ManualCodeEntryScreen(),
        ),
        GoRoute(
          path: attendeeCamera,
          builder: (context, state) => const AttendeeCameraScreen(),
        ),
        GoRoute(
          path: '$gallery/:eventId',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            final from = state.uri.queryParameters['from'];
            return GalleryScreen(eventId: eventId, showTakePictures: from == 'dashboard');
          },
        ),
        GoRoute(
          path: '$checkout/:eventId',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return CheckoutScreen(eventId: eventId);
          },
        ),
        GoRoute(
          path: photoReview,
          builder: (context, state) => const PhotoReviewScreen(),
        ),
        GoRoute(
          path: '/photo',
          builder: (context, state) {
            final url = state.uri.queryParameters['url'] ?? '';
            return PhotoViewScreen(imageUrl: url);
          },
        ),
      ],
    );
  }
}
