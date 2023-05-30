import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../widgets/comment_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/authentication_service.dart';
import '../models/user.dart';
class PostDetailScreen extends StatelessWidget {
  final Post post;

  PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
final AuthenticationService authService = Provider.of<AuthenticationService>(context, listen: false);

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
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(post.description),
            ),
            // Display images here
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  // ...
                },
              ),
              items: post.images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Image.network(image,
                            fit: BoxFit.cover, width: 1000.0),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            

            StreamBuilder(
              stream: context.watch<AuthenticationService>().authStateChanges,
              builder: (context, snapshot) {
                bool isAuthorized = snapshot.data != null;
                if (!isAuthorized) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('You need to login to comment'),
                  );
                }
                return Column(
                  children: [
                    Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Assuming you have access to the authorId
                String authorId = authService.getCurrentUserId();
                String authorDispName = user?.displayName ?? '';

                Comment comment = Comment(
                  id: '', // Firestore will auto-generate this
                  postId: post.id,
                  authorId: authorId,
                  content: commentController.text,
                  dateTime: DateTime.now(),
                  authorDisplayName: authorDispName,
                );

                await context.read<CommentService>().addComment(comment);

                // Show a snackbar on successful comment submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comment submitted!'),
                  ),
                );

                // Clear the text field
                commentController.clear();
              },
              child: Text('Submit'),
            ),
                  ],
                );
              },
            ),
            StreamBuilder<List<Comment>>(
              stream: context.read<CommentService>().getComments(post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return CommentCard(comment: snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
);
  }
}
