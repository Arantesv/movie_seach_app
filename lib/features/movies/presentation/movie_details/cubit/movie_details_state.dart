import 'package:equatable/equatable.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';

class MovieDetailsState extends Equatable {
  const MovieDetailsState({
    this.details = const LoadInitial(),
    this.cast = const LoadInitial(),
    this.trailer = const LoadInitial(),
    this.similar = const LoadInitial(),
  });

  final LoadState<MovieDetails> details;
  final LoadState<List<CastMember>> cast;
  final LoadState<String?> trailer;
  final LoadState<List<MovieSummary>> similar;

  MovieDetailsState copyWith({
    LoadState<MovieDetails>? details,
    LoadState<List<CastMember>>? cast,
    LoadState<String?>? trailer,
    LoadState<List<MovieSummary>>? similar,
  }) => MovieDetailsState(
    details: details ?? this.details,
    cast: cast ?? this.cast,
    trailer: trailer ?? this.trailer,
    similar: similar ?? this.similar,
  );

  @override
  List<Object?> get props => [details, cast, trailer, similar];
}
