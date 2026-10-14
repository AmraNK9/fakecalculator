import 'package:dio/dio.dart';

class Api {
  final _dio = Dio();

  Dio get dio => _dio;
  Api() {
    _dio.options.connectTimeout = const Duration(seconds: 4);
    _dio.options.baseUrl = 'https://server-less-sandy.vercel.app';
  }
}
