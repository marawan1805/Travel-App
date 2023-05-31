import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String message = await context.read<AuthenticationService>().signUp(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  displayName: displayNameController.text.trim(),
                );
                if (message != "Signed up")
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
              },
              child: Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
