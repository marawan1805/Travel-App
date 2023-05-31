import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'routes.dart' as app_routes;
import './services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import './services/authentication_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import './services/comment_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/notifications_screen.dart';

import './screens/profile_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import './screens/home_screen.dart';
import './screens/post_detail_screen.dart';
import './screens/create_post_screen.dart';
import './models/post.dart';
import './screens/edit_profile_screen.dart';
import './screens/my_posts_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/post': (context) => PostDetailScreen(
      post: ModalRoute.of(context)!.settings.arguments as Post),
  '/create': (context) => CreatePostScreen(),
  '/account': (context) => Profile(),
  '/edit-profile': (context) => EditProfile(),
  '/my-posts': (context) => MyPostsScreen(),
'/notifications': (context) => NotificationsScreen(messages: _messageStreamController.stream),

};

var _messageStreamController = BehaviorSubject<RemoteMessage>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  String? token = await messaging.getToken();

  if (kDebugMode) {
    print('Registration Token=$token');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (kDebugMode) {
    print('Handling a foreground message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
    print('Message notification: ${message.notification?.body}');
  }

  _messageStreamController.sink.add(message);
});


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(App());

  const topic = 'comments';
  await messaging.subscribeToTopic(topic);
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('error is ${snapshot.error}');
          return SomethingWentWrong();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider<PostService>(
                create: (_) => PostService(FirebaseFirestore.instance),
              ),
              Provider<AuthenticationService>(
                create: (_) => AuthenticationService(
                    FirebaseAuth.instance, FirebaseFirestore.instance),
              ),
              Provider<CommentService>(
                create: (_) => CommentService(FirebaseFirestore.instance),
              ),
            ],
            child: MaterialApp(
              title: 'Travel App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              initialRoute: '/',
              routes: routes,
              
            ),
          );
        }

        return Loading();
      },
    );
  }
}

class SomethingWentWrong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Something went wrong")),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
