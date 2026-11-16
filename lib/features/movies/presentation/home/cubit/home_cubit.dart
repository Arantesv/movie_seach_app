import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/home/cubit/home_state.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(HomeState());

  final MoviesRepository _repository;
  final _requests = <MovieCategory, int>{};

  Future<void> load() async =>
      Future.wait(MovieCategory.values.map(loadCategory));

  Future<void> loadCategory(MovieCategory category) async {
    if (isClosed) return;
    final request = (_requests[category] ?? 0) + 1;
    _requests[category] = request;
    emit(state.withCategory(category, const LoadInProgress()));
    try {
      final movies = await _repository.getCategory(category);
      if (isClosed || _requests[category] != request) return;
      emit(
        state.withCategory(
          category,
          LoadSuccess(List<MovieSummary>.unmodifiable(movies)),
        ),
      );
    } catch (error) {
      if (isClosed || _requests[category] != request) return;
      emit(
        state.withCategory(
          category,
          LoadFailure(AppFailure.from(error).message),
        ),
      );
    }
  }
}
