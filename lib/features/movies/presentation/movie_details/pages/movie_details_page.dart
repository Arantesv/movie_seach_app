import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/app/navigation/app_navigator.dart';
import 'package:movie_search_app/app/navigation/trailer_launcher.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/cubit/movie_details_state.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/general_movie_section.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/async_section.dart';

class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({
    super.key,
    this.trailerLauncher = const TrailerLauncher(),
  });

  final TrailerLauncher trailerLauncher;

  Future<void> _openTrailer(BuildContext context, String key) async {
    final launched = await trailerLauncher.open(key);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o trailer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieDetailsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Filme',
          style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.05),
        ),
      ),
      body: BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
        builder: (context, state) => AsyncSection(
          state: state.details,
          onRetry: cubit.loadDetails,
          builder: (movie) => GeneralMovieSection(
            movie: movie,
            cast: state.cast,
            trailer: state.trailer,
            similar: state.similar,
            onRetryCast: cubit.loadCast,
            onRetryTrailer: cubit.loadTrailer,
            onRetrySimilar: cubit.loadSimilar,
            onTrailerTap: (key) => _openTrailer(context, key),
            onMovieTap: (movie) =>
                AppNavigator.openMovieDetails(context, movie.id),
          ),
        ),
      ),
    );
  }
}
