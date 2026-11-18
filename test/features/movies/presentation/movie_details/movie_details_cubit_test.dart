import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  test(
    'loads sections in parallel and represents missing trailer as success',
    () async {
      final repository = FakeMoviesRepository();
      final cubit = MovieDetailsCubit(repository, movieId: 1);
      final pending = cubit.load();
      expect(repository.detailCalls, 1);
      expect(repository.castCalls, 1);
      expect(repository.trailerCalls, 1);
      expect(repository.similarCalls, 1);
      expect(cubit.state.details, isA<LoadInProgress<MovieDetails>>());
      await pending;
      expect(cubit.state.details, isA<LoadSuccess<MovieDetails>>());
      expect(cubit.state.cast, const LoadSuccess<List<CastMember>>([]));
      expect(cubit.state.trailer, const LoadSuccess<String?>(null));
      expect(cubit.state.similar, const LoadSuccess<List<MovieSummary>>([]));
      await cubit.close();
    },
  );

  test(
    'complementary failures preserve details and can retry independently',
    () async {
      final repository = FakeMoviesRepository();
      repository.onCast = (_) async =>
          throw const AppFailure(FailureKind.server);
      repository.onTrailer = (_) async =>
          throw const AppFailure(FailureKind.timeout);
      repository.onSimilar = (_) async =>
          throw const AppFailure(FailureKind.connection);
      final cubit = MovieDetailsCubit(repository, movieId: 1);
      await cubit.load();
      final details = cubit.state.details;
      expect(details, isA<LoadSuccess<MovieDetails>>());
      expect(cubit.state.cast, isA<LoadFailure<List<CastMember>>>());
      expect(cubit.state.trailer, isA<LoadFailure<String?>>());
      expect(cubit.state.similar, isA<LoadFailure<List<MovieSummary>>>());
      repository.onCast = (_) async => [const CastMember(name: 'Actor')];
      await cubit.loadCast();
      expect(cubit.state.details, details);
      expect(cubit.state.cast, const LoadSuccess([CastMember(name: 'Actor')]));
      expect(repository.detailCalls, 1);
      expect(repository.castCalls, 2);
      expect(repository.trailerCalls, 1);
      expect(repository.similarCalls, 1);
      repository.onTrailer = (_) async => 'video-id';
      repository.onSimilar = (_) async => [testMovie];
      await Future.wait([cubit.loadTrailer(), cubit.loadSimilar()]);
      expect(cubit.state.trailer, const LoadSuccess<String?>('video-id'));
      expect(cubit.state.similar, const LoadSuccess([testMovie]));
      await cubit.close();
    },
  );

  test('main details retry preserves previously loaded sections', () async {
    final repository = FakeMoviesRepository()
      ..onDetails = (_) async => throw const AppFailure(FailureKind.server);
    final cubit = MovieDetailsCubit(repository, movieId: 1);
    await cubit.load();
    expect(cubit.state.details, isA<LoadFailure<MovieDetails>>());
    repository.onDetails = null;
    await cubit.loadDetails();
    expect(cubit.state.details, isA<LoadSuccess<MovieDetails>>());
    expect(repository.detailCalls, 2);
    expect(repository.castCalls, 1);
    expect(repository.trailerCalls, 1);
    expect(repository.similarCalls, 1);
    await cubit.close();
  });

  test('stale section response cannot replace its newer result', () async {
    final old = Completer<String?>();
    final repository = FakeMoviesRepository()..onTrailer = (_) => old.future;
    final cubit = MovieDetailsCubit(repository, movieId: 1);
    final pending = cubit.loadTrailer();
    repository.onTrailer = (_) async => 'new-video';
    await cubit.loadTrailer();
    old.complete(null);
    await pending;
    expect(cubit.state.trailer, const LoadSuccess<String?>('new-video'));
    await cubit.close();
  });

  test(
    'closing during requests safely ignores late success and failure',
    () async {
      final details = Completer<MovieDetails>();
      final cast = Completer<List<CastMember>>();
      final trailer = Completer<String?>();
      final similar = Completer<List<MovieSummary>>();
      final repository = FakeMoviesRepository();
      repository.onDetails = (_) => details.future;
      repository.onCast = (_) => cast.future;
      repository.onTrailer = (_) => trailer.future;
      repository.onSimilar = (_) => similar.future;
      final cubit = MovieDetailsCubit(repository, movieId: 1);
      final pending = cubit.load();
      await cubit.close();
      details.complete(MovieDetails(id: 1, title: 'Movie'));
      cast.completeError(Exception('private'));
      trailer.complete(null);
      similar.complete([]);
      await expectLater(pending, completes);
      await cubit.load();
      expect(repository.detailCalls, 1);
    },
  );
}
