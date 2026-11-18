import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/app/navigation/trailer_launcher.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/pages/movie_details_page.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  testWidgets(
    'optional section error keeps the film visible and retries only cast',
    (tester) async {
      final repository = FakeMoviesRepository()
        ..onCast = (_) async => throw const AppFailure(FailureKind.server);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MovieDetailsCubit(repository, movieId: 1)..load(),
            child: const MovieDetailsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test movie'), findsWidgets);
      expect(find.text('Tentar novamente'), findsOneWidget);
      repository.onCast = (_) async => [];
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Elenco não disponível.'), findsOneWidget);
      expect(repository.castCalls, 2);
      expect(repository.detailCalls, 1);
      expect(repository.trailerCalls, 1);
      expect(repository.similarCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'trailer action reports launcher failure without reloading movie',
    (tester) async {
      final repository = FakeMoviesRepository()
        ..onTrailer = (_) async => 'video';
      final launchedKeys = <String>[];
      final launcher = TrailerLauncher(
        launch: (uri, mode) async {
          launchedKeys.add(uri.queryParameters['v']!);
          return false;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => MovieDetailsCubit(repository, movieId: 1)..load(),
            child: MovieDetailsPage(trailerLauncher: launcher),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Reproduzir trailer'));
      await tester.tap(find.text('Reproduzir trailer'));
      await tester.pumpAndSettle();
      expect(launchedKeys, ['video', 'video']);
      expect(find.text('Não foi possível abrir o trailer.'), findsOneWidget);
      expect(repository.detailCalls, 1);
      expect(repository.trailerCalls, 1);
    },
  );
}
