import 'package:privatenotes/services/auth/auth_user.dart';

abstract class CustomAuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logIn({required String email, required String password});

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();
}
