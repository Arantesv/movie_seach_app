import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/models/movie_search_page.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchInitial());

  final MoviesRepository _repository;
  int _requestId = 0;
  String _lastInput = '';
  MovieQuery _query = const MovieQuery('');

  /// Identifies the active query for deferred viewport callbacks.
  int get generation => _requestId;

  Future<void> search(String input) async {
    if (isClosed) return;
    _lastInput = input;
    final requestId = ++_requestId;
    final query = MovieQuery.parse(input);
    _query = query;
    if (query.title.isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    try {
      final result = await _repository.search(query);
      if (isClosed || requestId != _requestId) return;
      _emitResult(result, const []);
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(SearchFailure(AppFailure.from(error).message));
    }
  }

  Future<void> retry() => search(_lastInput);

  Future<void> loadNextPage() => _loadNextPage(retry: false);

  Future<void> retryNextPage() => _loadNextPage(retry: true);

  Future<void> _loadNextPage({required bool retry}) async {
    if (isClosed) return;
    final current = state;
    if (current is! SearchSuccess || !current.hasNextPage) return;
    if (retry
        ? current.nextPage is! NextPageFailure
        : current.nextPage is! NextPageIdle) {
      return;
    }
    final requestId = _requestId;
    emit(current.withNextPage(const NextPageLoading()));
    try {
      final result = await _repository.search(_query, page: current.page + 1);
      if (isClosed || requestId != _requestId) return;
      _emitResult(result, current.movies);
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(
        current.withNextPage(NextPageFailure(AppFailure.from(error).message)),
      );
    }
  }

  void _emitResult(MovieSearchPage result, List<MovieSummary> previous) {
    final ids = previous.map((movie) => movie.id).toSet();
    final movies = [
      ...previous,
      ...result.movies.where((movie) => ids.add(movie.id)),
    ];
    emit(
      movies.isEmpty && !result.hasNextPage
          ? const SearchEmpty()
          : SearchSuccess(
              movies,
              page: result.page,
              totalPages: result.totalPages,
            ),
    );
  }
}
