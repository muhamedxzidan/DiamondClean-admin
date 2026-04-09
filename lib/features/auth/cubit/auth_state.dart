sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

final class AuthUnauthenticated extends AuthState {
  final String savedEmail;
  final String savedPassword;
  final bool rememberMe;

  const AuthUnauthenticated({
    this.savedEmail = '',
    this.savedPassword = '',
    this.rememberMe = false,
  });
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
