import 'participant_model.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final ParticipantModel? participant;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    this.participant,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["access_token"],
      refreshToken: json["refresh_token"],
      tokenType: json["token_type"],
      participant: json["participant"] != null
          ? ParticipantModel.fromJson(json["participant"])
          : null,
    );
  }
}