import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/app/app.dart';
import 'package:movie_search_app/app/bootstrap.dart';
import 'package:movie_search_app/core/config/app_config.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

import '../support/fake_movies_repository.dart';

void main() {
  Future<void> start(
    WidgetTester tester,
    FakeMoviesRepository repository,
  ) async {
    // A phone viewport catches layout issues hidden by the default wide test view.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepositoryProvider<MoviesRepository>.value(
        value: repository,
        child: const MoviesApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'search survives tabs, details, return and rebuilds without new HTTP',
    (tester) async {
      final repository = FakeMoviesRepository();
      await start(tester, repository);
      expect(find.text('Em Cartaz'), findsOneWidget);
      expect(find.text('Em Breve'), findsNothing);
      expect(repository.categoryCalls.values, everyElement(1));
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Movie (2020)');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Test movie'), findsOneWidget);
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(find.text('Movie (2020)'), findsOneWidget);
      expect(find.text('Test movie'), findsOneWidget);
      expect(repository.categoryCalls.values, everyElement(1));
      expect(repository.queries, hasLength(1));
      await tester.tap(find.text('Test movie'));
      await tester.pumpAndSettle();
      expect(find.text('Detalhes do Filme'), findsOneWidget);
      expect(find.text('Data não informada'), findsOneWidget);
      expect(find.text('Reproduzir trailer'), findsNothing);
      expect(repository.detailCalls, 1);
      expect(repository.castCalls, 1);
      // A metrics change rebuilds the route, but must not reload its data.
      tester.view.physicalSize = const Size(400, 850);
      await tester.pumpAndSettle();
      expect(repository.detailCalls, 1);
      expect(repository.castCalls, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Movie (2020)'), findsOneWidget);
      expect(find.text('Test movie'), findsOneWidget);
      expect(repository.queries, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home retry requests only the failed category', (tester) async {
    final repository = FakeMoviesRepository()
      ..onCategory = (category) async {
        if (category == MovieCategory.nowPlaying) {
          throw const AppFailure(FailureKind.server);
        }
        return [];
      };
    await start(tester, repository);
    expect(find.text('Tentar novamente'), findsOneWidget);
    repository.onCategory = (_) async => [];
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(repository.categoryCalls[MovieCategory.nowPlaying], 2);
    expect(repository.categoryCalls[MovieCategory.popular], 1);
    expect(repository.categoryCalls[MovieCategory.topRated], 1);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets(
    'details loading and failure recover without reloading complementary sections',
    (tester) async {
      final pending = Completer<MovieDetails>();
      final repository = FakeMoviesRepository()
        ..onDetails = (_) => pending.future;
      await start(tester, repository);
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Movie');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test movie'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.completeError(const AppFailure(FailureKind.server));
      await tester.pumpAndSettle();
      expect(find.text('Tentar novamente'), findsOneWidget);
      repository.onDetails = null;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(find.text('Data não informada'), findsOneWidget);
      expect(repository.detailCalls, 2);
      expect(repository.castCalls, 1);
    },
  );

  testWidgets('missing build configuration explains the problem', (
    tester,
  ) async {
    expect(const AppConfig(tmdbApiKey: ' ').isConfigured, isFalse);
    expect(const AppConfig(tmdbApiKey: 'test-key').isConfigured, isTrue);
    await tester.pumpWidget(const ConfigurationErrorApp());
    expect(
      find.text('Configure TMDB_API_KEY para iniciar o aplicativo.'),
      findsOneWidget,
    );
  });
}
