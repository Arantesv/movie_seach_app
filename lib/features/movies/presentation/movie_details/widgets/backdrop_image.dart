import 'package:movie_search_app/features/movies/presentation/shared/widgets/tmdb_image.dart';
import 'package:flutter/material.dart';

/// Exibe a imagem de fundo (backdrop) do filme.
///
/// A imagem é obtida da API do The MovieDetails Database (TMDb) usando o [imagePath]
/// fornecido e é exibida com largura total e uma altura proporcional à tela.
class BackdropImage extends StatelessWidget {
  final String imagePath;
  const BackdropImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.25,
      child: TmdbImage(path: imagePath, size: 'w780'),
    );
  }
}
