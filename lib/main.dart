import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/dashboard_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DiamondCleanApp());
}

class DiamondCleanApp extends StatelessWidget {
  const DiamondCleanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        AuthRemoteDataSourceImpl(FirebaseAuth.instance),
        AuthLocalDataSource(const FlutterSecureStorage()),
      ),
      child: MaterialApp(
        title: 'Diamond Clean — Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => switch (state) {
        AuthAuthenticated() => const DashboardShell(),
        AuthUnauthenticated() || AuthError() => const LoginScreen(),
        AuthLoading() || AuthInitial() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
      },
    );
  }
}
