import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final messageStreamController = BehaviorSubject<RemoteMessage>();
