import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:eeg/core/utils/config.dart';
import 'package:eeg/core/utils/toast.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class HttpService {
  static final HttpService _instance = HttpService._internal();

  factory HttpService() => _instance;
  String? _proxy;
  final Dio _dio = Dio();

  HttpService._internal() {
    if (isDebug) {
      HttpOverrides.global = MyHttpOverrides();
    }
    if (!isWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        HttpClient client = HttpClient();
        if (_proxy != null) {
          client.findProxy = _findProxy;
          client.badCertificateCallback = _badCertificateCallback;
        }
        return client;
      };
    }
    _dio.options.headers['User-Agent'] = 'eeg/1.0.0';
    _dio.options.baseUrl = 'http://eeg.96kg.cn:8888';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (isDebug) {
            print(
                '请求: ${options.method} ${options.path} ${jsonEncode(options.data)}');
          }
          return handler.next(options); // continue
        },
        onResponse: (response, handler) {
          // 处理响应数据
          if (isDebug) {
            print('响应: ${response.statusCode} ${jsonEncode(response.data)}');
          }
          return handler.next(response); // continue
        },
        onError: (DioException e, handler) {
          print('错误: ${e.message}');
          return handler.next(e); // continue
        },
      ),
    );
  }

  void addInterceptors(Interceptor interceptor) {
    _dio.interceptors.insert(0, interceptor);
  }

  void setProxy(String proxy) {
    _proxy = proxy;
  }

  String _findProxy(Uri url) {
    return _proxy?.isNotEmpty == true ? 'PROXY $_proxy' : ''; // 通过代理发送请求
  }

  bool _badCertificateCallback(cert, host, port) {
    return _proxy?.isNotEmpty == true;
  }

  static Future<ResponseData> get(String path,
      {Map<String, dynamic>? queryParameters,
      bool needStateMessage = true,
      Function(DioException error)? onDioError}) async {
    var response =
        await _instance._dio.get(path, queryParameters: queryParameters);
    try {
      var json = response.data;
      if (json != null) {
        return _tryToastByStateAndMessage(
            ResponseData.fromJson(json), needStateMessage);
      }
    } on DioException catch (e) {
      onDioError?.call(e);
    }
    return ResponseData(status: -1);
  }

  static Future<ResponseData> post(String path,
      {dynamic data,
      bool needStateMessage = true,
      Function(DioException error)? onDioError}) async {
    try {
      var response = await _instance._dio.post(path, data: data);
      var json = response.data;
      if (json != null) {
        return _tryToastByStateAndMessage(
            ResponseData.fromJson(json), needStateMessage);
      }
    } on DioException catch (e) {
      onDioError?.call(e);
    }
    return ResponseData(status: -1);
  }

  static Future<Response> downloadFile(String url, String filePath,
      {ProgressCallback? onReceiveProgress}) async {
    return await _instance._dio
        .download(url, filePath, onReceiveProgress: onReceiveProgress);
  }

  static String baseUrl() {
    return _instance._dio.options.baseUrl;
  }

  static Dio dio() {
    return _instance._dio;
  }

  static ResponseData _tryToastByStateAndMessage(ResponseData responseData,
      [bool needStateMessage = true]) {
    if (needStateMessage) {
      if (responseData.status != 0) {
        // 错误码是2，显示提示信息 有云端控制
        if (responseData.status == 2 && responseData.message != null) {
          responseData.message!.showToast();
        }
      }
    }
    return responseData;
  }
}

typedef OnResponseNext = void Function(dynamic data);
typedef ProgressCallback = void Function(int count, int total);

class ResponseData {
  final int? status;
  final String? message;
  final dynamic data;
  final int? logid;

  bool get ok => status == 0;

  ResponseData({this.status, this.message, this.data, this.logid});

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        status: json["status"],
        message: json["message"],
        data: json["data"],
        logid: json["data"]?["logid"] as int?,
      );
}
