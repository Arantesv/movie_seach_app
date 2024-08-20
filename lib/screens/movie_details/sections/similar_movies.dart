import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/widgets/similar_movies_list.dart';

/// Seção que exibe uma lista de filmes similares ao filme específico.
///
/// O [SimilarMovies] utiliza o [movieId] para buscar filmes similares através
/// da API e exibi-los em uma lista utilizando o widget [SimilarMoviesList].
class SimilarMovies extends StatelessWidget {
  final int movieId;

  const SimilarMovies({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Movie>>(
      future: ApiService().getSimilarMovies(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar filmes similares: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final similarMovies = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filmes Similares',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              SimilarMoviesList(movies: similarMovies),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
