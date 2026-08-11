import '../../core/services/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/participant_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  ParticipantModel? _currentUser;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<ParticipantModel> login(
      String username,
      String password,
      ) async {
    final response = await dataSource.login(
      LoginRequest(
        username: username,
        password: password,
      ),
    );

    // Save JWT Tokens
    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    if (response.participant == null) {
      throw Exception("Participant data not found");
    }

    _currentUser = response.participant!;

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    try {
      await dataSource.logout();
    } catch (_) {}

    await TokenStorage.clear();
    _currentUser = null;
  }

  @override
  Future<ParticipantModel?> getCurrentUser() async {
    final participant = await dataSource.getCurrentUser();

    _currentUser = participant;

    return _currentUser;
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null) {
      throw Exception("Refresh token not found");
    }

    final response = await dataSource.refreshToken(
      refreshToken,
    );

    await TokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}