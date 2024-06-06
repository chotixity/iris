package com.example.iris

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.provider.Telephony
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_listener"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startListening") {
                startListening()
                result.success("Listening for SMS")
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startListening() {
        val smsReceiver = SmsReceiver(MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL))
        val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
        registerReceiver(smsReceiver, filter)
    }
}

class SmsReceiver(private val channel: MethodChannel) : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        val myMessage = MyMessage()
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            Log.d("receiver", "broadcast fired")
            val bundle = intent.extras
            bundle?.let {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                val fullMessage = StringBuilder()

                for (sms in messages) {
                    fullMessage.append(sms.messageBody)
                    myMessage.originatingAddress = sms.originatingAddress.toString()
                }
                myMessage.body = fullMessage.toString()
                Log.d("receiver", "SMS received from ${myMessage.originatingAddress}: ${myMessage.body}")
                sendMessageToFlutter(myMessage)
            }
        }
    }

    private fun sendMessageToFlutter(myMessage: MyMessage) {
        val messageData = mapOf(
            "originatingAddress" to myMessage.originatingAddress,
            "body" to myMessage.body
        )
        channel.invokeMethod("onSmsReceived", messageData)
    }
}

data class MyMessage(
    var body: String = "",
    var originatingAddress: String = ""
)

