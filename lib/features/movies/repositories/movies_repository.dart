import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';

abstract class MoviesRepository {
  Future<List<MovieSummary>> getCategory(MovieCategory category);
  Future<MovieSearchPage> search(MovieQuery query, {int page = 1});
  Future<MovieDetails> getDetails(int movieId);
  Future<List<CastMember>> getCast(int movieId);
  Future<String?> getTrailer(int movieId);
  Future<List<MovieSummary>> getSimilar(int movieId);
}
