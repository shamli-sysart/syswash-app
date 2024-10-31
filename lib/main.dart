import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:syswash/api/firbase_api.dart'; // Corrected import statement
import 'package:syswash/firebase_options.dart';
import 'package:syswash/utils/app_route.dart';
import 'package:syswash/view/screen/splash/splash_screen.dart';
import 'package:syswash/view/screen/notification/message.dart';

import 'api/firbase_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Background notification received: ${message.notification!.title}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Notification opened from background: $message");
    if (message.notification != null) {
      print("Notification body: ${message.notification!.body}");
      print("Notification is >>>>>>>> body: ${message}");

      final data = message.data;
      print('<<<<<<<<<<<<<<<<<<<<object>>>>>>>>>>>>>>>>>>>>');
      print(data);
      final type = data['type'];

      print('pickupassign_id: , type: $type');

      if (type == 'Pickup') {
        final pickupassignId = data['pickupassign_id'];
        final pickupCustomerId = data['pickupcustomer_id'];
        navigatorKey.currentState!.pushNamed(
          "/customer_details",
          // arguments: pickupassignId,
          arguments: {
            'pickupassgnId': pickupassignId,
            'pickupCustomerId': pickupCustomerId,
          },
        );
      } else if (type == 'Delivery') {
        final pickupassignId = data['deliveryInvoiceNo'];
        final pickupCustomerId = data['deliverycustomer_id'];
        navigatorKey.currentState!.pushNamed(
            "/customDetailsDelivery",
            arguments: {
              'deliveryInvoiceNo': pickupassignId,
              'deliveryCustomerId': pickupCustomerId,
            }
        );
      } else {
        navigatorKey.currentState!.pushNamed("/message", arguments: message);
      }
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Initialize notifications
  FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: onGenerateRoute,
      initialRoute: '/splash',
      builder: EasyLoading.init(),
      routes: {
        '/splash': (context) => SplashPage(),
        '/message': (context) => Message(),
      },
    );
  }
}


// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:syswash/api/firbase_api.dart';
// import 'package:syswash/firebase_options.dart';
// import 'package:syswash/utils/app_route.dart';
// import 'package:syswash/view/screen/dashboard/home_screen.dart';
// import 'package:syswash/view/screen/notification/message.dart';
// import 'package:syswash/view/screen/notification/notication.dart';
// import 'package:syswash/view/screen/splash/splash_screen.dart';
//
// final navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
//   if (message.notification != null) {
//     print("Background notification received: ${message.notification!.title}");
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print("Background Notification tapped with payload: ${message}");
//     if (message.notification != null) {
//       print("Background Notification tapped: ${message.notification!.body}");
//
//       final data = message.data;
//
//       final type = data['type'];
//      // print('pickupassign_id: $pickupassignId, type: $type');
//
//       if (type == 'Pickup') {
//         final pickupassignId = data['pickupassign_id'];
//         navigatorKey.currentState!.pushNamed(
//           "/customer_details",
//           arguments: pickupassignId,
//         );
//       } else if(type == 'Delivery'){
//         final pickupassignId = data['deliveryInvoiceNo'];
//         navigatorKey.currentState!.pushNamed(
//           "/customDetailsDelivery",
//           arguments: pickupassignId,
//         );
//       } else {
//         navigatorKey.currentState!.pushNamed("/message", arguments: message);
//       }
//
//
//
//
//
//       // navigatorKey.currentState!.pushNamed("/message", arguments: message);
//     }
//   });
//
//   PushNotification.init();
//   PushNotification.localNotiInit();
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
//
//   // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//   //   String payloadData = jsonEncode(message.data);
//   //   print("Got a message in foreground");
//   //   if (message.notification != null) {
//   //     PushNotification.showSimpleNotification(
//   //       title: message.notification!.title!,
//   //       body: message.notification!.body!,
//   //       payload: payloadData,
//   //     );
//   //   }
//   // });
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       onGenerateRoute: onGenerateRoute,
//       initialRoute: '/splash',
//       builder: EasyLoading.init(),
//       routes: {
//         '/splash': (context) => SplashPage(),
//         '/message': (context) => Message(),
//       },
//     );
//   }
// }
