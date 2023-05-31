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
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);

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

            FutureBuilder<User>(
              future: authService.getCurrentUser(),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                ;
                } else {
                  User? user = snapshot.data;
                  final bool isAuthorized = user != null;
                  return Column(
                    children: [
                      if (!isAuthorized)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('You need to login to comment'),
                        ),
                      if (isAuthorized)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              labelText: 'Add a comment',
                            ),
                          ),
                        ),
                      if (isAuthorized)
                        ElevatedButton(
                          onPressed: () async {
                            String authorId = authService.getCurrentUserId();
                            String authorDispName = user.displayName ?? '';

                            Comment comment = Comment(
                              id: '', // Firestore will auto-generate this
                              postId: post.id,
                              authorId: authorId,
                              content: commentController.text,
                              dateTime: DateTime.now(),
                              authorDisplayName: authorDispName,
                            );
                            if (comment.content.isNotEmpty) {
                              await context
                                  .read<CommentService>()
                                  .addComment(comment);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Comment cannot be empty!'),
                                ),
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Comment submitted!'),
                              ),
                            );
                            commentController.clear();
                          },
                          child: Text('Submit'),
                        ),
                    ],
                  );
                }
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
                  List<Comment> comments = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentCard(comment: comments[index]);
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
