import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_profile_app/providers/theme_provider.dart';
import 'package:skill_profile_app/screens/splash_screen.dart';
import 'package:skill_profile_app/screens/login_screen.dart';
import 'package:skill_profile_app/screens/register_screen.dart';
import 'package:skill_profile_app/screens/main_screen.dart';
import 'package:skill_profile_app/screens/chat_screen.dart';

void main() {
  runApp(const ProviderScope(child: FeaturesAndFoundApp()));
}

class FeaturesAndFoundApp extends ConsumerWidget {
  const FeaturesAndFoundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Features & Found',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(colorTheme),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
