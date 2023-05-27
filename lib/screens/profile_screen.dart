import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/authentication_service.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

    User? user = authService.getCurrentUser();
    return Scaffold(
        appBar: AppBar(
          title: Text(user!.displayName),
        ),
        body: Container(
          child: Column(
            children: [
              Text(user.displayName),
              Text(user.email),
              Text(user.id),
            ],
          ),
        ));
  }
}
