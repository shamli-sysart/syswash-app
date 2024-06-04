import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  Map<String, dynamic> payload = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final data = ModalRoute.of(context)!.settings.arguments;
      print('Received data in Message screen: $data');

      if (data is RemoteMessage) {
        setState(() {
          payload = {
            'title': data.notification?.title ?? 'No Title',
            'body': data.notification?.body ?? 'No Body',
            ...data.data, // Include any additional data
          };
        });
      } else if (data is NotificationResponse) {
        setState(() {
          payload = jsonDecode(data.payload!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your message")),
      body: Center(
        child: payload.isNotEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Title: ${payload['title'] ?? 'No Title'}'),
            Text('Body: ${payload['body'] ?? 'No Body'}'),
            Text('Data: ${payload.toString()}'),
          ],
        )
            : Text("No data"),
      ),
    );
  }
}
