import 'package:event_hub_mobile/features/auth/data/models/user.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const checkEmail = '/check-email';
  static const home = '/';
  static const discover = '/discover';
  static const tickets = '/tickets';
  static const saved = '/saved';
  static const profile = '/profile';
  static const search = '/search';

  // Organizer and admin accounts get their own tabs, all under /org: they
  // follow sales and check guests in, they do not buy tickets.
  static const orgEvents = '/org/events';
  static const orgBookings = '/org/bookings';
  static const orgCheckIn = '/org/check-in';
  static const orgProfile = '/org/profile';
  static const orgCheckInResult = '/org/check-in/result';

  static const orgEventPattern = '/org/events/:id';
  static String orgEvent(String id) => '/org/events/$id';

  static const orgAttendeesPattern = '/org/events/:id/attendees';
  static String orgAttendees(String id) => '/org/events/$id/attendees';

  /// The event as an attendee sees it.
  static const orgPreviewPattern = '/org/events/:id/preview';
  static String orgPreview(String id) => '/org/events/$id/preview';

  /// Where a signed-in account starts.
  static String homeFor(UserRole role) =>
      role == UserRole.attendee ? home : orgEvents;

  static const ticketDetailPattern = '/tickets/:id';
  static String ticketDetail(String bookingId) => '/tickets/$bookingId';

  static const eventDetailPattern = '/events/:id';
  static String eventDetail(String id) => '/events/$id';

  // Booking flow
  static const selectTicketsPattern = '/events/:id/tickets';
  static String selectTickets(String eventId) => '/events/$eventId/tickets';

  static const checkoutPattern = '/bookings/:id/checkout';
  static String checkout(String bookingId) => '/bookings/$bookingId/checkout';

  static const paymentPattern = '/bookings/:id/payment';
  static String payment(String bookingId) => '/bookings/$bookingId/payment';

  static const orderSuccessPattern = '/bookings/:id/success';
  static String orderSuccess(String bookingId) =>
      '/bookings/$bookingId/success';

  static const paymentFailedPattern = '/bookings/:id/failed';
  static String paymentFailed(String bookingId) =>
      '/bookings/$bookingId/failed';
}
