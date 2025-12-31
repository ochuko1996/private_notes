import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privatenotes/constant/route.dart';
import 'package:privatenotes/services/auth/bloc/auth_bloc.dart';
import 'package:privatenotes/services/auth/bloc/auth_event.dart';
import 'package:privatenotes/services/auth/bloc/auth_state.dart';
import 'package:privatenotes/services/auth/firebase_auth_provider.dart';
import 'package:privatenotes/views/login_view.dart';
import 'package:privatenotes/views/notes/create_update_note.dart';
import 'package:privatenotes/views/notes/notes_view.dart';
import 'package:privatenotes/views/register_view.dart';
import 'package:privatenotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Private Notes',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightGreen)),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedin) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
