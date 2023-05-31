// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import '../screens/post_detail_screen.dart';
// class NotificationService {
//   late final FirebaseMessaging _messaging;

//   void initialize(BuildContext context) async {
//     _messaging = FirebaseMessaging.instance;
//     await _messaging.requestPermission(
//       alert: true, 
//       announcement: false,
//       badge: true, 
//       carPlay: false, 
//       criticalAlert: false, 
//       provisional: false, 
//       sound: true,
//     );

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       handleNotification(context, message);
//     });
//   }

//   Future<String?> getToken() async {
//     return await _messaging.getToken();
//   }

//   Future<void> handleNotification(BuildContext context, RemoteMessage message) async {
//     // Add your code here to handle what should happen when a user taps on the notification
//     // Typically this involves navigating to a specific page in your app

//     // The following is an example where we assume 'screen' and 'id' are provided in the data
//     var data = message.data;
//     String? screen = data['screen'];
//     String? id = data['id'];

//     if (screen != null && id != null) {
//       if (screen == 'post_details') {
//         // Assuming PostDetailsScreen exists and it requires a post id
//         Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(id: id)));
//       }
//       // Add more navigation cases based on your needs
//     }
//   }
// }
