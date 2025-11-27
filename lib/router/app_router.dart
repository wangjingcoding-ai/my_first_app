import 'package:flutter/material.dart';
import 'package:alterego/pages/splash_screen.dart';
import 'package:alterego/pages/login_page.dart';
import 'package:alterego/pages/register_page.dart';
import 'package:alterego/pages/forgot_password_page.dart';
import 'package:alterego/pages/profile_setup_page.dart';
import 'package:alterego/pages/home_page.dart';
import 'package:alterego/pages/welcome_page.dart';
import 'package:alterego/pages/root_tabs.dart';
import 'package:alterego/pages/content_detail_page.dart';
import 'package:alterego/pages/chat_screen.dart';
import 'package:alterego/pages/create_story_screen.dart';

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
    '/chat': (context) => const ChatScreen(),
    '/create-story': (context) => const CreateStoryScreen(),
    };
}