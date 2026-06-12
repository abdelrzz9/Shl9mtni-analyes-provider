import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final tokens = await _authRepository.login(email, password);
      emit(AuthAuthenticated(User(
        id: tokens.userId,
        email: email,
        displayName: tokens.displayName,
      )));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(
      String email, String password, String displayName) async {
    emit(const AuthLoading());
    try {
      final tokens =
          await _authRepository.register(email, password, displayName);
      emit(AuthAuthenticated(User(
        id: tokens.userId,
        email: email,
        displayName: tokens.displayName,
      )));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
