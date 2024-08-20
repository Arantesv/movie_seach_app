import 'package:flutter/material.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/search/widgets/movie_title.dart';
import 'package:movie_search_app/screens/search/widgets/movie_rating.dart';
import 'package:movie_search_app/screens/search/widgets/movie_release.dart';

/// Seção que organiza as informações do filme na lista de pesquisa.
///
/// O [MovieInfo] organiza e exibe o título, a avaliação e a data de lançamento 
/// de um filme, utilizando os widgets [MovieTitle], [MovieRating] 
/// e [MovieReleaseDate].
class MovieInfo extends StatelessWidget {
  const MovieInfo({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MovieTitle(title: movie.title),
          SizedBox(height: screenHeight * 0.01),
          MovieRating(rating: movie.rating),
          SizedBox(height: screenHeight * 0.007),
          MovieReleaseDate(releaseDate: movie.releaseDate),
        ],
      ),
    );
  }
}