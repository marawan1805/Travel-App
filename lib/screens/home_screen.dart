import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/authentication_service.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Call setState to rebuild the widget with the new filtered posts.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<AuthenticationService>().authStateChanges,
      builder: (context, snapshot) {
        bool isAuthorized = snapshot.data != null;
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          body: Column(
            children: [
              _buildCategoryTabs(),
              Expanded(
                child: StreamBuilder<List<Post>>(
                  stream: context.read<PostService>().getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Post> filteredPosts = _filterPosts(snapshot.data);
                      return ListView.builder(
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: filteredPosts[index]);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
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

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _buildCategoryTab('All'),
          _buildCategoryTab('Restaurant'),
          _buildCategoryTab('Beach'),
          _buildCategoryTab('Bar'),
          _buildCategoryTab('Local Market'),
          _buildCategoryTab('Hotel'),
          _buildCategoryTab('Museum'),
          _buildCategoryTab('Park'),
          _buildCategoryTab('Landmark'),
          _buildCategoryTab('Other'),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    bool isSelected = category == selectedCategory;
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(25), // Add this
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  }

  List<Post> _filterPosts(List<Post>? posts) {
    String searchQuery = searchController.text.toLowerCase();

    if (posts == null) {
      return [];
    }

    List<Post> filteredPosts = selectedCategory == 'All'
        ? posts
        : posts.where((post) => post.category == selectedCategory).toList();

    return filteredPosts
        .where((post) =>
            // post.location.toLowerCase().contains(searchQuery) ||
            post.title.toLowerCase().contains(searchQuery) ||
            post.category.toLowerCase().contains(searchQuery))
        .toList();
  }

  Widget buildMenu(BuildContext context, {required bool isAuthorized}) {
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
              // Close the drawer and navigate back to the login screen.
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Signed out successfully'),
                ),
              );
            },
          ),
          FloatingActionButton(
            heroTag: 'notificationsButton', // Assign a unique hero tag
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
            child: Icon(Icons.notifications),
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
