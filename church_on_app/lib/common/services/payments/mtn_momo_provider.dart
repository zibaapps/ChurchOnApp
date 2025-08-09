import 'package:dio/dio.dart';

class MtnMomoProvider {
  MtnMomoProvider({Dio? dio, required this.baseUrl, required this.apiKey, required this.primaryKey}) : _dio = dio ?? Dio();
  final Dio _dio;
  final String baseUrl; // e.g., https://sandbox.momodeveloper.mtn.com
  final String apiKey; // subscription key
  final String primaryKey; // target environment key

  Future<String> initiatePayment({required String reference, required String payerMsisdn, required double amountZMW, required String currency}) async {
    // TODO: Implement MTN MoMo Collections request (v1_0)
    // Return an external reference/transactionId for polling
    // Placeholder: return reference
    return reference;
  }

  Future<String> checkStatus(String transactionId) async {
    // TODO: Call GET status endpoint
    // Return one of: pending | success | failed
    return 'success';
  }
}