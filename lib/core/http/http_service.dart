import 'package:dio/dio.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();

  factory HttpService() => _instance;

  final Dio _dio = Dio();

  HttpService._internal() {
    // 初始化Dio配置
    _dio.options.baseUrl = 'https://127.0.0.1:8080';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求之前做一些事情
        print('请求: ${options.method} ${options.path}');
        return handler.next(options); // continue
      },
      onResponse: (response, handler) {
        // 处理响应数据
        print('响应: ${response.statusCode} ${response.data}');

        return handler.next(response); // continue
      },
      onError: (DioException e, handler) {
        // 处理错误
        print('错误: ${e.message}');
        return handler.next(e); // continue
      },
    ));
  }

  Future<Response?> _get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      return null;
    }
  }

  Future<Response?> _post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      return null;
    }
  }

  static Future<Response?> get(String path,
          {Map<String, dynamic>? queryParameters}) async =>
      _instance._get(path, queryParameters: queryParameters);

  static Future<Response?> post(String path, {dynamic data}) async =>
      _instance._post(path, data: data);
}
