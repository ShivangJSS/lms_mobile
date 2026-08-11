import '../../data/models/participant_model.dart';

abstract class AuthRepository {
  Future<ParticipantModel> login(
      String username,
      String password,
      );

  Future<void> logout();

  Future<ParticipantModel?> getCurrentUser();

  Future<void> refreshToken();
}