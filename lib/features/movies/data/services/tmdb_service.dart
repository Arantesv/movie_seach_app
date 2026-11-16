import 'package:movie_search_app/core/network/tmdb_client.dart';

class TmdbService {
  const TmdbService(this._client);

  final TmdbClient _client;

  Future<Map<String, dynamic>> category(String endpoint) =>
      _client.get('movie/$endpoint');

  Future<Map<String, dynamic>> search(String title, {String? year}) =>
      _client.get(
        'search/movie',
        parameters: {'query': title, if (year != null) 'year': year},
      );

  Future<Map<String, dynamic>> details(int id, {String? language = 'pt-BR'}) =>
      _client.get(
        'movie/$id',
        language: language,
        parameters: const {'append_to_response': 'credits'},
      );

  Future<Map<String, dynamic>> cast(int id) => _client.get('movie/$id/credits');

  Future<Map<String, dynamic>> videos(int id, {String? language = 'pt-BR'}) =>
      _client.get('movie/$id/videos', language: language);

  Future<Map<String, dynamic>> similar(int id) =>
      _client.get('movie/$id/similar');
}
