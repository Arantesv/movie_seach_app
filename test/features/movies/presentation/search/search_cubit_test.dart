import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  late FakeMoviesRepository repository;
  setUp(() => repository = FakeMoviesRepository());

  blocTest<SearchCubit, SearchState>(
    'loading to success and parses title/year',
    build: () => SearchCubit(repository),
    act: (cubit) => cubit.search(' Movie (2020) '),
    expect: () => [
      const SearchLoading(),
      SearchSuccess([testMovie]),
    ],
    verify: (_) =>
        expect(repository.queries, [const MovieQuery('Movie', year: '2020')]),
  );

  blocTest<SearchCubit, SearchState>(
    'empty results have a distinct state',
    build: () => SearchCubit(repository..onSearch = (_) async => []),
    act: (cubit) => cubit.search('Unknown'),
    expect: () => [const SearchLoading(), const SearchEmpty()],
  );

  blocTest<SearchCubit, SearchState>(
    'failure is friendly and retry reuses input',
    build: () => SearchCubit(
      repository
        ..onSearch = (_) async =>
            throw const AppFailure(FailureKind.connection),
    ),
    act: (cubit) async {
      await cubit.search('Movie');
      repository.onSearch = (_) async => [testMovie];
      await cubit.retry();
    },
    expect: () => [
      const SearchLoading(),
      SearchFailure(const AppFailure(FailureKind.connection).message),
      const SearchLoading(),
      SearchSuccess([testMovie]),
    ],
    verify: (_) => expect(repository.queries, [
      const MovieQuery('Movie'),
      const MovieQuery('Movie'),
    ]),
  );

  test('older success or failure cannot overwrite a newer response', () async {
    for (final failOld in [false, true]) {
      final old = Completer<List<MovieSummary>>();
      repository.onSearch = (query) =>
          query.title == 'Old' ? old.future : Future.value([testMovie]);
      final cubit = SearchCubit(repository);
      final pending = cubit.search('Old');
      await cubit.search('New');
      if (failOld) {
        old.completeError(const AppFailure(FailureKind.server));
      } else {
        old.complete([]);
      }
      await pending;
      expect(cubit.state, SearchSuccess([testMovie]));
      await cubit.close();
    }
  });

  test(
    'empty input invalidates pending search without a new request',
    () async {
      final pending = Completer<List<MovieSummary>>();
      repository.onSearch = (_) => pending.future;
      final cubit = SearchCubit(repository);
      final request = cubit.search('Old');
      await cubit.search(' (2020) ');
      pending.complete([testMovie]);
      await request;
      expect(cubit.state, const SearchInitial());
      expect(repository.queries, hasLength(1));
      await cubit.close();
    },
  );

  test('completion after closing never emits or throws', () async {
    for (final failRequest in [false, true]) {
      final pending = Completer<List<MovieSummary>>();
      repository.onSearch = (_) => pending.future;
      final cubit = SearchCubit(repository);
      final request = cubit.search('Movie');
      await cubit.close();
      if (failRequest) {
        pending.completeError(Exception('private exception'));
      } else {
        pending.complete([testMovie]);
      }
      await expectLater(request, completes);
      await cubit.search('Ignored');
    }
  });
}
