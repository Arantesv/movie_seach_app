import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/sections/general_movie_section.dart';

/// Tela de detalhes do filme.
///
/// O [MovieDetailScreen] exibe detalhes completos de um filme utilizando o [movieId] 
/// para buscar as informações através da API. A tela é estruturada com um [AppBar] 
/// e uma [FutureBuilder] para gerenciar o estado da requisição de dados.
class MovieDetailScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Filme',
          style: TextStyle(fontSize: screenWidth * 0.05),
        ),
      ),
      body: FutureBuilder<Movie>(
        future: ApiService().getMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return GeneralMovieSection(movie: movie);
          } else {
            return const Center(child: Text('Nenhum dado disponível.'));
          }
        },
      ),
    );
  }
}
