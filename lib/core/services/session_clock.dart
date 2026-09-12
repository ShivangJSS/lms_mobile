/// Tracks how long the current sign-in has lasted, so the whole-session time
/// can be reported once on logout.
///
/// Deliberately tiny and static: the value only needs to survive between login
/// and logout within one app run, and losing it (e.g. the app is killed) simply
/// means that session is not reported — which is preferable to guessing.
class SessionClock {
  SessionClock._();

  static DateTime? _startedAt;

  /// Called when a session begins (fresh login or a restored session).
  static void start() {
    _startedAt = DateTime.now();
  }

  /// Whole minutes elapsed since [start], or null if no session is running.
  static int? elapsedMinutes() {
    final started = _startedAt;
    if (started == null) return null;

    final minutes = DateTime.now().difference(started).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  static void clear() {
    _startedAt = null;
  }
}
