import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService = Provider.of<AuthenticationService>(context, listen: false);
    final User user = authService.getCurrentUser()!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          _buildAvatar(context, user),
          _buildUserInfo(user),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, User user) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/edit-profile');
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.imageURL),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Name"),
            subtitle: Text(user.displayName),
          ),
          Divider(),
          ListTile(
            title: Text("Email"),
            subtitle: Text(user.email),
          ),
          Divider(),
          ListTile(
            title: Text("User ID"),
            subtitle: Text(user.id),
          ),
          Divider(),
        ],
      ),
    );
  }
}
