import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eeg/core/utils/date_format.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tar/tar.dart';

void logi(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  _logger.log(
    Level.info,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
  );
}

void logd(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  _logger.log(
    Level.debug,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
  );
}

void loge(
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  _logger.log(
    Level.error,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
  );
}

/// 一个简单的文件日志输出（用于 logger 的 output）
class _FileLogOutput extends LogOutput {
  final IOSink _sink;

  _FileLogOutput(this._sink);

  @override
  void output(OutputEvent event) {
    // OutputEvent.lines 是一行或多行日志，逐行写入文件
    for (var line in event.lines) {
      final msg = '${DateTime.now()} $line';
      print(msg);
      _sink.writeln(msg);
    }
    // 不立刻 flush，IOSink 会自行缓冲并在关闭或需要时写入磁盘
  }
}

late final Logger _logger;

class AppLogger {
  static IOSink? _sink;
  static String? logFilePath;

  /// 初始化 logger，建议在 app 启动时调用
  /// filePrefix 可自定义文件名前缀，默认 'app_log'
  static Future<void> init({String filePrefix = 'app_log'}) async {
    // 若已初始化则直接返回
    if (_sink != null) return;
    // 确保在 Flutter 环境初始化后调用
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final date = DateTime.now();
      final file = File(
          '${await _getLogDir()}/${filePrefix}_${date.yyyy_MM_dd_HH_mm_ss_file}.log');
      // 创建目录(通常已存在)并打开 append 模式的 sink
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      _sink = file.openWrite(mode: FileMode.append);

      // 自定义打印格式（你可以修改 PrettyPrinter 的参数）
      final pretty = PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        // 写入文件时，不需要颜色控制符
        colors: false,
        printEmojis: false,
        // dateTimeFormat: DateTimeFormat.dateAndTime,
      );

      // 使用自定义的文件输出
      _logger = Logger(
        printer: pretty,
        output: _FileLogOutput(_sink!),
      );

      logFilePath = file.path;
      if (kDebugMode) {
        // 在调试模式下，也打印到控制台（可选）
        print('Logger initialized. Log file: $logFilePath');
      }
    } catch (e) {
      // 若初始化失败，回退到控制台 logger，以免抛异常影响启动
      final fallback = Logger();
      fallback.e('Failed to initialize file logger: $e');
      _logger = fallback;
    }
  }

  static Future<String> _getLogDir() async {
    return '${(await getApplicationDocumentsDirectory()).path}/logs';
  }

  /// 关闭底层 sink，确保日志全部写入磁盘
  static Future<void> dispose() async {
    try {
      if (_sink != null) {
        await _sink!.flush();
        await _sink!.close();
        _sink = null;
      }
    } catch (e) {
      // ignore
    }
  }

  static Future<void> uploadLog({
    required String email,
    required String account,
  }) async {
    await _sink?.flush();
    final dateTime = DateTime.now();
    final dir = await getApplicationDocumentsDirectory();
    final tarPath = '${dir.path}/${dateTime.yyyy_MM_dd_HH_mm_ss_file}.tar';
    SmartDialog.showLoading(msg: '正在上传日志...');

    logi('开始组装日志包: $tarPath');
    final tarFile = File(tarPath);
    if (!await tarFile.exists()) {
      await tarFile.create();
    }
    await _tarEntriesFromDirectory(Directory(await _getLogDir()))
        .pipe(tarWritingSink(tarFile.openWrite()));
    logi('开始上传日志↑↑↑: $tarPath');
    final dio = Dio();
    dio.options.baseUrl = 'http://xdfg.cc:8081/api';

    final loginResponse = await dio
        .post('/login', data: {'username': "eeg", 'password': "Mainli0."});
    if (loginResponse.statusCode == 200) {
      final token = loginResponse.data['token'] as String? ?? '';
      if (token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
        logi('获取Token: $token');
        final packageInfo = await PackageInfo.fromPlatform();
        final response = await dio.post(
          '/upload',
          data: FormData.fromMap({
            'logFile': await MultipartFile.fromFile(tarFile.path,
                filename: path.basename('${dateTime.yyyy_MM_dd_HH_mm_ss}.tar')),
            'version': '${packageInfo.version}+${packageInfo.buildNumber}',
            'email': email,
            'account': account,
            'products': 'eeg',
          }),
          options: Options(
            contentType: 'multipart/form-data',
            responseType: ResponseType.plain,
          ),
        );
        final statusCode = response.statusCode ?? 0;
        final respBody = response.data?.toString() ?? '';
        if (statusCode >= 200 && statusCode < 300) {
          logi('上传日志成功: $statusCode body:$respBody');
          try {
            await tarFile.delete();
            logi('已删除本地tar: ${tarFile.path}');
            if (logFilePath != null) {
              _cleanLogDirectory(
                  await _getLogDir(), path.basename(logFilePath!));
            }
          } catch (e, st) {
            loge('删除tar失败: $e', error: e, stackTrace: st);
          }
          '上传日志成功'.toast;
        } else {
          loge('Upload failed: $statusCode body:$respBody');
          '上传日志失败: $statusCode\n$respBody'.toast;
        }
        SmartDialog.dismiss(status: SmartStatus.loading);
        return;
      }
      logi('获取Token失败: $loginResponse');
    }
    SmartDialog.dismiss(status: SmartStatus.loading);
  }

  static Stream<TarEntry> _tarEntriesFromDirectory(Directory base) async* {
    await for (final entity in base.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        final relPath = path.relative(entity.path, from: base.path);
        final header = TarHeader(
          name: relPath.replaceAll('\\', '/'),
          mode: int.parse('644', radix: 8),
          size: bytes.length,
        );
        yield TarEntry.data(header, bytes);
      }
    }
  }

  static Future<void> _cleanLogDirectory(
      String directoryPath, String excludeFileName) async {
    final directory = Directory(directoryPath);
    try {
      if (await directory.exists()) {
        var files = directory.listSync();
        for (var file in files) {
          if (file is File && file.uri.pathSegments.last != excludeFileName) {
            await file.delete();
          }
        }
      } else {}
    } catch (e) {}
  }
}
