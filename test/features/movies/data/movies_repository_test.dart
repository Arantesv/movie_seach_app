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
    'search encodes special characters, filters year and preserves API order',
    () async {
      final repo = repository((request) async {
        expect(request.url.path, '/3/search/movie');
        expect(request.url.queryParameters['query'], 'A & B? São Paulo');
        expect(request.url.queryParameters['year'], '2020');
        expect(request.url.queryParameters['language'], 'pt-BR');
        expect(request.url.queryParameters['page'], '2');
        return json({
          'page': 2,
          'total_pages': 3,
          'results': [
            movie(1, 'Z', '2020-01-01'),
            movie(2, 'Árvore', '2020-12-01'),
            movie(3, 'A', '2020-01-01'),
            movie(4, 'Old', '2019-01-01'),
            movie(5, 'Unknown', null),
          ],
        });
      });
      final result = await repo.search(
        const MovieQuery('A & B? São Paulo', year: '2020'),
        page: 2,
      );
      final movies = result.movies;
      expect(result.page, 2);
      expect(result.totalPages, 3);
      expect(result.hasNextPage, isTrue);
      expect(movies.map((movie) => movie.id), [1, 2, 3]);
      expect(movies.first.title, 'Z');
      expect(movies.first.rating, 8.0);
      expect(() => movies.clear(), throwsUnsupportedError);
    },
  );

  test('empty search never calls HTTP', () async {
    final repo = repository((_) async => fail('Unexpected network request'));
    expect((await repo.search(const MovieQuery(' '))).movies, isEmpty);
  });

  test('search metadata handles empty, last, filtered and maximum accessible pages', () async {
    final cases = [
      {'page': 1, 'total_pages': 0, 'results': <Object>[]},
      {'page': 2, 'total_pages': 2, 'results': <Object>[]},
      {
        'page': 1,
        'total_pages': 3,
        'results': [movie(1, 'Old', '2019-01-01')],
      },
      {'page': 500, 'total_pages': 900, 'results': <Object>[]},
    ];
    for (final data in cases) {
      final repo = repository((_) async => json(data));
      final result = await repo.search(
        const MovieQuery('Movie', year: '2020'),
        page: data['page'] as int,
      );
      expect(result.movies, isEmpty);
      expect(
        result.totalPages,
        (data['total_pages'] as int) > 500 ? 500 : data['total_pages'],
      );
      expect(result.hasNextPage, data['total_pages'] == 3);
    }
  });

  test(
    'search rejects malformed metadata and unexpected response pages',
    () async {
      for (final data in [
        {'results': []},
        {'page': 1, 'total_pages': -1, 'results': []},
        {'page': 1.0, 'total_pages': 1, 'results': []},
        {'page': 2, 'total_pages': 2, 'results': []},
        {'page': 1, 'total_pages': '2', 'results': []},
        {
          'page': 1,
          'total_pages': 0,
          'results': [movie(1, 'Movie', null)],
        },
        {'page': 1, 'total_pages': 1, 'results': {}},
      ]) {
        final repo = repository((_) async => json(data));
        await expectLater(
          repo.search(const MovieQuery('Movie')),
          throwsA(failure(FailureKind.invalidData)),
        );
      }
    },
  );

  test('maps category endpoints and keeps missing dates last', () async {
    final paths = <String>[];
    final repo = repository((request) async {
      paths.add(request.url.path);
      expect(request.url.queryParameters['language'], 'pt-BR');
      expect(
        request.url.queryParameters['region'],
        request.url.path.endsWith('/now_playing') ? 'BR' : isNull,
      );
      return json({
        'results': [movie(1, 'Missing', ''), movie(2, 'Dated', '2020-01-01')],
      });
    });
    for (final category in MovieCategory.values) {
      expect((await repo.getCategory(category)).map((m) => m.id), [2, 1]);
    }
    expect(paths, [
      '/3/movie/now_playing',
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
