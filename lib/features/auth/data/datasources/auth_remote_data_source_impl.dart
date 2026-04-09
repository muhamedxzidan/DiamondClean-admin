import 'package:firebase_auth/firebase_auth.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSourceImpl(this._auth);

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  bool get isLoggedIn => _auth.currentUser != null;
}
