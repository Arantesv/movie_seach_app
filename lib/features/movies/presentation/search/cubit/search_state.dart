import 'package:equatable/equatable.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  SearchSuccess(
    List<MovieSummary> movies, {
    this.page = 1,
    this.totalPages = 1,
    this.nextPage = const NextPageIdle(),
  }) : movies = List.unmodifiable(movies);

  final List<MovieSummary> movies;
  final int page;
  final int totalPages;
  final NextPageState nextPage;

  bool get hasNextPage => page < totalPages;

  SearchSuccess withNextPage(NextPageState value) => SearchSuccess(
    movies,
    page: page,
    totalPages: totalPages,
    nextPage: value,
  );

  @override
  List<Object?> get props => [movies, page, totalPages, nextPage];
}

sealed class NextPageState extends Equatable {
  const NextPageState();

  @override
  List<Object?> get props => [];
}

final class NextPageIdle extends NextPageState {
  const NextPageIdle();
}

final class NextPageLoading extends NextPageState {
  const NextPageLoading();
}

final class NextPageFailure extends NextPageState {
  const NextPageFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty();
}

final class SearchFailure extends SearchState {
  const SearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
