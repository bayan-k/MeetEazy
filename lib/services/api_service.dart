import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logging_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use your computer's local network IP address when running on a physical device or emulator
  final String baseUrl = 'http://10.0.2.2:8000'; // For Android Emulator
  final LoggingService _logger = LoggingService();

  Map<String, String> _getDefaultHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final finalHeaders = {..._getDefaultHeaders(), ...?headers};
      
      _logger.logNetworkRequest('GET', url.toString(), headers: finalHeaders);

      final response = await http.get(url, headers: finalHeaders);
      _logger.logNetworkResponse(
        'GET',
        url.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _logger.error('GET request failed: $endpoint - $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final finalHeaders = {..._getDefaultHeaders(), ...?headers};

      _logger.logNetworkRequest(
        'POST',
        url.toString(),
        headers: finalHeaders,
        body: body,
      );

      final response = await http.post(
        url,
        headers: finalHeaders,
        body: json.encode(body),
      );

      _logger.logNetworkResponse(
        'POST',
        url.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _logger.error('POST request failed: $endpoint - $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final finalHeaders = {..._getDefaultHeaders(), ...?headers};

      _logger.logNetworkRequest(
        'PUT',
        url.toString(),
        headers: finalHeaders,
        body: body,
      );

      final response = await http.put(
        url,
        headers: finalHeaders,
        body: json.encode(body),
      );

      _logger.logNetworkResponse(
        'PUT',
        url.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('Request failed with status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _logger.error('PUT request failed: $endpoint - $e');
      rethrow;
    }
  }

  Future<void> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final finalHeaders = {..._getDefaultHeaders(), ...?headers};

      _logger.logNetworkRequest('DELETE', url.toString(), headers: finalHeaders);

      final response = await http.delete(url, headers: finalHeaders);
      
      _logger.logNetworkResponse(
        'DELETE',
        url.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException('Request failed with status: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      _logger.error('DELETE request failed: $endpoint - $e');
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await get('/api/test-connection/');
      _logger.log('Connection test successful: ${response['message']}');
      return true;
    } catch (e) {
      _logger.error('Connection test failed: $e');
      return false;
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => message;
}
