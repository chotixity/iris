import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmsListener {
  static const MethodChannel _channel = MethodChannel('sms_listener');

  // Function to start listening for SMS
  static Future<void> startListening() async {
    try {
      await _channel.invokeMethod('startListening');
    } on PlatformException catch (e) {
      print("Failed to start listening for SMS: '${e.message}'.");
    }
  }

  // Function to set a handler for received SMS
  static void onSmsReceived(Function(Map<String, dynamic>) callback,
      Function(Map<String, dynamic>) dothis) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onSmsReceived') {
        debugPrint('An sms arrived here');
        final message = Map<String, dynamic>.from(call.arguments as Map);
        dothis(message);
        callback(message);
      }
    });
  }
}
