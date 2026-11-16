import 'package:flutter/material.dart';
import 'package:movie_search_app/screens/movie_details/movie_detail_screen.dart';

abstract final class AppNavigator {
  static Future<void> openMovieDetails(BuildContext context, int movieId) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movieId: movieId)),
      );
}
