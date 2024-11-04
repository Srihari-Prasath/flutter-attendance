import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'login_page.dart'; // Import your login page here

class StaffDashboard extends StatefulWidget {
  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> attendanceStatus = ['Present', 'Absent'];
  Map<String, String> attendanceRecords = {}; // to hold attendance records

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
      appBar: AppBar(
        title: Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context), // Call the logout function
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Mark Attendance', style: TextStyle(fontSize: 24)),
            Expanded(child: _buildStudentList()),
            ElevatedButton(
              onPressed: _submitAttendance,
              child: Text('Submit Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            var student = students[index];
            var studentId = student.id;

            return ListTile(
              title: Text(student['name']),
              trailing: DropdownButton<String>(
                value: attendanceRecords[studentId],
                hint: Text('Select'),
                items: attendanceStatus.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    attendanceRecords[studentId] = newValue!;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitAttendance() async {
    DateTime now = DateTime.now();
    String date = "${now.year}-${now.month}-${now.day}";

    // Loop through attendance records and save to Firestore
    for (var entry in attendanceRecords.entries) {
      String studentId = entry.key;
      String status = entry.value;

      await _firestore.collection('students')
          .doc(studentId)
          .collection('attendance')
          .doc(date)
          .set({'status': status});
    }

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance marked successfully!')),
    );

    // Clear attendance records after submission
    setState(() {
      attendanceRecords.clear();
    });
  }
}
