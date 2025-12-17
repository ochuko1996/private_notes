import 'package:flutter/material.dart';
import 'package:privatenotes/constant/route.dart';
import 'package:privatenotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Column(
        children: [
          const Text(
            "We've sent you an email verification. Please open it to verify your account",
          ),
          const Text(
            "if you haven't received a verification email yet, press the button below",
          ),
          TextButton(
            onPressed: () async {
              AuthService.firebase().currentUser;
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send Verification Email"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              await Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (_) => false);
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }
}
