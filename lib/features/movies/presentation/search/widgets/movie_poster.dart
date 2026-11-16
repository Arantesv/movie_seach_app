import 'package:flutter/material.dart';

/// Exibe o pôster do filme no resultado da pesquisa.
///
/// O [MoviePoster] mostra a imagem do pôster de um filme com um caminho
/// fornecido por [posterPath]. Se o caminho estiver vazio, exibe um
/// espaço cinza com um ícone de filme em vez do pôster.
class MoviePoster extends StatelessWidget {
  const MoviePoster({required this.posterPath});

  final String posterPath;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final posterWidth = screenWidth * 0.25;
    final posterHeight = posterWidth * 1.49;

    return ClipRRect(
      borderRadius: BorderRadius.circular(screenWidth * 0.02),
      child: posterPath.isNotEmpty
          ? Image.network(
              'https://image.tmdb.org/t/p/w185$posterPath',
              width: posterWidth,
              height: posterHeight,
              fit: BoxFit.cover,
            )
          : Container(
              width: posterWidth,
              height: posterHeight,
              color: Colors.grey[700],
              child: Icon(
                Icons.movie,
                color: Colors.white70,
                size: posterWidth * 0.5,
              ),
            ),
    );
  }
}
