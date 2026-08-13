import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../../core/services/token_storage.dart';
import '../../data/models/participant_model.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final ParticipantModel? user;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    ParticipantModel? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final Ref ref;

  LoginViewModel(this.ref) : super(const LoginState());

  Future<bool> login(
      String username,
      String password,
      ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(authRepositoryProvider);

      final participant = await repository.login(
        username,
        password,
      );

      state = LoginState(
        isLoading: false,
        user: participant,
      );

      return true;
    } on DioException catch (e) {
      String message;

      switch (e.response?.statusCode) {
        case 401:
          message = "Invalid username or password";
          break;

        case 500:
          message = "Server error. Please try again.";
          break;

        default:
          message = e.message ?? "Network error";
      }

      state = LoginState(
        isLoading: false,
        error: message,
      );

      return false;
    } on SocketException {
      state = const LoginState(
        isLoading: false,
        error: "No internet connection",
      );

      return false;
    } catch (e) {
      state = LoginState(
        isLoading: false,
        error: e.toString(),
      );

      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final repository = ref.read(authRepositoryProvider);

      await repository.logout();

      state = const LoginState();
    } catch (e) {
      state = LoginState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Restores a previous session on launch.
  ///
  /// Returns true when the stored tokens still identify a participant, so the
  /// app can go straight to the dashboard instead of asking to log in again.
  Future<bool> restoreSession() async {
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) return false;

    final repository = ref.read(authRepositoryProvider);

    try {
      final participant = await repository.getCurrentUser();

      if (participant == null) return false;

      state = LoginState(user: participant);

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) return false;

      // Access token expired — spend the refresh token before giving up.
      try {
        await repository.refreshToken();

        final participant = await repository.getCurrentUser();

        if (participant == null) return false;

        state = LoginState(user: participant);

        return true;
      } catch (_) {
        await TokenStorage.clear();
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);

      final participant = await repository.getCurrentUser();

      state = LoginState(
        user: participant,
      );
    } catch (e) {
      state = LoginState(
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      error: null,
    );
  }
}

final loginViewModelProvider =
StateNotifierProvider<LoginViewModel, LoginState>(
      (ref) => LoginViewModel(ref),
);