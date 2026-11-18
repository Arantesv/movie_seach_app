import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_search_app/app/navigation/app_navigator.dart';
import 'package:movie_search_app/features/movies/models/movie_category.dart';
import 'package:movie_search_app/features/movies/presentation/home/cubit/home_cubit.dart';
import 'package:movie_search_app/features/movies/presentation/home/cubit/home_state.dart';
import 'package:movie_search_app/features/movies/presentation/home/widgets/movie_carousel.dart';
import 'package:movie_search_app/features/movies/presentation/shared/widgets/async_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('home'),
          padding: EdgeInsets.symmetric(horizontal: width * 0.03),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final category in MovieCategory.values)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.007),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(switch (category) {
                          MovieCategory.nowPlaying => 'Em Cartaz',
                          MovieCategory.topRated => 'Melhor Avaliados',
                          MovieCategory.popular => 'Populares',
                        }, style: TextStyle(fontSize: width * 0.05)),
                        SizedBox(height: height * 0.008),
                        AsyncSection(
                          state: state.categories[category]!,
                          onRetry: () =>
                              context.read<HomeCubit>().loadCategory(category),
                          builder: (movies) => movies.isEmpty
                              ? const Text('Nenhum filme disponível.')
                              : MovieCarousel(
                                  movies: movies,
                                  onMovieTap: (movie) =>
                                      AppNavigator.openMovieDetails(
                                        context,
                                        movie.id,
                                      ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
