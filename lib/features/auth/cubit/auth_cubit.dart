import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthCubit(this._remoteDataSource, this._localDataSource)
      : super(const AuthInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_remoteDataSource.isLoggedIn) {
      emit(const AuthAuthenticated());
    } else {
      final credentials = await _localDataSource.loadCredentials();
      emit(AuthUnauthenticated(
        savedEmail: credentials.email,
        savedPassword: credentials.password,
        rememberMe: credentials.rememberMe,
      ));
    }
  }

  Future<void> login(
    String email,
    String password, {
    required bool rememberMe,
  }) async {
    emit(const AuthLoading());
    try {
      await _remoteDataSource.login(email, password);
      if (rememberMe) {
        await _localDataSource.saveCredentials(email, password);
      } else {
        await _localDataSource.clearCredentials();
      }
      emit(const AuthAuthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _localDataSource.clearCredentials();
    emit(const AuthUnauthenticated());
  }

  String _mapFirebaseError(String code) => switch (code) {
    'user-not-found' || 'wrong-password' || 'invalid-credential' =>
      'بريد إلكتروني أو كلمة مرور غير صحيحة',
    'user-disabled' => 'هذا الحساب معطّل',
    'too-many-requests' => 'محاولات كثيرة، حاول لاحقاً',
    _ => 'حدث خطأ، حاول مجدداً',
  };
}
