import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure to import Firebase Auth
import 'login_page.dart'; // Ensure you import your login page here

class VicePrincipalDashboard extends StatelessWidget {
  // Logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login page after logging out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('vice principal Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, vice principal!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => logout(context), // Call the logout function
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
