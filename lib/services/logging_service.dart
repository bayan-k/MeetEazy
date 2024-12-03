import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String tag = 'MeetEazy';
  late final String _logFilePath;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      _logFilePath = '${directory.path}/app_logs.txt';
    }
    _initialized = true;
  }

  void log(String message) {
    _log('INFO', message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  void debug(String message) {
    _log('DEBUG', message);
  }

  void warn(String message) {
    _log('WARN', message);
  }

  void logNetworkRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    final message = '''
Network Request:
Method: $method
URL: $url
Headers: $headers
Body: $body
''';
    _log('NETWORK', message);
  }

  void logNetworkResponse(String method, String url, int statusCode, dynamic body) {
    final message = '''
Network Response:
Method: $method
URL: $url
Status Code: $statusCode
Body: $body
''';
    _log('NETWORK', message);
  }

  void _log(String level, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $level: $message';
    
    if (error != null) {
      final errorMessage = '$logMessage\nError: $error';
      final fullMessage = stackTrace != null 
          ? '$errorMessage\nStackTrace:\n$stackTrace' 
          : errorMessage;
      
      developer.log(fullMessage, name: tag, error: error, stackTrace: stackTrace);
      _writeToFile(fullMessage);
    } else {
      developer.log(logMessage, name: tag);
      _writeToFile(logMessage);
    }

    // Also print to console in debug mode
    if (kDebugMode) {
      print(logMessage);
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace:\n$stackTrace');
    }
  }

  Future<void> _writeToFile(String message) async {
    if (kIsWeb || !_initialized) return;

    try {
      final file = File(_logFilePath);
      await file.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write to log file: $e', name: tag, error: e);
    }
  }

  Future<String> getLogContent() async {
    if (kIsWeb || !_initialized) return '';
    
    try {
      final file = File(_logFilePath);
      if (!await file.exists()) return '';
      return await file.readAsString();
    } catch (e) {
      developer.log('Failed to read log file: $e', name: tag);
      return '';
    }
  }

  Future<void> clearLogs() async {
    if (kIsWeb || !_initialized) return;
    
    try {
      final file = File(_logFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      developer.log('Failed to clear log file: $e', name: tag);
    }
  }
}
