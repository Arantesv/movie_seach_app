import 'package:equatable/equatable.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';

class HomeState extends Equatable {
  HomeState({Map<MovieCategory, LoadState<List<MovieSummary>>>? categories})
    : categories = Map.unmodifiable(
        categories ??
            {
              for (final category in MovieCategory.values)
                category: const LoadInitial<List<MovieSummary>>(),
            },
      );

  final Map<MovieCategory, LoadState<List<MovieSummary>>> categories;

  HomeState withCategory(
    MovieCategory category,
    LoadState<List<MovieSummary>> value,
  ) => HomeState(categories: {...categories, category: value});

  @override
  List<Object?> get props => [categories];
}
