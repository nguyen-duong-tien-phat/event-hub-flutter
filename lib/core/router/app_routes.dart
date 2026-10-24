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
