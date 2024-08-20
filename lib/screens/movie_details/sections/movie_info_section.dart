import 'package:flutter/material.dart';
import 'package:movie_search_app/screens/movie_details/widgets/movie_info_row.dart';

/// Seção que exibe as principais informações de um filme.
///
/// O [MovieInfoSection] mostra a data de lançamento, a duração e os gêneros 
/// de um filme em formato de coluna, utilizando o widget [MovieInfoRow] 
/// para exibir cada informação com um ícone correspondente.
class MovieInfoSection extends StatelessWidget {
  const MovieInfoSection({
    super.key,
    required this.releaseDate,
    required this.runtime,
    required this.genres,
  });

  final String releaseDate;
  final String runtime;
  final String genres;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        MovieInfoRow(icon: Icons.calendar_today, info: releaseDate),
        SizedBox(height: screenHeight * 0.007),
        MovieInfoRow(icon: Icons.timer, info: runtime),
        SizedBox(height: screenHeight * 0.007),
        MovieInfoRow(icon: Icons.category, info: genres),
      ],
    );
  }
}