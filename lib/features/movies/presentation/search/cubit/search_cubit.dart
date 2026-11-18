import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_query.dart';
import 'package:movie_search_app/features/movies/presentation/search/cubit/search_state.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchInitial());

  final MoviesRepository _repository;
  int _requestId = 0;
  String _lastInput = '';

  Future<void> search(String input) async {
    if (isClosed) return;
    _lastInput = input;
    final requestId = ++_requestId;
    final query = MovieQuery.parse(input);
    if (query.title.isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    try {
      final movies = await _repository.search(query);
      if (isClosed || requestId != _requestId) return;
      emit(movies.isEmpty ? const SearchEmpty() : SearchSuccess(movies));
    } catch (error) {
      if (isClosed || requestId != _requestId) return;
      emit(SearchFailure(AppFailure.from(error).message));
    }
  }

  Future<void> retry() => search(_lastInput);
}
