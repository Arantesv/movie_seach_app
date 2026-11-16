import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/models/cast.dart';

/// ServiÃ§o responsÃ¡vel por realizar chamadas Ã  API do The Movie Database (TMDB).
class ApiService {
  final String _apiKey = const String.fromEnvironment('TMDB_API_KEY');
  final String _baseUrl = 'https://api.themoviedb.org/3';

  /// Busca uma lista de filmes com base em uma consulta [query].
  /// Se [year] for fornecido, filtrarÃ¡ os resultados pelo ano.
  Future<List<Movie>> searchMovies(String query, {String? year}) async {
    final uri = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR${year != null ? '&year=$year' : ''}',
    );
    return _fetchMovies(uri, year: year);
  }

  /// ObtÃ©m os detalhes de um filme especÃ­fico pelo seu [id].
  /// Se a sinopse em portuguÃªs estiver ausente, busca a sinopse padrÃ£o.
  /// 
  /// A consulta inclui o parÃ¢metro `append_to_response=credits`, que permite adicionar
  /// informaÃ§Ãµes adicionais Ã  resposta da API em uma Ãºnica solicitaÃ§Ã£o, neste caso, os crÃ©ditos 
  /// do filme (elenco e equipe). Isso evita a necessidade de fazer mÃºltiplas requisiÃ§Ãµes para
  /// obter os diretores do filme.
  Future<Movie> getMovieDetails(int id) async {
    final uriPtBr = Uri.parse(
        '$_baseUrl/movie/$id?api_key=$_apiKey&language=pt-BR&append_to_response=credits');
    final dataPtBr = await _getRequest(uriPtBr);

    if (dataPtBr == null) throw Exception('Erro ao carregar os detalhes do filme');

    if (dataPtBr['overview'] == null || dataPtBr['overview'].isEmpty) {
      final uriNoLang = Uri.parse(
          '$_baseUrl/movie/$id?api_key=$_apiKey&append_to_response=credits');
      final dataNoLang = await _getRequest(uriNoLang);

      if (dataNoLang != null && dataNoLang['overview'] != null && dataNoLang['overview'].isNotEmpty) {
        dataPtBr['overview'] = dataNoLang['overview'];
      }
    }

    final directors = (dataPtBr['credits']?['crew'] as List?)
        ?.where((member) => member['job'] == 'Director')
        .map<String>((director) => director['name'] as String)
        .toList() ?? [];

    return Movie.fromJson(dataPtBr, directors);
  }

  /// ObtÃ©m o elenco principal de um filme pelo seu [movieId].
  /// Retorna uma lista de [Cast] ou lanÃ§a uma exceÃ§Ã£o em caso de erro.
  Future<List<Cast>> getMovieCast(int movieId) async {
    final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=pt-BR');
    final data = await _getRequest(uri);
    return data != null
        ? (data['cast'] as List).map((cast) => Cast.fromJson(cast)).take(10).toList()
        : throw Exception('Erro ao carregar o elenco do filme');
  }

  /// ObtÃ©m o trailer de um filme pelo seu [movieId].
  /// Busca trailers tanto em portuguÃªs quanto em inglÃªs, retornando a primeira chave vÃ¡lida.
  Future<String?> getMovieTrailer(int movieId) async {
    final uris = [
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=pt-BR'),
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    ];

    for (var uri in uris) {
      final data = await _getRequest(uri);
      if (data != null) {
        final trailerKey = _extractTrailerKey(data['results']);
        if (trailerKey != null) return trailerKey;
      }
    }
    return null;
  }

  Future<List<Movie>> fetchUpcomingMovies() async {
    final uri = Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&language=pt-BR');
    return _fetchMovies(uri);
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    final uri = Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=pt-BR');
    return _fetchMovies(uri);
  }

  Future<List<Movie>> fetchPopularMovies() async {
    final uri = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=pt-BR');
    return _fetchMovies(uri);
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=pt-BR');
    return _fetchMovies(uri);
  }

  /// Realiza uma requisiÃ§Ã£o GET para o [uri] fornecido.
  /// Retorna um mapa com os dados da resposta ou `null` em caso de erro.
  Future<Map<String, dynamic>?> _getRequest(Uri uri) async {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  /// Busca e filtra uma lista de filmes a partir de uma [uri].
  /// Se [year] for fornecido, filtra os filmes por ano.
  Future<List<Movie>> _fetchMovies(Uri uri, {String? year}) async {
    final data = await _getRequest(uri);
    if (data == null) throw Exception('Erro ao carregar os filmes');
    final movies = (data['results'] as List)
        .map((movie) => Movie.fromJson(movie, []))
        .toList();

    return _filterAndSortMovies(movies, year);
  }

  /// Filtra e ordena uma lista de [movies] pelo [year] (se fornecido).
  /// Ordena primeiro por data de lanÃ§amento e, em caso de empate, por tÃ­tulo.
  List<Movie> _filterAndSortMovies(List<Movie> movies, String? year) {
    if (year != null) {
      movies = movies.where((movie) => movie.releaseDate.startsWith(year)).toList();
    }
    movies.sort((a, b) {
      final yearComparison = b.releaseDate.compareTo(a.releaseDate);
      return yearComparison != 0 ? yearComparison : a.title.compareTo(b.title);
    });
    return movies;
  }

  /// Extrai a chave do trailer de uma lista de [videos].
  /// Retorna a chave do trailer do YouTube ou `null` se nÃ£o encontrado.
  String? _extractTrailerKey(List<dynamic> videos) {
    return videos
        .firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        )?['key'] as String?;
  }
}
