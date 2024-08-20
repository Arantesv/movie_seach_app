import 'package:flutter/material.dart';
import 'package:movie_search_app/models/movie.dart';

/// Exibe o título e a avaliação do filme.
///
/// O [MovieTitleRating] apresenta o título, a avaliação do usuário com o número de votos
/// e o título original do filme em itálico.
class MovieTitleRating extends StatelessWidget {
  const MovieTitleRating({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                movie.title,
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orangeAccent, size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.005),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  '(${movie.voteCount})',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          movie.originalTitle,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
