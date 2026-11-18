import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  MovieSearchPage page(
    int number,
    List<MovieSummary> movies, {
    int total = 3,
  }) => MovieSearchPage(movies: movies, page: number, totalPages: total);
  const second = MovieSummary(id: 2, title: 'Second');

  test(
    'pages append in API order, deduplicate IDs and stop at the end',
    () async {
      final repository = FakeMoviesRepository()
        ..onSearchPage = (_, number) async => number == 1
            ? page(1, [second, second])
            : page(2, [testMovie, second], total: 2);
      final cubit = SearchCubit(repository);
      addTearDown(cubit.close);
      await cubit.search('Movie');
      expect((cubit.state as SearchSuccess).movies, [second]);
      await cubit.loadNextPage();
      final result = cubit.state as SearchSuccess;
      expect(result.movies, [second, testMovie]);
      expect(result.page, 2);
      expect(result.hasNextPage, isFalse);
      expect(() => result.movies.clear(), throwsUnsupportedError);
      await cubit.loadNextPage();
      await cubit.retryNextPage();
      expect(repository.searchPages, [1, 2]);
    },
  );

  test('one pending request, failure preserves movies and retry repeats the same page', () async {
    final pending = Completer<MovieSearchPage>();
    final repository = FakeMoviesRepository()
      ..onSearchPage = (_, number) =>
          number == 1 ? Future.value(page(1, [testMovie])) : pending.future;
    final cubit = SearchCubit(repository);
    addTearDown(cubit.close);
    await cubit.search('Movie (2020)');
    final request = cubit.loadNextPage();
    expect((cubit.state as SearchSuccess).nextPage, const NextPageLoading());
    await cubit.loadNextPage();
    await cubit.retryNextPage();
    expect(repository.searchPages, [1, 2]);
    pending.completeError(const AppFailure(FailureKind.connection));
    await request;
    final failed = cubit.state as SearchSuccess;
    expect(failed.movies, [testMovie]);
    expect(failed.page, 1);
    expect(failed.nextPage, isA<NextPageFailure>());
    await cubit.loadNextPage();
    expect(repository.searchPages, [1, 2]);
    repository.onSearchPage = (_, number) async => page(number, [second]);
    await cubit.retryNextPage();
    expect(repository.searchPages, [1, 2, 2]);
    expect(repository.queries.last.year, '2020');
    expect((cubit.state as SearchSuccess).movies, [testMovie, second]);
  });

  test(
    'empty filtered and duplicate-only pages still advance the page',
    () async {
      final repository = FakeMoviesRepository()
        ..onSearchPage = (_, number) async =>
            page(number, number == 1 ? [] : [testMovie], total: 4);
      final cubit = SearchCubit(repository);
      addTearDown(cubit.close);
      await cubit.search('Movie (2020)');
      expect((cubit.state as SearchSuccess).movies, isEmpty);
      await cubit.loadNextPage();
      await cubit.loadNextPage();
      expect((cubit.state as SearchSuccess).page, 3);
      expect((cubit.state as SearchSuccess).movies, [testMovie]);
      await cubit.loadNextPage();
      expect(repository.searchPages, [1, 2, 3, 4]);
    },
  );

  test(
    'empty state only appears when all pages finish without visible results',
    () async {
      final repository = FakeMoviesRepository()
        ..onSearchPage = (_, number) async => page(number, [], total: 2);
      final cubit = SearchCubit(repository);
      addTearDown(cubit.close);
      await cubit.search('Movie');
      expect(cubit.state, isA<SearchSuccess>());
      await cubit.loadNextPage();
      expect(cubit.state, const SearchEmpty());
    },
  );

  for (final fail in [false, true]) {
    for (final replacement in ['New', '']) {
      test(
        'old pagination ${fail ? 'failure' : 'success'} ignored after query "$replacement"',
        () async {
          final pending = Completer<MovieSearchPage>();
          final repository = FakeMoviesRepository()
            ..onSearchPage = (_, number) => number == 1
                ? Future.value(page(1, [testMovie]))
                : pending.future;
          final cubit = SearchCubit(repository);
          addTearDown(cubit.close);
          await cubit.search('Old');
          final request = cubit.loadNextPage();
          await cubit.search(replacement);
          final expected = cubit.state;
          if (fail) {
            pending.completeError(const AppFailure(FailureKind.server));
          } else {
            pending.complete(page(2, [second]));
          }
          await request;
          expect(cubit.state, expected);
        },
      );
    }
    test(
      'pagination ${fail ? 'failure' : 'success'} after close never emits',
      () async {
        final pending = Completer<MovieSearchPage>();
        final repository = FakeMoviesRepository()
          ..onSearchPage = (_, number) =>
              number == 1 ? Future.value(page(1, [testMovie])) : pending.future;
        final cubit = SearchCubit(repository);
        await cubit.search('Movie');
        final request = cubit.loadNextPage();
        await cubit.close();
        if (fail) {
          pending.completeError(Exception('offline'));
        } else {
          pending.complete(page(2, [second]));
        }
        await expectLater(request, completes);
      },
    );
  }
}
