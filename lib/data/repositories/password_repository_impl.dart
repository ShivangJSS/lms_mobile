import '../../domain/repositories/password_repository.dart';
import '../datasource/remote/password_remote_datasource.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  final PasswordRemoteDataSource dataSource;

  PasswordRepositoryImpl(this.dataSource);

  @override
  Future<String> requestReset(String username) async {
    return await dataSource.requestReset(username);
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await dataSource.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
