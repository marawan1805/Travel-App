import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(post.title),
            subtitle: Text('Rating: ${post.rating.toStringAsFixed(1)}'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post.description),
          ),
          // Display images here
          // Navigate to post detail screen on tap
        ],
      ),
    );
  }
}
