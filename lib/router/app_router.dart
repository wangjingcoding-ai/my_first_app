import 'package:flutter/material.dart';
import 'package:my_first_app/pages/splash_screen.dart';
import 'package:my_first_app/pages/login_page.dart';
import 'package:my_first_app/pages/register_page.dart';
import 'package:my_first_app/pages/forgot_password_page.dart';
import 'package:my_first_app/pages/profile_setup_page.dart';
import 'package:my_first_app/pages/home_page.dart';
import 'package:my_first_app/pages/welcome_page.dart';
import 'package:my_first_app/pages/root_tabs.dart';
import 'package:my_first_app/pages/content_detail_page.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const RootTabs(),
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/forgot-password': (context) => const ForgotPasswordPage(),
    '/profile-setup': (context) => const ProfileSetupPage(),
    '/welcome': (context) => const WelcomePage(),
    '/home': (context) => const HomePage(),
    '/content': (context) => const ContentDetailPage(),
    };
}