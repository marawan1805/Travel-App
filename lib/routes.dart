import 'package:flutter/material.dart';

import '../screens/settings_screen.dart';
import './screens/profile_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import './screens/home_screen.dart';
import './screens/post_detail_screen.dart';
import './screens/create_post_screen.dart';
import './models/post.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignupScreen(),
  '/post': (context) => PostDetailScreen(
      post: ModalRoute.of(context)!.settings.arguments as Post),
  '/create': (context) => CreatePostScreen(),
  '/account': (context) => Profile(),
  '/settings':(context) => Settings(),
};
