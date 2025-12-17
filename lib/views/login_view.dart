import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:privatenotes/constant/route.dart';
import 'package:privatenotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: "Email"),
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Password"),
            controller: _password,
          ),
          TextButton(
            onPressed: () async {
              // Registration logic goes here
              final email = _email.text;
              final password = _password.text;

              try {
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(notesRoutes, (route) => false);
                log("User login: ${userCredential.user}");
              } on FirebaseAuthException catch (e) {
                log("Error: $e");
                log(e.code);
                if (e.code == "invalid-credential") {
                  log("Invalid credentials", name: "login");
                  await showErrorDialog(
                    context,
                    "Email or password is incorrect",
                  );
                } else if (e.code == "user-disabled") {
                  log("User disabled", name: "login");
                  await showErrorDialog(context, e.message.toString());
                } else {
                  await showErrorDialog(context, "Error: ${e.code}");
                }
              } catch (e) {
                log("Error: $e");
                await showErrorDialog(context, e.toString());
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text("Not registered yet? Register here"),
          ),
        ],
      ),
    );
  }
}
