import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/authentication_service.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<AuthenticationService>().authStateChanges,
      builder: (context, snapshot) {
        bool isAuthorized = snapshot.data != null;
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
          ),
          body: StreamBuilder<List<Post>>(
            stream: context.read<PostService>().getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: snapshot.data![index]);
                  },
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isAuthorized) {
                // Navigate to create post screen
                Navigator.of(context).pushNamed('/create');
              } else {
                // Show message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('You need to login to create a post'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            child: Icon(Icons.add),
          ),
          drawer: Drawer(
            child: buildMenu(context, isAuthorized: isAuthorized),
          ),
        );
      },
    );
  }

  ListView buildMenu(BuildContext context, {required bool isAuthorized}) {
    if (isAuthorized) {
      return ListView(
        children: <Widget>[
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.of(context).pushNamed('/account');
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          ListTile(
            title: Text('Sign Out'),
            onTap: () async {
              await context.read<AuthenticationService>().signOut();
              // Close the drawer and navigate back to login screen.
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signed out successfuly'),
                  ),
                );
            },
          ),
        ],
      );
    } else {
      // Return an empty ListView, or some other widget.
      return ListView(
        children: <Widget>[
          ListTile(
            title: Text('Sign Up'),
            onTap: () {
              Navigator.of(context).pushNamed('/signup');
            },
          ),
          ListTile(
            title: Text('Login'),
            onTap: () {
              Navigator.of(context).pushNamed('/login');
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      );
    }
  }
}
