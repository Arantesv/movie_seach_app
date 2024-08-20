import 'package:flutter/material.dart';

/// Exibe a sinopse do filme.
///
/// O [MovieOverview] apresenta uma sinopse do filme fornecida através
/// do parâmetro [overview].
class MovieOverview extends StatelessWidget {
  const MovieOverview({super.key, required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sinopse',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        Text(
          overview,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.04,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}