import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

const testMovie = MovieSummary(id: 1, title: 'Test movie');

class FakeMoviesRepository implements MoviesRepository {
  final queries = <MovieQuery>[];
  final searchPages = <int>[];
  Future<MovieSearchPage> Function(MovieQuery, int)? onSearchPage;
  final categoryCalls = <MovieCategory, int>{};
  int detailCalls = 0;
  int castCalls = 0;
  int trailerCalls = 0;
  int similarCalls = 0;

  Future<List<MovieSummary>> Function(MovieQuery)? onSearch;
  Future<List<MovieSummary>> Function(MovieCategory)? onCategory;
  Future<MovieDetails> Function(int)? onDetails;
  Future<List<CastMember>> Function(int)? onCast;
  Future<String?> Function(int)? onTrailer;
  Future<List<MovieSummary>> Function(int)? onSimilar;

  @override
  Future<MovieSearchPage> search(MovieQuery query, {int page = 1}) async {
    queries.add(query);
    searchPages.add(page);
    if (onSearchPage != null) return onSearchPage!(query, page);
    return MovieSearchPage(
      movies: onSearch == null ? [testMovie] : await onSearch!(query),
      page: page,
      totalPages: 1,
    );
  }

  @override
  Future<List<MovieSummary>> getCategory(MovieCategory category) async {
    categoryCalls.update(category, (value) => value + 1, ifAbsent: () => 1);
    return onCategory == null ? [] : await onCategory!(category);
  }

  @override
  Future<MovieDetails> getDetails(int movieId) async {
    detailCalls++;
    return onDetails == null
        ? MovieDetails(
            id: movieId,
            title: 'Test movie',
            overview: 'Overview',
            originalLanguage: 'en',
          )
        : await onDetails!(movieId);
  }

  @override
  Future<List<CastMember>> getCast(int movieId) async {
    castCalls++;
    return onCast == null ? [] : await onCast!(movieId);
  }

  @override
  Future<String?> getTrailer(int movieId) async {
    trailerCalls++;
    return onTrailer == null ? null : await onTrailer!(movieId);
  }

  @override
  Future<List<MovieSummary>> getSimilar(int movieId) async {
    similarCalls++;
    return onSimilar == null ? [] : await onSimilar!(movieId);
  }
}
