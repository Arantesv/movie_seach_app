import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/movie_detail_screen.dart';

/// Exibe uma lista de filmes em um carrossel.
///
/// O [MovieCarousel] exibe uma lista de objetos [Movie] em um carrossel
/// deslizante, destacando o item central. Quando um item é tocado, o usuário 
/// é levado para a tela [MovieDetailScreen].
/// 
/// Referência: https://github.com/ShubhGupta001/PopcornFlix/blob/main/lib/widgets/trending_slider_series.dart#L6
class MovieCarousel extends StatelessWidget {
  final List<Movie> movies;

  const MovieCarousel({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Define a fração da viewport com base na largura da tela, se adaptando aos tablets.
    double viewportFraction = screenWidth > 600 ? 0.31 : 0.35;

    return CarouselSlider.builder(
      itemCount: movies.length,
      itemBuilder: (context, index, pageViewIndex) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () {
            // Navega para a tela de detalhes do filme quando um item é tocado.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movieId: movie.id),
              ),
            );
          },
          child: MovieCarouselItem(movie: movie),
        );
      },
      options: CarouselOptions(
        height: screenHeight * 0.234,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: viewportFraction,
      ),
    );
  }
}

/// Representa um item individual no carrossel de filmes.
///
/// O [MovieCarouselItem] exibe a imagem do pôster de um [Movie].
class MovieCarouselItem extends StatelessWidget {
  final Movie movie;

  const MovieCarouselItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.01,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
