import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/backdrop_image.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/cast_list.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/movie_info_section.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/movie_overview.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/movie_technical_details.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/movie_title_rating.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/similar_movies_list.dart';
import 'package:movie_search_app/features/movies/presentation/movie_details/widgets/trailer_text.dart';
import 'package:movie_search_app/features/movies/presentation/shared/load_state.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/async_section.dart';

class GeneralMovieSection extends StatelessWidget {
  const GeneralMovieSection({
    super.key,
    required this.movie,
    required this.cast,
    required this.trailer,
    required this.similar,
    required this.onRetryCast,
    required this.onRetryTrailer,
    required this.onRetrySimilar,
    required this.onTrailerTap,
    required this.onMovieTap,
  });

  final MovieDetails movie;
  final LoadState<List<CastMember>> cast;
  final LoadState<String?> trailer;
  final LoadState<List<MovieSummary>> similar;
  final VoidCallback onRetryCast;
  final VoidCallback onRetryTrailer;
  final VoidCallback onRetrySimilar;
  final ValueChanged<String> onTrailerTap;
  final ValueChanged<MovieSummary> onMovieTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie.backdropPath.isNotEmpty)
            BackdropImage(imagePath: movie.backdropPath),
          Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieTitleRating(movie: movie),
                SizedBox(height: height * 0.01),
                MovieInfoSection(
                  releaseDate: movie.releaseDate == null
                      ? 'Data não informada'
                      : DateFormat('dd/MM/yyyy').format(movie.releaseDate!),
                  runtime: movie.runtime > 0
                      ? '${movie.runtime ~/ 60}h ${movie.runtime % 60}min'
                      : 'Duração não informada',
                  genres: movie.genres.isEmpty
                      ? 'Gêneros não informados'
                      : movie.genres.join(', '),
                ),
                SizedBox(height: height * 0.007),
                AsyncSection(
                  state: trailer,
                  onRetry: onRetryTrailer,
                  builder: (key) => key == null
                      ? const SizedBox.shrink()
                      : TrailerText(onTap: () => onTrailerTap(key)),
                ),
                SizedBox(height: height * 0.01),
                MovieOverview(
                  overview: movie.overview.isEmpty
                      ? 'Sinopse não disponível.'
                      : movie.overview,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Elenco',
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: width * 0.01),
                AsyncSection(
                  state: cast,
                  onRetry: onRetryCast,
                  builder: (members) => members.isEmpty
                      ? const Text('Elenco não disponível.')
                      : CastList(castList: members),
                ),
                SizedBox(height: height * 0.01),
                MovieTechnicalDetails(movie: movie),
                SizedBox(height: height * 0.01),
                AsyncSection(
                  state: similar,
                  onRetry: onRetrySimilar,
                  builder: (movies) => movies.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filmes Similares',
                              style: TextStyle(
                                fontSize: width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: width * 0.02),
                            SimilarMoviesList(
                              movies: movies,
                              onMovieTap: onMovieTap,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
