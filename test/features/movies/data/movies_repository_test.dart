import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/core/network/tmdb_client.dart';
import 'package:movie_search_app/features/movies/data/mappers/movie_mapper.dart';
import 'package:movie_search_app/features/movies/data/repositories/tmdb_movies_repository.dart';
import 'package:movie_search_app/features/movies/data/services/tmdb_service.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';

void main() {
  TmdbMoviesRepository repository(
    Future<http.Response> Function(http.Request) handler, {
    Duration timeout = const Duration(seconds: 1),
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return TmdbMoviesRepository(
      TmdbService(
        TmdbClient(client: client, apiKey: 'test-key', timeout: timeout),
      ),
    );
  }

  http.Response json(Object data) => http.Response(
    jsonEncode(data),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  Map<String, dynamic> movie(int id, String title, String? date) => {
    'id': id,
    'title': title,
    'release_date': date,
    'poster_path': null,
    'vote_average': 8,
  };

  Matcher failure(FailureKind kind) =>
      isA<AppFailure>().having((error) => error.kind, 'kind', kind);

  test('parses the existing title/year syntax, including whitespace', () {
    expect(
      MovieQuery.parse('  Harry Potter (2009)  '),
      const MovieQuery('Harry Potter', year: '2009'),
    );
    expect(
      MovieQuery.parse('Movie (extended)'),
      const MovieQuery('Movie (extended)'),
    );
    expect(MovieQuery.parse('  '), const MovieQuery(''));
  });

  test(
    'search encodes special characters, filters year and sorts date then title',
    () async {
      final repo = repository((request) async {
        expect(request.url.path, '/3/search/movie');
        expect(request.url.queryParameters['query'], 'A & B? São Paulo');
        expect(request.url.queryParameters['year'], '2020');
        expect(request.url.queryParameters['language'], 'pt-BR');
        return json({
          'results': [
            movie(1, 'Z', '2020-01-01'),
            movie(2, 'Árvore', '2020-12-01'),
            movie(3, 'A', '2020-01-01'),
            movie(4, 'Old', '2019-01-01'),
            movie(5, 'Unknown', null),
          ],
        });
      });
      final movies = await repo.search(
        const MovieQuery('A & B? São Paulo', year: '2020'),
      );
      expect(movies.map((movie) => movie.id), [2, 3, 1]);
      expect(movies.first.title, 'Árvore');
      expect(movies.first.rating, 8.0);
      expect(() => movies.clear(), throwsUnsupportedError);
    },
  );

  test('empty search never calls HTTP', () async {
    final repo = repository((_) async => fail('Unexpected network request'));
    expect(await repo.search(const MovieQuery(' ')), isEmpty);
  });

  test('maps category endpoints and keeps missing dates last', () async {
    final paths = <String>[];
    final repo = repository((request) async {
      paths.add(request.url.path);
      return json({
        'results': [movie(1, 'Missing', ''), movie(2, 'Dated', '2020-01-01')],
      });
    });
    for (final category in MovieCategory.values) {
      expect((await repo.getCategory(category)).map((m) => m.id), [2, 1]);
    }
    expect(paths, [
      '/3/movie/upcoming',
      '/3/movie/top_rated',
      '/3/movie/popular',
    ]);
  });

  test(
    'summary and details tolerate absent optional data and impossible dates',
    () {
      for (final date in [null, '', '0000-00-00', '2024-02-30', 'not-a-date']) {
        final summary = MovieMapper.summary(movie(1, 'Movie', date));
        expect(summary.releaseDate, isNull);
        expect(summary.posterPath, isEmpty);
      }
      final details = MovieMapper.details({
        ...movie(1, 'Movie', null),
        'overview': null,
        'genres': [
          {'name': 'Drama'},
        ],
        'credits': {
          'crew': [
            {'job': 'Writer', 'name': 'Writer'},
            {'job': 'Director', 'name': 'Director'},
          ],
        },
      });
      expect(details.overview, isEmpty);
      expect(details.directors, ['Director']);
      expect(details.genres, ['Drama']);
      expect(details.runtime, 0);
      expect(() => details.genres.add('Comedy'), throwsUnsupportedError);
    },
  );

  test(
    'falls back to original overview without replacing localized title',
    () async {
      final repo = repository(
        (request) async => json({
          ...movie(
            1,
            request.url.queryParameters.containsKey('language')
                ? 'Local'
                : 'Original',
            null,
          ),
          'overview': request.url.queryParameters.containsKey('language')
              ? ''
              : 'Original overview',
        }),
      );
      final details = await repo.getDetails(1);
      expect(details.title, 'Local');
      expect(details.overview, 'Original overview');
    },
  );

  test('failed overview fallback preserves valid primary details', () async {
    final repo = repository(
      (request) async => request.url.queryParameters.containsKey('language')
          ? json(movie(1, 'Local', null))
          : http.Response('', 503),
    );
    expect((await repo.getDetails(1)).title, 'Local');
  });

  test('cast is limited to ten and missing portraits are supported', () async {
    final repo = repository(
      (_) async => json({
        'cast': List.generate(
          12,
          (index) => {
            'name': 'Actor $index',
            'character': null,
            'profile_path': null,
          },
        ),
      }),
    );
    final cast = await repo.getCast(1);
    expect(cast, hasLength(10));
    expect(cast.first.profilePath, isEmpty);
    expect(cast.first.character, isEmpty);
  });

  test(
    'trailer falls back to default language and ignores non-YouTube videos',
    () async {
      final repo = repository(
        (request) async => json({
          'results': [
            {'type': 'Trailer', 'site': 'Other', 'key': 'wrong'},
            if (!request.url.queryParameters.containsKey('language'))
              {'type': 'Trailer', 'site': 'YouTube', 'key': 'video-id'},
          ],
        }),
      );
      expect(await repo.getTrailer(1), 'video-id');
    },
  );

  test('missing trailer is a valid result', () async {
    final repo = repository((_) async => json({'results': []}));
    expect(await repo.getTrailer(1), isNull);
  });

  test(
    'HTTP errors are translated without exposing response contents',
    () async {
      for (final status in [401, 403, 404, 429, 500]) {
        final repo = repository(
          (_) async => http.Response('private response', status),
        );
        await expectLater(
          repo.getSimilar(1),
          throwsA(
            failure(
              status == 401 || status == 403
                  ? FailureKind.unauthorized
                  : FailureKind.server,
            ),
          ),
        );
      }
    },
  );

  test('connection failure is translated', () async {
    final repo = repository(
      (_) async => throw http.ClientException('private URL'),
    );
    await expectLater(
      repo.getDetails(1),
      throwsA(failure(FailureKind.connection)),
    );
  });

  test('timeouts are translated', () async {
    final pending = Completer<http.Response>();
    final repo = repository(
      (_) => pending.future,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      repo.getSimilar(1),
      throwsA(failure(FailureKind.timeout)),
    );
    pending.complete(json({'results': []}));
  });

  test(
    'invalid JSON, root and required field types become invalid-data failures',
    () async {
      for (final body in [
        'not JSON',
        '[]',
        '{}',
        '{"results":[{"id":"bad"}]}',
      ]) {
        final repo = repository((_) async => http.Response(body, 200));
        await expectLater(
          repo.getSimilar(1),
          throwsA(failure(FailureKind.invalidData)),
        );
      }
    },
  );
}
