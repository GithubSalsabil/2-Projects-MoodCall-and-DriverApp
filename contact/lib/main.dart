import 'package:contact/MyHomePage.dart';
import 'package:contact/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences with error handling
  bool onboarding = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    onboarding = prefs.getBool("onboarding") ?? false;
  } catch (e) {
    print("Error retrieving onboarding status: $e");
  }

  runApp(MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

//home:const splashscreen()