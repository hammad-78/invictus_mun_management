import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'viewmodels/attendance_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/delegate_viewmodel.dart';
import 'viewmodels/team_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DelegateViewModel()),
        ChangeNotifierProvider(create: (_) => TeamViewModel()),
        ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          _stopAppData(context);
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: auth.isCurrentUserAdmin(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (adminSnapshot.data == true) {
              _startAppData(context);
              return const DashboardScreen();
            }

            _logoutRejectedUser(context);
            return const LoginScreen();
          },
        );
      },
    );
  }

  void _startAppData(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<DelegateViewModel>().startListening();
      context.read<TeamViewModel>().startListening();
      context.read<AttendanceViewModel>().startListening();
      context.read<DashboardViewModel>().startListening();
    });
  }

  void _stopAppData(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<DelegateViewModel>().stopListening();
      context.read<TeamViewModel>().stopListening();
      context.read<AttendanceViewModel>().stopListening();
      context.read<DashboardViewModel>().stopListening();
    });
  }

  void _logoutRejectedUser(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _stopAppData(context);
      context.read<AuthViewModel>().logout();
    });
  }
}
