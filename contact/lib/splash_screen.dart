import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Onboarding/onboarding_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Démarrage d'un timer pour rediriger vers la page des contacts après 5 secondes
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingView()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF6A2055), // Couleur de fond spécifiée
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer tout le contenu
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image au centre sans autre élément
              Image.asset(
                'assets/moodcall.png',  // Remplacez par le chemin de votre image dans les assets
                height: 350,  // Ajustez la taille de l'image
                width: 350,
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "Take the right call",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
