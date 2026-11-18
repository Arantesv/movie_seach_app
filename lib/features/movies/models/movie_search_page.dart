import 'package:equatable/equatable.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';

class MovieSearchPage extends Equatable {
  MovieSearchPage({
    required List<MovieSummary> movies,
    required this.page,
    required this.totalPages,
  }) : movies = List.unmodifiable(movies);

  final List<MovieSummary> movies;
  final int page;
  final int totalPages;

  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [movies, page, totalPages];
}
