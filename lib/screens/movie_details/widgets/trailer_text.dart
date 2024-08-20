import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Exibe um texto clicável para reproduzir o trailer do filme.
///
/// O [TrailerText] utiliza o [movieId] para buscar o trailer do filme através
/// da API e exibe um link que, ao ser clicado, abre o vídeo no YouTube.
class TrailerText extends StatelessWidget {
  final int movieId;

  const TrailerText({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<String?>(
      future: ApiService().getMovieTrailer(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return const SizedBox.shrink();
        } else {
          final trailerKey = snapshot.data!;
          final trailerUrl = 'https://www.youtube.com/watch?v=$trailerKey';

          return GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse(trailerUrl);
              bool launched = await launchUrl(
                url,
                mode: LaunchMode.externalNonBrowserApplication,
              );
              if (!launched) {
                launched = await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: Row(
              children: [
                Icon(Icons.play_arrow, size: screenWidth * 0.045, color: Colors.grey[300]),
                SizedBox(width: screenWidth * 0.015),
                Text(
                  'Reproduzir trailer',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: screenWidth * 0.04,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
