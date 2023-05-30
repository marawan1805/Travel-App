import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

    return FutureBuilder<User>(
        future: authService.getCurrentUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading spinner while waiting for data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error case
          } else {
            User user = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text("Profile"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  _buildAvatar(context, user),
                  _buildUserInfo(user, context),
                ],
              ),
            );
          }
        });
  }

  Widget _buildAvatar(BuildContext context, User user) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/view-image');
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.imageURL as String),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user, BuildContext context) {
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
           ElevatedButton(onPressed: () {
             Navigator.pushNamed(context, '/my-posts');
           } 
           , child:
            Text("My Posts")
           )
        ],
      ),
    );
  }

  
}
