import 'package:flutter/material.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/movie_detail_screen.dart';
import 'package:movie_search_app/screens/search/sections/movie_info.dart';
import 'package:movie_search_app/screens/search/widgets/movie_poster.dart';

/// Seção que exibe os filmes resultante da busca do usuário.
///
/// [movie] é o objeto [Movie] que contém as informações do filme.
/// [onTap] é uma função que será executada quando o item for clicado.
class MovieListSection extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieListSection({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap ?? () => _navigateToMovieDetail(context, movie.id),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.006),
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoviePoster(posterPath: movie.posterPath),
            SizedBox(width: screenWidth * 0.04),
            MovieInfo(movie: movie),
          ],
        ),
      ),
    );
  }

  /// Navega para a tela de detalhes do filme com o [movieId] fornecido.
  void _navigateToMovieDetail(BuildContext context, int movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movieId),
      ),
    );
  }
}

