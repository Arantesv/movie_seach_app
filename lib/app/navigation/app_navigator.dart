import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/pages/movie_details_page.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_cubit.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

abstract final class AppNavigator {
  static Future<void> openMovieDetails(BuildContext context, int movieId) {
    final repository = context.read<MoviesRepository>();
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              MovieDetailsCubit(repository, movieId: movieId)..load(),
          child: const MovieDetailsPage(),
        ),
      ),
    );
  }
}
