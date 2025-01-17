import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

/// Exception thrown when an error occurs during an API call.
class ApiCallException implements Exception {
  final String message;

  ApiCallException(this.message);

  @override
  String toString() => 'ApiCallException: $message';
}

/// Enum representing the supported HTTP methods for API calls.
enum HttpMethod { get, post, delete }

/// [ApiCall] class provides methods to perform HTTP requests to an API and handle the responses.
class ApiCall {
  /// The host URL of the API.
  // static const host = "http://10.104.9.210:9406";
  // static const host = "http://10.104.12.25:9846";
  static const host = "https://uat.silsaas.co.in:9116";

  /// The base URL of the API.
  static const baseUrl = "$host/optengine/";

  /// Performs an HTTP request to the API and returns the response as an object of type T.
  ///
  /// [path] specifies the path to append to the base URL.
  /// [method] specifies the HTTP method to use for the request.
  /// [body] is the request body, in the form of a map of key-value pairs.
  /// [headers] are the request headers, in the form of a map of key-value pairs.
  /// [queryParameters] are the query parameters to append to the URL, in the form of a map of key-value pairs.
  /// [jsonParser] is a function that takes a JSON string and returns an object of type T.
  /// If provided, this function will be used to parse the JSON response from the server.
  static Future<T> request<T>({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? headers = const {
      'Content-Type': 'application/json',
      'request-id': 'ItJpwb8+bI7M3std+IygAvrWGBBQP5xxRK8ABFt+1+c=',
      'request-key': 'FwIOemhG55dkToVR6EzcAfJRZcWSBFLLXFlJwThIcac=',
    },
    Map<String, String>? queryParameters = const {},
    T Function(String)? jsonParser,
  }) async {
    final url = Uri.parse(baseUrl + path);

    // Log the request details
    log('Request URL: $url', name: 'ApiCall');
    log('Request Method: ${method.toString().split('.').last}',
        name: 'ApiCall');
    if (headers != null)
      log('Request Headers: ${json.encode(headers)}', name: 'ApiCall');
    if (body != null)
      log('Request Body: ${json.encode(body)}', name: 'ApiCall');

    http.Response response;
    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(url, headers: headers);
          break;
        case HttpMethod.post:
          response =
              await http.post(url, headers: headers, body: json.encode(body));
          break;
        case HttpMethod.delete:
          response =
              await http.delete(url, headers: headers, body: json.encode(body));
          break;
      }
    } catch (e) {
      log('Error making API call: $e', name: 'ApiCall');
      throw ApiCallException('Error making API call: $e');
    }

    return _handleResponse<T>(response, jsonParser);
  }

  /// Handles the response from the API and returns the response as an object of type T.
  ///
  /// [response] is the response from the server.
  /// [jsonParser] is a function that takes a JSON string and returns an object of type T.
  /// If provided, this function will be used to parse the JSON response from the server.
  static T _handleResponse<T>(
      http.Response response, T Function(String)? jsonParser) {
    log('API response status code: ${response.statusCode}', name: 'ApiCall');
    log('API response body: ${response.body}', name: 'ApiCall');

    if (response.statusCode == 200) {
      return jsonParser != null
          ? jsonParser(response.body)
          : response.body as T;
    } else {
      throw ApiCallException(
          'Request failed with status code ${response.statusCode}');
    }
  }
}
