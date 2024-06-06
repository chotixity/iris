import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'smsReceiver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SmsListenerWidget(),
    );
  }
}

class SmsListenerWidget extends StatefulWidget {
  const SmsListenerWidget({super.key});

  @override
  _SmsListenerWidgetState createState() => _SmsListenerWidgetState();
}

class _SmsListenerWidgetState extends State<SmsListenerWidget> {
  String _smsMessage = "No SMS received yet";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.sms.request().isGranted) {
      print("SMS permission granted");
      SmsListener.startListening();
      _setupSmsListener();
    } else {
      // Handle the case where the user did not grant the permission
      setState(() {
        _smsMessage = "SMS permission denied";
      });
    }
  }

  void _setupSmsListener() {
    SmsListener.onSmsReceived(
      (Map<String, dynamic> message) {
        debugPrint('Trying to debug');
      },
      (Map<String, dynamic> message) {
        debugPrint('Doing something additional');
        // Additional logic you want to execute
        updateSmsMessage(message);
      },
    );
  }

  void updateSmsMessage(Map<String, dynamic> message) {
    setState(() {
      _smsMessage =
          "From: ${message['originatingAddress']}\nMessage: ${message['body']}";
      print("setState called with: $_smsMessage");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Listener'),
      ),
      body: Center(
        child: Text(_smsMessage),
      ),
    );
  }
}
