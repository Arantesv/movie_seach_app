import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:movie_search_app/screens/home/sections/movie_categories.dart';

/// Tela inicial do aplicativo que exibe três categorias de filmes.
///
/// O [HomeScreen] utiliza o [ApiService] para buscar filmes em cartaz, 
/// melhor avaliados e populares, exibindo cada categoria através da 
/// seção [MovieCategories].
class HomeScreen extends StatelessWidget {  
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieCategories(
                  title: 'Em Cartaz',
                  fetchMovies: api.fetchUpcomingMovies(),
                ),
                MovieCategories(
                  title: 'Melhor Avaliados',
                  fetchMovies: api.fetchTopRatedMovies(),
                ),
                MovieCategories(
                  title: 'Populares',
                  fetchMovies: api.fetchPopularMovies(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}