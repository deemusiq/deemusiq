import 'package:dio/dio.dart';

/// Shared Dio for general app traffic. Always carries sane timeouts so a
/// hung host cannot stall callers indefinitely.
final globalDio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
  ),
);
