import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(comment.content),
        // Display author's name here
      ),
    );
  }
}
