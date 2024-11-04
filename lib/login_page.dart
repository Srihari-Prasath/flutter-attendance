import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_app/principal_dashboard.dart';
import 'package:college_app/staff_dashboard.dart';
import 'package:college_app/student_dashboard.dart';
import 'package:college_app/vice_principal_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hod_dashboard.dart';
import 'home_page.dart';
import 'signup_page.dart'; // Import the SignupPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedRole; // Variable to hold selected role

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Basic input validation
    if (email.isEmpty || password.isEmpty || selectedRole == null) {
      _showError('Please enter both email, password, and select a role.');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

      // Check if the user document exists and contains the role
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Debug log for user data
        print('User Data: $userData');

        // Ensure the user role matches the selected role
        if (userData.containsKey('role')) {
          String role = userData['role'];
          print('Fetched role from Firestore: $role');
          print('Selected role: $selectedRole');

          if (role == selectedRole) {
            // Navigate to the respective dashboard based on the role
            switch (role) {
              case 'Principal':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PrincipalDashboard()));
                break;
              case 'Vice Principal':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VicePrincipalDashboard()));
                break;
              case 'HoD':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HoDDashboard()));
                break;
              case 'Staff':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StaffDashboard()));
                break;
              case 'Student':
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentDashboard()));
                break;
              default:
                _showError('Unknown role: $role');
            }
          } else {
            _showError('User role does not match the selected role.');
          }
        } else {
          _showError('User role not found.');
        }
      } else {
        _showError('User document does not exist.');
      }
    } catch (e) {
      print('Login failed: $e');
      _showError('Login failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: <String>['Principal', 'Vice Principal', 'HoD', 'Staff', 'Student']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue;
                });
              },
              decoration: InputDecoration(labelText: 'Select Role'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Log In'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
