// lib/services/payment_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/global/global.dart';

class PaymentService {
  static const String _secretKey = 'your_secret_key';

  static Future<void> makeStripePayment({
    required double totalAmount,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      // Create payment intent
      final paymentIntentData = await _createPaymentIntent(
          amount: (totalAmount * 100).round().toString(),
          currency: 'USD'
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Pamvotis Food Delivery',
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      onSuccess();
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }

  static Future<Map<String, dynamic>> _createPaymentIntent(
      {required String amount, required String currency}
      ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': amount,
          'currency': currency,
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }
}