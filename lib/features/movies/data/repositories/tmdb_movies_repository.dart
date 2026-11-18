import 'dart:math' as math;

import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/data/mappers/movie_mapper.dart';
import 'package:movie_search_app/features/movies/data/services/tmdb_service.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

class TmdbMoviesRepository implements MoviesRepository {
  const TmdbMoviesRepository(this._service);

  final TmdbService _service;

  @override
  Future<List<MovieSummary>> getCategory(MovieCategory category) =>
      _guard(() async {
        final endpoint = switch (category) {
          MovieCategory.nowPlaying => 'now_playing',
          MovieCategory.topRated => 'top_rated',
          MovieCategory.popular => 'popular',
        };
        return _movies(
          await _service.category(
            endpoint,
            region: category == MovieCategory.nowPlaying ? 'BR' : null,
          ),
        );
      });

  @override
  Future<MovieSearchPage> search(MovieQuery query, {int page = 1}) => _guard(
    () async {
      if (page < 1 || page > 500) throw RangeError.range(page, 1, 500, 'page');
      if (query.title.trim().isEmpty) {
        return MovieSearchPage(movies: const [], page: 1, totalPages: 0);
      }
      final data = await _service.search(
        query.title,
        year: query.year,
        page: page,
      );
      final responsePage = data['page'];
      final totalPages = data['total_pages'];
      final rawMovies = data['results'] as List;
      if (responsePage is! int ||
          responsePage != page ||
          totalPages is! int ||
          totalPages < 0 ||
          (totalPages == 0
              ? page != 1 || rawMovies.isNotEmpty
              : page > totalPages)) {
        throw const AppFailure(FailureKind.invalidData);
      }
      return MovieSearchPage(
        movies: _mapMovies(data, year: query.year),
        page: responsePage,
        // TMDB only exposes pages 1–500, even when total_pages is larger.
        totalPages: math.min(totalPages, 500),
      );
    },
  );

  @override
  Future<MovieDetails> getDetails(int movieId) => _guard(() async {
    final data = await _service.details(movieId);
    if ((data['overview'] as String? ?? '').isEmpty) {
      // An optional translation fallback must not discard valid primary details.
      try {
        final fallback = await _service.details(movieId, language: null);
        data['overview'] = fallback['overview'] as String? ?? '';
      } on AppFailure {
        // Keep the localized details when the fallback request fails.
      }
    }
    return MovieMapper.details(data);
  });

  @override
  Future<List<CastMember>> getCast(int movieId) => _guard(() async {
    final data = await _service.cast(movieId);
    return List.unmodifiable(
      (data['cast'] as List)
          .take(10)
          .map((item) => MovieMapper.cast(item as Map<String, dynamic>)),
    );
  });

  @override
  Future<String?> getTrailer(int movieId) => _guard(() async {
    final localized = _trailer(await _service.videos(movieId));
    if (localized != null) return localized;
    return _trailer(await _service.videos(movieId, language: null));
  });

  @override
  Future<List<MovieSummary>> getSimilar(int movieId) =>
      _guard(() async => _movies(await _service.similar(movieId)));

  List<MovieSummary> _mapMovies(Map<String, dynamic> data, {String? year}) {
    final movies = (data['results'] as List)
        .map((item) => MovieMapper.summary(item as Map<String, dynamic>))
        .where(
          (movie) => year == null || movie.releaseDate?.year.toString() == year,
        )
        .toList();
    return movies;
  }

  List<MovieSummary> _movies(Map<String, dynamic> data) {
    final movies = _mapMovies(data);
    // Categories and similar movies retain their existing ordering.
    movies.sort((a, b) {
      final comparison =
          (b.releaseDate?.millisecondsSinceEpoch ?? -8640000000000000)
              .compareTo(
                a.releaseDate?.millisecondsSinceEpoch ?? -8640000000000000,
              );
      return comparison == 0 ? a.title.compareTo(b.title) : comparison;
    });
    return List.unmodifiable(movies);
  }

  String? _trailer(Map<String, dynamic> data) {
    for (final video in data['results'] as List) {
      if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
        final key = video['key'] as String?;
        if (key != null && key.isNotEmpty) return key;
      }
    }
    return null;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } on FormatException {
      throw const AppFailure(FailureKind.invalidData);
    } on TypeError {
      throw const AppFailure(FailureKind.invalidData);
    }
  }
}
