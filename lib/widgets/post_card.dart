import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'dart:io';
import '../models/post.dart';
import '../services/authentication_service.dart';
import 'star_rating.dart';
import '../services/post_service.dart';
import '../models/user.dart';

class PostCard extends StatefulWidget {
  final Post post;

  PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  double currentIndexPage = 0.0;
  int pageLength = 1;

  @override
  void initState() {
    super.initState();
    currentIndexPage = 0.0;
    pageLength = widget.post.images.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future:
            context.read<AuthenticationService>().getUser(widget.post.authorId),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.done &&
              userSnapshot.hasData) {
            User author = userSnapshot.data!;
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/post', arguments: widget.post);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(author.imageURL),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'User: ${author.displayName}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          StreamBuilder(
                              stream: context
                                  .watch<AuthenticationService>()
                                  .authStateChanges,
                              builder: (context, snapshot) {
                                bool isAuthorized = snapshot.data != null;
                                return isAuthorized
                                    ? StarRating(
                                        postId: widget.post.id,
                                        initialRating: widget.post.rating,
                                        onRatingUpdate: (rating) {
                                          String userId = context
                                              .read<AuthenticationService>()
                                              .getCurrentUserId();
                                          context
                                              .read<PostService>()
                                              .updatePostRating(widget.post.id,
                                                  userId, rating);
                                        },
                                      )
                                    : SizedBox();
                              }),
                          SizedBox(width: 10),
                          Text(
                            'Avg Rating: ${widget.post.rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.post.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.velocity.pixelsPerSecond.dx > 0) {
                            // Swipe Right
                            if (currentIndexPage > 0) {
                              setState(() {
                                currentIndexPage -= 1;
                              });
                            }
                          } else if (details.velocity.pixelsPerSecond.dx < 0) {
                            //Swipe Left
                            if (currentIndexPage < (pageLength - 1)) {
                              setState(() {
                                currentIndexPage += 1;
                              });
                            }
                          }
                        },
                        child: Container(
                          height: 200.0,
                          child: PageView(
                            controller: PageController(
                                initialPage: currentIndexPage.toInt()),
                            children: widget.post.images.map((image) {
                              bool isUrl = Uri.parse(image).isAbsolute;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: isUrl
                                    ? Image.network(image, fit: BoxFit.cover)
                                    : Image.file(File(image),
                                        fit: BoxFit.cover),
                              );
                            }).toList(),
                            onPageChanged: (value) {
                              setState(
                                  () => currentIndexPage = value.toDouble());
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: DotsIndicator(
                          dotsCount: pageLength,
                          position: currentIndexPage,
                          decorator: DotsDecorator(
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        });
  }
}