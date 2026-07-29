package com.example.silenthelp

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SMS_CHANNEL = "com.example.silenthelp/sms"
    private val SMS_SENT_ACTION = "com.example.silenthelp.SMS_SENT"
    private val SMS_DELIVERED_ACTION = "com.example.silenthelp.SMS_DELIVERED"
    private val SMS_RESULT_TIMEOUT_MS = 15000L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendSms" -> {
                        val phone = call.argument<String>("phone")
                        val message = call.argument<String>("message")

                        if (phone.isNullOrBlank() || message.isNullOrBlank()) {
                            result.error(
                                "INVALID_ARGS",
                                "Both 'phone' and 'message' are required.",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        sendSmsWithDeliveryStatus(phone, message, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun sendSmsWithDeliveryStatus(
        phone: String,
        message: String,
        result: MethodChannel.Result,
    ) {
        val smsManager: SmsManager =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                applicationContext.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

        val parts = smsManager.divideMessage(message)
        val totalParts = parts.size
        val requestIdBase = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()

        val sendStatuses = mutableMapOf<Int, Boolean>()
        val deliveryStatuses = mutableMapOf<Int, Boolean>()
        var resultSent = false

        val mainHandler = Handler(Looper.getMainLooper())
        lateinit var sentReceiver: BroadcastReceiver
        lateinit var deliveredReceiver: BroadcastReceiver

        val cleanUp: () -> Unit = {
            try {
                unregisterReceiver(sentReceiver)
            } catch (_: Exception) {
            }
            try {
                unregisterReceiver(deliveredReceiver)
            } catch (_: Exception) {
            }
            mainHandler.removeCallbacksAndMessages(null)
        }

        val submitResult = lambda@{
            if (resultSent) return@lambda
            resultSent = true

            val sentOk = sendStatuses.size == totalParts && sendStatuses.values.all { it }
            val deliveredOk = deliveryStatuses.size == totalParts && deliveryStatuses.values.all { it }
            val status = when {
                !sentOk -> "failed"
                deliveredOk -> "delivered"
                deliveryStatuses.size == totalParts -> "delivery_failed"
                sendStatuses.size == totalParts -> "sent_waiting_delivery"
                else -> "sent_unknown"
            }

            try {
                result.success(
                    mapOf(
                        "sent" to sentOk,
                        "delivered" to deliveredOk,
                        "status" to status,
                    ),
                )
            } catch (_: Exception) {
            } finally {
                cleanUp()
            }
        }

        sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val partIndex = intent?.getIntExtra("partIndex", -1) ?: -1
                if (partIndex < 0) return
                val success = resultCode == Activity.RESULT_OK
                sendStatuses[partIndex] = success
                if (sendStatuses.size == totalParts && deliveryStatuses.size == totalParts) {
                    submitResult()
                }
            }
        }

        deliveredReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val partIndex = intent?.getIntExtra("partIndex", -1) ?: -1
                if (partIndex < 0) return
                val success = resultCode == Activity.RESULT_OK
                deliveryStatuses[partIndex] = success
                if (sendStatuses.size == totalParts && deliveryStatuses.size == totalParts) {
                    submitResult()
                }
            }
        }

        registerReceiver(sentReceiver, IntentFilter(SMS_SENT_ACTION))
        registerReceiver(deliveredReceiver, IntentFilter(SMS_DELIVERED_ACTION))

        val sendIntents = ArrayList<PendingIntent>(totalParts)
        val deliveryIntents = ArrayList<PendingIntent>(totalParts)

        for (i in 0 until totalParts) {
            val sendIntent = Intent(SMS_SENT_ACTION).apply {
                putExtra("partIndex", i)
            }
            val deliveryIntent = Intent(SMS_DELIVERED_ACTION).apply {
                putExtra("partIndex", i)
            }

            val sendPendingIntent = PendingIntent.getBroadcast(
                this,
                requestIdBase + i,
                sendIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            val deliveryPendingIntent = PendingIntent.getBroadcast(
                this,
                requestIdBase + totalParts + i,
                deliveryIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )

            sendIntents.add(sendPendingIntent)
            deliveryIntents.add(deliveryPendingIntent)
        }

        try {
            if (parts.size == 1) {
                smsManager.sendTextMessage(
                    phone,
                    null,
                    message,
                    sendIntents.first(),
                    deliveryIntents.first(),
                )
            } else {
                smsManager.sendMultipartTextMessage(
                    phone,
                    null,
                    parts,
                    sendIntents,
                    deliveryIntents,
                )
            }
        } catch (e: Exception) {
            cleanUp()
            result.error("SMS_ERROR", e.message ?: "Unknown SMS error", null)
            return
        }

        mainHandler.postDelayed({
            if (!resultSent) {
                submitResult()
            }
        }, SMS_RESULT_TIMEOUT_MS)
    }
}
