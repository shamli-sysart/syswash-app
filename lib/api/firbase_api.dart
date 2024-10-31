import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_sp.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  // Create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notification
  Future<void> initNotifications() async {
    print('<<<<<<<<<<<<<< Requesting Permission >>>>>>>>>>>>>>');
    await _firebaseMessaging.requestPermission();
    print('<<<<<<<<<<<<<< Permission Granted >>>>>>>>>>>>>>');

    // Get the token each time the application loads
    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    if (fCMToken != null) {
      AppSp().setFirebasetoken(fCMToken);
      print('Token saved to local storage');
    } else {
      print('Failed to retrieve FCM token');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}




// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:syswash/main.dart';
//
// import '../utils/app_sp.dart';
// import '../view/screen/notification/notication.dart';
// Future<void>handleBackgroundMessage(RemoteMessage message)async {
//   print('Title:${message.notification?.title}');
//   print('Body:${message.notification?.title}');
//   print('payload:${message.data}');
// }
//
// class FirebaseApi{
//   //create an instance of firebase messaging
//   final _firebaseMessaging = FirebaseMessaging.instance;
//
//
//
//
//   //  function  to initialize notification
//    Future<void> initNotifications()async{
//      await _firebaseMessaging.requestPermission();
//      final fCMToken = await _firebaseMessaging.getToken();
//      print('Token:' + fCMToken.toString());FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//
//
//      AppSp().setFirebasetoken(fCMToken.toString());
//
//      print('saved');
//
//
//
//    }
//
//
// //  function handle  received message
//
// //function to initialized  foreground and background settings
// }