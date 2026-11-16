import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/pages/search_page.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  testWidgets('manual submit, loading, empty, failure and retry', (
    tester,
  ) async {
    final repository = FakeMoviesRepository();
    final pending = Completer<List<MovieSummary>>();
    repository.onSearch = (_) => pending.future;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SearchCubit(repository),
          child: const SearchPage(),
        ),
      ),
    );
    expect(find.text('Busque um filme pelo título.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Movie');
    await tester.pump();
    expect(repository.queries, isEmpty);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Nenhum filme encontrado.'), findsOneWidget);
    repository.onSearch = (_) async =>
        throw const AppFailure(FailureKind.server);
    await tester.tap(find.byTooltip('Buscar filmes'));
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    repository.onSearch = (_) async => [testMovie];
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Test movie'), findsOneWidget);
    expect(find.text('Ano não informado'), findsOneWidget);
    final count = repository.queries.length;
    await tester.pumpWidget(MaterialApp(home: const SizedBox()));
    await tester.pump();
    expect(repository.queries, hasLength(count));
    expect(tester.takeException(), isNull);
  });
}
