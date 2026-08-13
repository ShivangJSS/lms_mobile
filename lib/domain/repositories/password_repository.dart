abstract class PasswordRepository {
  /// Returns the reset token for the given username.
  Future<String> requestReset(String username);

  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  });
}
