import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../services/authentication_service.dart';

 class StarRating extends StatelessWidget {
  final String postId;
  final double initialRating;
  final Function(double) onRatingUpdate;

  StarRating({
    required this.postId,
    required this.initialRating,
    required this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        String userId = context.read<AuthenticationService>().getCurrentUserId();
        context.read<PostService>().updatePostRating(postId, userId, rating);
        onRatingUpdate(rating);
      },
    );
  }
}
