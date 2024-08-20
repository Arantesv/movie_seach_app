import 'package:flutter/material.dart';

/// Exibe a avaliação de um filme com uma estrela e o valor numérico.
///
/// O [MovieRating] mostra uma estrela laranja seguida pelo valor da avaliação 
/// do filme, formatado com duas casas decimais.
class MovieRating extends StatelessWidget {
  const MovieRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(Icons.star, color: Colors.orangeAccent, size: screenWidth * 0.05),
        SizedBox(width: screenWidth * 0.01),
        Text(
          rating.toStringAsFixed(2),
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Colors.grey[400],
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}