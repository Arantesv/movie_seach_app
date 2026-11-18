import 'package:movie_search_app/core/network/tmdb_client.dart';

class TmdbService {
  const TmdbService(this._client);

  final TmdbClient _client;

  Future<Map<String, dynamic>> category(String endpoint, {String? region}) =>
      _client.get(
        'movie/$endpoint',
        parameters: {if (region != null) 'region': region},
      );

  Future<Map<String, dynamic>> search(
    String title, {
    String? year,
    int page = 1,
  }) => _client.get(
    'search/movie',
    parameters: {
      'query': title,
      'page': page.toString(),
      if (year != null) 'year': year,
    },
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
