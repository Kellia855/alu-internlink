/// Route/tab identifiers used across the app.
///
/// `login`, `signup`, and `splash` are real named [Navigator] routes.
/// `home`, `discover`, `applications`, and `profile` are shared tab
/// identifiers used by [MainShell]'s bottom navigation bar -- both the
/// student and startup experiences use these exact same four slots, they
/// simply render different content per role.
class AppRoutes {
  AppRoutes._();

  // Named Navigator routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';

  // Shared bottom-nav tab identifiers (role-agnostic)
  static const String home = 'home';
  static const String discover = 'discover';
  static const String applications = 'applications';
  static const String profile = 'profile';

  /// Order in which tabs appear in the bottom navigation bar.
  static const List<String> tabOrder = [home, discover, applications, profile];
}
