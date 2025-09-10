import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../IT/homepage.dart';
import '../ME/homepage.dart';
import '../Manager/homepage.dart';
import '../pages/homepage.dart';
import 'login.dart';

class LandingPage extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasError) {
                return Center(child: Text('Error: ${streamSnapshot.error}'));
              }

              if (streamSnapshot.connectionState == ConnectionState.active) {
                User? _user = streamSnapshot.data;

                if (_user == null) {
                  return LoginPage();
                } else {
                  // Role-based navigation
                  String email = _user.email ?? "";
                  if (email == "megoil@gmail.com") {
                    return HomepageME();
                  } else if (email == "admingoil@gmail.com") {
                    return Homepage();
                  } else if (email == "itgoil@gmail.com") {
                    return Homepage();
                  } else if (email == "managergoil@gmail.com") {
                    return HomepageManager();
                  } else {
                    return Scaffold(
                      body: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
                              const SizedBox(height: 16),
                              Text(
                                "No role assigned for this account.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Please contact the administrator to get access.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 25),
                              ElevatedButton.icon(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                },
                                icon: Icon(Icons.logout, color: Colors.white),
                                label: Text(
                                  'LOG OUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700], // Goil orange
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  elevation: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    );
                  }
                }
              }

              return Scaffold(
                body: Center(child: Text('Checking Authentication...')),
              );
            },
          );
        }

        return Scaffold(
          body: Center(child: Text('Loading...')),
        );
      },
    );
  }
}
