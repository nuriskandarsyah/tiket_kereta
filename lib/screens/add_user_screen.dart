import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super (key: key);

  @override
  _AddUserScreen createState() => _AddUserScreen();
}

class _AddUserScreen extends State<AddUserScreen> {
  final usernameController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  bool _isPasswordVisible = false;

  void addUser() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and Password cannot be empty')),
      );
      return;
    }
    
    await DBHelper.instance.addUser(
      usernameController.text,
      passwordController.text,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addUser,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}