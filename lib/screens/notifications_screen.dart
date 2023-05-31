import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  final Stream<RemoteMessage> messages;

  NotificationsScreen({required this.messages});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<RemoteMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    widget.messages.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

@override
Widget build(BuildContext context) {

  final AuthenticationService authService =
      Provider.of<AuthenticationService>(context, listen: false);

  return Scaffold(
    appBar: AppBar(
      title: Text('Notifications'),
    ),
    body: ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        // Only show the notification if the current user ID matches the postAuthorId
        if(authService.getCurrentUserId() != message.notification?.title) {
          return Container();
        }
        return ListTile(
          title: Text(message.notification?.title ?? 'No title'),
          subtitle: Text(message.notification?.body ?? 'No body'),
        );
      },
    ),
  );
}

}
