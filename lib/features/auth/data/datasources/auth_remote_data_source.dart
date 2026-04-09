abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> logout();
  bool get isLoggedIn;
}
