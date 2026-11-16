import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/home/cubit/home_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  test(
    'starts all categories before any response and keeps independent states',
    () async {
      final requests = {
        for (final category in MovieCategory.values)
          category: Completer<List<MovieSummary>>(),
      };
      final repository = FakeMoviesRepository()
        ..onCategory = (category) => requests[category]!.future;
      final cubit = HomeCubit(repository);
      final pending = cubit.load();
      expect(repository.categoryCalls.length, 3);
      expect(
        cubit.state.categories.values,
        everyElement(isA<LoadInProgress<List<MovieSummary>>>()),
      );
      requests[MovieCategory.upcoming]!.complete([testMovie]);
      requests[MovieCategory.topRated]!.completeError(
        const AppFailure(FailureKind.server),
      );
      requests[MovieCategory.popular]!.complete([]);
      await pending;
      expect(
        cubit.state.categories[MovieCategory.upcoming],
        const LoadSuccess([testMovie]),
      );
      expect(
        cubit.state.categories[MovieCategory.topRated],
        isA<LoadFailure<List<MovieSummary>>>(),
      );
      expect(
        cubit.state.categories[MovieCategory.popular],
        const LoadSuccess<List<MovieSummary>>([]),
      );
      await cubit.close();
    },
  );

  test(
    'retry only fetches its category and preserves other successes',
    () async {
      final repository = FakeMoviesRepository()
        ..onCategory = (category) async {
          if (category == MovieCategory.popular) {
            throw const AppFailure(FailureKind.connection);
          }
          return [testMovie];
        };
      final cubit = HomeCubit(repository);
      await cubit.load();
      repository.onCategory = (_) async => [testMovie];
      await cubit.loadCategory(MovieCategory.popular);
      expect(repository.categoryCalls, {
        MovieCategory.upcoming: 1,
        MovieCategory.topRated: 1,
        MovieCategory.popular: 2,
      });
      expect(
        cubit.state.categories.values,
        everyElement(const LoadSuccess([testMovie])),
      );
      await cubit.close();
    },
  );

  test('a stale retry cannot overwrite a newer response', () async {
    final old = Completer<List<MovieSummary>>();
    final repository = FakeMoviesRepository()..onCategory = (_) => old.future;
    final cubit = HomeCubit(repository);
    final pending = cubit.loadCategory(MovieCategory.popular);
    repository.onCategory = (_) async => [testMovie];
    await cubit.loadCategory(MovieCategory.popular);
    old.completeError(const AppFailure(FailureKind.server));
    await pending;
    expect(
      cubit.state.categories[MovieCategory.popular],
      const LoadSuccess([testMovie]),
    );
    await cubit.close();
  });

  test('closing while categories load ignores success and failure', () async {
    final requests = {
      for (final category in MovieCategory.values)
        category: Completer<List<MovieSummary>>(),
    };
    final repository = FakeMoviesRepository()
      ..onCategory = (category) => requests[category]!.future;
    final cubit = HomeCubit(repository);
    final pending = cubit.load();
    await cubit.close();
    requests[MovieCategory.upcoming]!.complete([testMovie]);
    requests[MovieCategory.topRated]!.completeError(Exception('private'));
    requests[MovieCategory.popular]!.complete([]);
    await expectLater(pending, completes);
    await cubit.load();
    expect(repository.categoryCalls.values, everyElement(1));
  });
}
