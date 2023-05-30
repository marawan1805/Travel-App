import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/widgets/image_swapper.dart';

import '../widgets/avatar_button.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/authentication_service.dart';
import '../services/post_service.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService = Provider.of<AuthenticationService>(context, listen: false);
    final User user = authService.getCurrentUser()!;

    return Scaffold(
        appBar: AppBar(
          title: Text(user!.displayName),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: Column(
              children: [
                AvatarButton(
                    onTap: () {
                      changeProfileImage(context, user);
                      setState(() {});
                    },
                    imageURL: user.imageURL),
                Text(user.displayName),
                Text(user.email),
                Text(user.id),
              ],
            ),
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
