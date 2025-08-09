import 'package:dio/dio.dart';

class AirtelMoneyProvider {
  AirtelMoneyProvider({Dio? dio, required this.baseUrl, required this.clientId, required this.clientSecret}) : _dio = dio ?? Dio();
  final Dio _dio;
  final String baseUrl; // e.g., https://openapi.airtel.africa
  final String clientId;
  final String clientSecret;

  Future<String> initiatePayment({required String reference, required String payerMsisdn, required double amountZMW, required String currency}) async {
    // TODO: Implement Airtel Money Collections API
    return reference;
  }

  Future<String> checkStatus(String transactionId) async {
    // TODO: Query status
    return 'success';
  }
}