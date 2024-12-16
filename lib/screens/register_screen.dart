import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login_screen.dart';
import '../db/db_helper.dart';

class RegisterScreen extends StatelessWidget {
  final usernameController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  void login(BuildContext context) async {
    final isRegister = await DBHelper.instance.addUser(
      usernameController.text,
      passwordController.text,
    );

    if (usernameController.text != '' || passwordController.text != '' ) {
      isRegister;
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text('Regis'),
            ),
            

          ],
        ),
      ),
    );
  }
}
