import 'package:movie_search_app/features/movies/presentation/search/widgets/search_pagination_footer.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/app/app.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/search/pages/search_page.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

import '../../../../support/fake_movies_repository.dart';

void main() {
  List<MovieSummary> movies(int page) => List.generate(
    20,
    (index) => MovieSummary(
      id: (page - 1) * 20 + index,
      title: 'Movie ${(page - 1) * 20 + index}',
    ),
  );
  MovieSearchPage result(int page, {int total = 2, bool empty = false}) =>
      MovieSearchPage(
        movies: empty ? [] : movies(page),
        page: page,
        totalPages: total,
      );

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> submit(WidgetTester tester, [String input = 'Movie']) async {
    await tester.enterText(find.byType(TextField), input);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  ScrollController scroll(WidgetTester tester) =>
      tester.widget<ListView>(find.byType(ListView)).controller!;

  testWidgets(
    'near end loads once; footer retry preserves results and does not auto-loop',
    (tester) async {
      await phone(tester);
      final pending = Completer<MovieSearchPage>();
      final repository = FakeMoviesRepository()
        ..onSearchPage = (_, page) =>
            page == 1 ? Future.value(result(1)) : pending.future;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => SearchCubit(repository),
            child: const SearchPage(),
          ),
        ),
      );
      await submit(tester);
      final controller = scroll(tester);
      controller.jumpTo(controller.position.maxScrollExtent - 200);
      await tester.pump();
      expect(repository.searchPages, [1, 2]);
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byType(SearchPaginationFooter),
        300,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      expect(repository.searchPages, [1, 2]);
      pending.completeError(const AppFailure(FailureKind.connection));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Não foi possível carregar mais filmes.'),
        findsOneWidget,
      );
      expect(
        tester.widget<ListView>(find.byType(ListView)).semanticChildCount,
        21,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(repository.searchPages, [1, 2]);
      repository.onSearchPage = (_, page) async => result(page);
      await Scrollable.ensureVisible(
        tester.element(find.text('Tentar novamente')),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      final offset = controller.offset;
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(repository.searchPages, [1, 2, 2]);
      expect(controller.offset, offset);
      expect(
        tester.widget<ListView>(find.byType(ListView)).semanticChildCount,
        40,
      );
      expect(find.text('Tentar novamente'), findsNothing);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(repository.searchPages, [1, 2, 2]);
    },
  );

  testWidgets('short pages complete the viewport only when the tab is active', (
    tester,
  ) async {
    await phone(tester);
    final repository = FakeMoviesRepository()
      ..onSearchPage = (_, page) async => MovieSearchPage(
        movies: [MovieSummary(id: page, title: 'Movie $page')],
        page: page,
        totalPages: 3,
      );
    final cubit = SearchCubit(repository);
    addTearDown(cubit.close);
    Widget screen(bool active) => MaterialApp(
      home: BlocProvider.value(
        value: cubit,
        child: SearchPage(isActive: active),
      ),
    );
    await tester.pumpWidget(screen(false));
    await cubit.search('Movie');
    await tester.pumpAndSettle();
    expect(repository.searchPages, [1]);
    await tester.pumpWidget(screen(true));
    await tester.pumpAndSettle();
    expect(repository.searchPages, [1, 2, 3]);
    expect(find.text('Movie 3'), findsOneWidget);
  });

  testWidgets('empty filtered pages continue until a definitive empty result', (
    tester,
  ) async {
    await phone(tester);
    final repository = FakeMoviesRepository()
      ..onSearchPage = (_, page) async => result(page, empty: true);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SearchCubit(repository),
          child: const SearchPage(),
        ),
      ),
    );
    await submit(tester, 'Movie (2020)');
    expect(repository.searchPages, [1, 2]);
    expect(find.text('Nenhum filme encontrado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pagination position survives details and tabs; new query resets to top',
    (tester) async {
      await phone(tester);
      final repository = FakeMoviesRepository()
        ..onSearchPage = (_, page) async => result(page);
      await tester.pumpWidget(
        RepositoryProvider<MoviesRepository>.value(
          value: repository,
          child: const MoviesApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      await submit(tester);
      final controller = scroll(tester);
      controller.jumpTo(controller.position.maxScrollExtent - 200);
      await tester.pumpAndSettle();
      expect(repository.searchPages, [1, 2]);
      controller.jumpTo(400);
      await tester.pumpAndSettle();
      final offset = controller.offset;
      final tile = find.text('Movie 2');
      await Scrollable.ensureVisible(tester.element(tile), alignment: 0.5);
      await tester.pumpAndSettle();
      final detailOffset = controller.offset;
      await tester.tap(tile);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(controller.offset, detailOffset);
      expect(repository.searchPages, [1, 2]);
      controller.jumpTo(offset);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(scroll(tester).offset, offset);
      expect(
        tester.widget<ListView>(find.byType(ListView)).semanticChildCount,
        40,
      );
      expect(repository.searchPages, [1, 2]);
      await submit(tester, 'New movie');
      expect(scroll(tester).offset, 0);
      expect(repository.searchPages, [1, 2, 1]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing during pagination and a scheduled check is safe', (
    tester,
  ) async {
    await phone(tester);
    final pending = Completer<MovieSearchPage>();
    final repository = FakeMoviesRepository()
      ..onSearchPage = (_, page) =>
          page == 1 ? Future.value(result(1)) : pending.future;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SearchCubit(repository),
          child: const SearchPage(),
        ),
      ),
    );
    await submit(tester);
    final controller = scroll(tester);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(repository.searchPages, [1, 2]);
    await tester.pumpWidget(const SizedBox());
    pending.complete(result(2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
