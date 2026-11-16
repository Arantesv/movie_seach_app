import 'package:movie_search_app/features/movies/presentation/shared/widgets/tmdb_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';

/// Exibe uma lista horizontal de filmes similares.
///
/// O [SimilarMoviesList] recebe uma lista de objetos [MovieSummary] e exibe cada filme
/// em um item de lista utilizando o widget [SimilarMovieItem]. Apenas filmes
/// com um caminho de pôster válido são exibidos.
class SimilarMoviesList extends StatelessWidget {
  const SimilarMoviesList({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  final List<MovieSummary> movies;
  final ValueChanged<MovieSummary> onMovieTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: screenWidth * 0.04,
        children: movies
            .where((movie) => movie.posterPath.isNotEmpty)
            .map(
              (movie) => SimilarMovieItem(
                movie: movie,
                onTap: () => onMovieTap(movie),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Representa um único filme similar na lista.
///
/// O [SimilarMovieItem] exibe o pôster e o título do filme utilizando [ClipRRect], e permite a navegação
/// para a tela de detalhes do filme de detalhes ao ser tocado.
class SimilarMovieItem extends StatelessWidget {
  const SimilarMovieItem({super.key, required this.movie, required this.onTap});

  final MovieSummary movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: TmdbImage(
              path: movie.posterPath,
              width: screenWidth * 0.25,
              height: screenWidth * 0.375,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          SizedBox(
            width: screenWidth * 0.25,
            child: Text(
              movie.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
