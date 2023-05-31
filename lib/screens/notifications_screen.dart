import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/post.dart';
import '../screens/post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final Stream<RemoteMessage> messages;

  NotificationsScreen({required this.messages});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthenticationService authService =
        Provider.of<AuthenticationService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final messages = snapshot.data!.docs.map((doc) => doc).toList();

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];

              if(authService.getCurrentUserId() != message['title']) {
                return Container();
              }
              return ListTile(
                title: Text(message['heading'] ?? 'No title'),
                subtitle: Text(message['content'] ?? 'No body'),
                
                  // ...
onTap: () async {
  final docSnapshot = await FirebaseFirestore.instance.collection('posts').doc(message['id']).get();
  if(docSnapshot.exists) {
    final data = docSnapshot.data()!;

    print(data);
    final post = Post(
      id: message['id'] ?? '',
      title: data['title'],
      description: data['description'],
      images: (data['images'] as List)?.cast<String>() ?? [],
      authorId: data['authorId'] ?? '',
      authorDisplayName: data['authorDisplayName'] ?? '',
      rating: data['rating'] ?? 0.0,
      ratings: (data['ratings'] as Map)?.cast<String, double>() ?? {},
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      );
    Navigator.of(context).pushNamed(
      '/post',
      arguments: post,
    );
  }
},
// ...

              );
            },
          );
        },
      ),
    );
  }
}
