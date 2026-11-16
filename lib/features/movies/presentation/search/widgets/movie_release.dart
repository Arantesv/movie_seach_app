import 'package:flutter/material.dart';

/// Exibe o ano de lançamento de um filme.
///
/// O [MovieReleaseDate] mostra o ano de lançamento de um filme,
/// extraído da data completa fornecida através de [releaseDate].
class MovieReleaseDate extends StatelessWidget {
  const MovieReleaseDate({required this.releaseDate});

  final DateTime? releaseDate;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        SizedBox(width: screenWidth * 0.003),
        Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.018),
        Expanded(
          child: Text(
            releaseDate?.year.toString() ?? 'Ano não informado',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}
