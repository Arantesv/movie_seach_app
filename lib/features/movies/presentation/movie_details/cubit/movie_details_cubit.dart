import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/core/errors/app_failure.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_state.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit(this._repository, {required this.movieId})
    : super(const MovieDetailsState());

  final MoviesRepository _repository;
  final int movieId;
  final _requests = <String, int>{};

  Future<void> load() async =>
      Future.wait([loadDetails(), loadCast(), loadTrailer(), loadSimilar()]);

  Future<void> loadDetails() => _load(
    'details',
    () => _repository.getDetails(movieId),
    (value) => state.copyWith(details: value),
  );

  Future<void> loadCast() => _load(
    'cast',
    () async =>
        List<CastMember>.unmodifiable(await _repository.getCast(movieId)),
    (value) => state.copyWith(cast: value),
  );

  Future<void> loadTrailer() => _load(
    'trailer',
    () => _repository.getTrailer(movieId),
    (value) => state.copyWith(trailer: value),
  );

  Future<void> loadSimilar() => _load(
    'similar',
    () async =>
        List<MovieSummary>.unmodifiable(await _repository.getSimilar(movieId)),
    (value) => state.copyWith(similar: value),
  );

  Future<void> _load<T>(
    String section,
    Future<T> Function() fetch,
    MovieDetailsState Function(LoadState<T>) update,
  ) async {
    if (isClosed) return;
    final request = (_requests[section] ?? 0) + 1;
    _requests[section] = request;
    emit(update(LoadInProgress<T>()));
    try {
      final data = await fetch();
      if (isClosed || _requests[section] != request) return;
      emit(update(LoadSuccess(data)));
    } catch (error) {
      if (isClosed || _requests[section] != request) return;
      emit(update(LoadFailure(AppFailure.from(error).message)));
    }
  }
}
