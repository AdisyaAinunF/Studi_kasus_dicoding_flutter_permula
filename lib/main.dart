import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studi_kasus/screens/appointments_screen.dart';
import 'package:studi_kasus/screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SehatJiwaBDG());
}

class SehatJiwaBDG extends StatelessWidget {
  const SehatJiwaBDG({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SehatJiwaBDG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (c) => const SplashScreen(),
        '/onboarding': (c) => const OnboardingScreen(),
        '/login': (c) => const LoginScreen(),
        '/register': (c) => const RegisterScreen(),
        '/home': (c) => const HomeScreen(),
        '/detail': (c) => const DetailScreen(),
        '/search': (c) => const SearchScreen(),
        '/gallery': (c) => const GalleryScreen(),
        '/profile': (c) => const ProfileScreen(),
        '/appointments': (c) => const AppointmentsScreen(),
      },
    );
  }
}
