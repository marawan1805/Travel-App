import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  String imageURL = "https://kingstonplaza.com/wp-content/uploads/2015/07/generic-avatar.png";

  User({
    required this.id,
    required this.email,
    required this.displayName,
  });
}
