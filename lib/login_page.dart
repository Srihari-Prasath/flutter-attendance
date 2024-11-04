import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_app/principal_dashboard.dart';
import 'package:college_app/staff_dashboard.dart';
import 'package:college_app/student_dashboard.dart';
import 'package:college_app/vice_principal_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hod_dashboard.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedRole;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || selectedRole == null) {
      _showError('Please enter both email, password, and select a role.');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('role')) {
          String role = userData['role'];
          if (role == selectedRole) {
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
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/nscet.png',
                        height: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 15),
                      Text('Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Add Forgot Password Functionality
                          },
                          child: Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Color(0xFF3498DB), // New background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.grey[700])),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
