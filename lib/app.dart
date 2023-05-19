import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart' as app_routes;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egypt Tourist App',
      theme: appTheme,
      initialRoute: '/',
      routes: app_routes.routes,
    );
  }
}
