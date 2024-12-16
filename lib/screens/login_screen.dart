import 'package:flutter/material.dart';
import 'package:flutter_app/screens/register_screen.dart';
import '../db/db_helper.dart';

class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) async {
    final isLoggedIn = await DBHelper.instance.login(
      usernameController.text,
      passwordController.text,
    );

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => {
Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()))
              } ,
              child: Text('Register'),
            )

          ],
        ),
      ),
    );
  }
}
