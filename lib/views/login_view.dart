import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:privatenotes/firebase_options.dart';

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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                        log("User login: ${userCredential.user}");
                      } on FirebaseAuthException catch (e) {
                        log("Error: $e");
                        log(e.code);
                        if (e.code == "invalid-credential") {
                          log("Invalid credentials", name: "login");
                        } else {
                          log("Something went wrong");
                        }
                      }
                    },
                    child: const Text("Login"),
                  ),
                ],
              );
            default:
              return const Center(child: Text("Loading..."));
          }
        },
      ),
    );
  }
}
