import 'package:flutter/material.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/home/widgets/movie_carousel.dart';

/// Exibe a categoria de filmes.
///
/// O [MovieCategories] recebe um título [title] e uma função [fetchMovies] que
/// retorna uma lista futura de objetos [Movie]. O título é exibido no topo,
/// seguido por um carrosel de filmes atráves do widget [MovieCarousel].
class MovieCategories extends StatelessWidget {
  final String title;
  final Future<List<Movie>> fetchMovies;

  const MovieCategories(
      {super.key, required this.title, required this.fetchMovies});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.007,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          FutureBuilder<List<Movie>>(
            future: fetchMovies,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return MovieCarousel(movies: snapshot.data!);
              } else {
                return const Center(child: Text('Nenhum filme disponível.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
