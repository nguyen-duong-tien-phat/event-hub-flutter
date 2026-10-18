abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const checkEmail = '/check-email';
  static const home = '/';

  static const eventDetailPattern = '/events/:id';
  static String eventDetail(String id) => '/events/$id';
}
