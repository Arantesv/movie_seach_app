import 'package:flutter/material.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/movie_detail_screen.dart';

/// Exibe uma lista horizontal de filmes similares.
///
/// O [SimilarMoviesList] recebe uma lista de objetos [Movie] e exibe cada filme
/// em um item de lista utilizando o widget [SimilarMovieItem]. Apenas filmes 
/// com um caminho de pôster válido são exibidos.
class SimilarMoviesList extends StatelessWidget {
  const SimilarMoviesList({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: screenWidth * 0.04,
        children: movies
            .where((movie) => movie.posterPath.isNotEmpty)
            .map((movie) => SimilarMovieItem(movie: movie))
            .toList(),
      ),
    );
  }
}

/// Representa um único filme similar na lista.
///
/// O [SimilarMovieItem] exibe o pôster e o título do filme utilizando [ClipRRect], e permite a navegação
/// para a tela de detalhes do filme [MovieDetailScreen] ao ser tocado.
class SimilarMovieItem extends StatelessWidget {
  const SimilarMovieItem({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final posterUrl = 'https://image.tmdb.org/t/p/w185${movie.posterPath}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieId: movie.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: Image.network(
              posterUrl,
              width: screenWidth * 0.25,
              height: screenWidth * 0.375,
              fit: BoxFit.cover,
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
