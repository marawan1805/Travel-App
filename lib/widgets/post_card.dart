import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'dart:io';
import '../models/post.dart';
import '../services/authentication_service.dart';
import 'star_rating.dart';
import 'dart:io';
import '../services/post_service.dart';
import '../services/authentication_service.dart';

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
    return StreamBuilder(
        stream: context.watch<AuthenticationService>().authStateChanges,
        builder: (context, snapshot) {
          bool isAuthorized = snapshot.data != null;
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/post', arguments: widget.post);
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
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        widget.post.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        'Rating: ${widget.post.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isAuthorized
                          ? StarRating(
                              postId: widget.post.id,
                              initialRating: widget.post.rating,
                              onRatingUpdate: (rating) {
                                String userId = context
                                    .read<AuthenticationService>()
                                    .getCurrentUserId();
                                context.read<PostService>().updatePostRating(
                                    widget.post.id, userId, rating);
                              },
                            )
                          : null,
                    ),
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
                    Container(
                      height: 200.0,
                      child: PageView(
                        children: widget.post.images.map((image) {
                          bool isUrl = Uri.parse(image).isAbsolute;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: isUrl
                                ? Image.network(image, fit: BoxFit.cover)
                                : Image.file(File(image), fit: BoxFit.cover),
                          );
                        }).toList(),
                        onPageChanged: (value) {
                          setState(() => currentIndexPage = value.toDouble());
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0, right: 8.0),
                      child: DotsIndicator(
                        dotsCount: pageLength == 0 ? 1 : pageLength,
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
        });
  }
}
