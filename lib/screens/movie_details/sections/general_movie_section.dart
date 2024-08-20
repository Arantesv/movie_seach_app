import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/sections/movie_cast.dart';
import 'package:movie_search_app/screens/movie_details/widgets/movie_title_rating.dart';
import 'package:movie_search_app/screens/movie_details/widgets/trailer_text.dart';
import 'package:movie_search_app/screens/movie_details/widgets/backdrop_image.dart';
import 'package:movie_search_app/screens/movie_details/sections/similar_movies.dart';
import 'package:movie_search_app/screens/movie_details/widgets/movie_overview.dart';
import 'package:movie_search_app/screens/movie_details/sections/movie_info_section.dart';
import 'package:movie_search_app/screens/movie_details/sections/movie_technical_details.dart';

/// Seção geral que organiza os detalhes de um filme.
///
/// O [GeneralMovieSection] combina várias sub-seções para apresentar informações
/// detalhadas sobre um [Movie], como título, avaliação, data de lançamento,
/// duração, trailer, sinopse, elenco, ficha técnica e filmes similares.
class GeneralMovieSection extends StatelessWidget {
  const GeneralMovieSection({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Formata a data de lançamento do filme.
    final releaseDate = DateFormat('dd/MM/yyyy').format(
      DateTime.parse(movie.releaseDate),
    );

    // Calcula a duração do filme em horas e minutos.
    final int hours = movie.runtime ~/ 60;
    final int minutes = movie.runtime % 60;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie.backdropPath.isNotEmpty)
            BackdropImage(imagePath: movie.backdropPath),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieTitleRating(movie: movie),
                SizedBox(height: screenHeight * 0.01),
                MovieInfoSection(
                  releaseDate: releaseDate,
                  runtime: '${hours}h ${minutes}min',
                  genres: movie.genres.join(', '),
                ),
                SizedBox(height: screenHeight * 0.007),
                TrailerText(movieId: movie.id),
                SizedBox(height: screenHeight * 0.01),
                MovieOverview(overview: movie.overview),
                SizedBox(height: screenHeight * 0.01),
                MovieCast(movieId: movie.id),
                SizedBox(height: screenHeight * 0.01),
                MovieTechnicalDetails(movie: movie),
                SizedBox(height: screenHeight * 0.01),
                SimilarMovies(movieId: movie.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}