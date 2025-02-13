import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class SendMailHelper {
  const SendMailHelper();

  Future<void> call({
    required String subject,
    required String text,
  }) async {
    try {
      final mailData = {
        'subject': subject,
        'text': text,
      };
      await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('sendEmail')
          .call(mailData);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Failed to send email: ${e.code} - ${e.message}');
      debugPrint('Details: ${e.details}');
      rethrow;
    }
  }
}
