import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendee/presentation/attendee_camera_screen.dart';
import '../../features/attendee/presentation/manual_code_entry_screen.dart';
import '../../features/attendee/presentation/photo_review_screen.dart';
import '../../features/attendee/presentation/qr_scanner_screen.dart';
import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/organizer_login_screen.dart';
import '../../features/auth/presentation/organizer_signup_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/create_event_pricing_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/organizer/presentation/organizer_dashboard_screen.dart';
import '../../features/organizer/presentation/organizer_events_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../../shared/widgets/shell/organizer_shell_scaffold.dart';

/// Central router for EventShot. Expand with shell routes and feature routes.
class AppRouter {
  static const String welcome = '/welcome';
  static const String organizerSignUp = '/auth/organizer-signup';
  static const String organizerLogin = '/auth/organizer-login';
  static const String organizerDashboard = '/organizer/dashboard';
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

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: welcome,
      redirect: (context, state) {
        if (state.matchedLocation == '/organizer' ||
            state.matchedLocation == '/organizer/') {
          return organizerDashboard;
        }
        return null;
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
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/organizer/profile',
                  builder: (context, state) =>
                      const _PlaceholderScreen(title: 'Organizer Profile'),
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
            return GalleryScreen(eventId: eventId);
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
      ],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
