import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class NewsApi {
  NewsApi({http.Client? client, String? apiKey})
    : apiKey = apiKey ?? newsApiKey,
      _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final String apiKey;

  Future<Map<String, dynamic>> get(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception(
          'News API key is missing. Please configure it to load news.',
        );
      }
      final response = await _client
          .get(
            Uri.https('newsapi.org', '/v2/$endpoint', parameters),
            headers: {'X-Api-Key': apiKey},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception(
          'News could not be loaded (HTTP ${response.statusCode}).',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'ok' || data['articles'] is! List) {
        throw Exception('News service returned an invalid response.');
      }
      return data;
    } finally {
      if (_ownsClient) _client.close();
    }
  }
}
