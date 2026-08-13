import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';

class PasswordState {
  final bool isLoading;
  final String? error;

  /// Held between the two steps; never shown to the participant.
  final String? resetToken;

  final bool isReset;

  const PasswordState({
    this.isLoading = false,
    this.error,
    this.resetToken,
    this.isReset = false,
  });

  bool get hasToken => resetToken != null && resetToken!.isNotEmpty;

  PasswordState copyWith({
    bool? isLoading,
    String? error,
    String? resetToken,
    bool? isReset,
  }) {
    return PasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      resetToken: resetToken ?? this.resetToken,
      isReset: isReset ?? this.isReset,
    );
  }
}

class PasswordViewModel extends StateNotifier<PasswordState> {
  final Ref ref;

  PasswordViewModel(this.ref) : super(const PasswordState());

  Future<bool> requestReset(String username) async {
    if (username.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter your username');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await ref
          .read(passwordRepositoryProvider)
          .requestReset(username.trim());

      state = state.copyWith(isLoading: false, resetToken: token);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
      return false;
    }
  }

  Future<bool> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 6) {
      state = state.copyWith(
        error: 'Password must be at least 6 characters',
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      state = state.copyWith(error: 'Passwords do not match');
      return false;
    }

    if (!state.hasToken) {
      state = state.copyWith(error: 'Please start again');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(passwordRepositoryProvider).resetPassword(
            resetToken: state.resetToken!,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );

      state = const PasswordState(isReset: true);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFor(e));
      return false;
    }
  }

  void reset() => state = const PasswordState();

  String _messageFor(Object e) {
    if (e is DioException) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : null;

      switch (e.response?.statusCode) {
        case 400:
          return detail ?? 'Please check the details you entered.';
        case 401:
          return 'This reset link has expired. Please start again.';
        case 404:
          return detail ?? 'No account found with that username.';
        case 500:
          return 'Server error. Please try again.';
        default:
          return e.message ?? 'Something went wrong';
      }
    }

    if (e is SocketException) return 'No internet connection';

    return e.toString();
  }
}

final passwordViewModelProvider =
    StateNotifierProvider<PasswordViewModel, PasswordState>(
  (ref) => PasswordViewModel(ref),
);
