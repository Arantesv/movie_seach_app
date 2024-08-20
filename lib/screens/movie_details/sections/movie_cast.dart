import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:movie_search_app/models/cast.dart';
import 'package:movie_search_app/screens/movie_details/widgets/cast_list.dart';

/// Seção que organiza o elenco de um filme.
///
/// O [MovieCast] faz uma chamada à API para buscar os dados do elenco de um 
/// filme específico, identificado por [movieId], e exibe essa informação 
/// em uma lista de elenco utilizando o widget [CastList].
class MovieCast extends StatelessWidget {
  const MovieCast({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elenco',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        FutureBuilder<List<Cast>>(
          future: ApiService().getMovieCast(movieId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final castList = snapshot.data!;
              return CastList(castList: castList);
            } else {
              return const Center(child: Text('Nenhum dado disponível.'));
            }
          },
        ),
      ],
    );
  }
}