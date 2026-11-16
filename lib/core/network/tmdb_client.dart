import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movie_search_app/core/errors/app_failure.dart';

class TmdbClient {
  TmdbClient({
    required this.client,
    required this.apiKey,
    this.timeout = const Duration(seconds: 15),
  });

  final http.Client client;
  final String apiKey;
  final Duration timeout;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> parameters = const {},
    String? language = 'pt-BR',
  }) async {
    final uri = Uri.https('api.themoviedb.org', '/3/$path', {
      'api_key': apiKey,
      if (language != null) 'language': language,
      ...parameters,
    });
    try {
      final response = await client.get(uri).timeout(timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AppFailure(FailureKind.unauthorized);
      }
      if (response.statusCode != 200) {
        throw const AppFailure(FailureKind.server);
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) {
        throw const AppFailure(FailureKind.invalidData);
      }
      return data;
    } on TimeoutException {
      throw const AppFailure(FailureKind.timeout);
    } on http.ClientException {
      throw const AppFailure(FailureKind.connection);
    } on FormatException {
      throw const AppFailure(FailureKind.invalidData);
    }
  }
}
