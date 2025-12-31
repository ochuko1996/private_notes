import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privatenotes/constant/route.dart';
import 'package:privatenotes/services/auth/auth_exceptions.dart';
import 'package:privatenotes/services/auth/bloc/auth_bloc.dart';
import 'package:privatenotes/services/auth/bloc/auth_event.dart';
import 'package:privatenotes/utilities/dialogs/error_dialog.dart';

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
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
              } on InvalidCredentialsAuthException {
                await showErrorDialog(
                  context,
                  "Email or password is incorrect",
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Email is invalid");
              } on UserDisabledAuthException {
                await showErrorDialog(context, "This user has been disabled.");
              } on GenericAuthException {
                await showErrorDialog(context, "Authentication error");
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
