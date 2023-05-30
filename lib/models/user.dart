import 'package:flutter/material.dart';
class User {
  final String id;
  final String email;
  final String displayName;
  final String imageURL;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.imageURL = '',
  });
}


