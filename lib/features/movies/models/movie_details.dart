import 'package:equatable/equatable.dart';

class MovieDetails extends Equatable {
  MovieDetails({
    required this.id,
    required this.title,
    this.overview = '',
    this.posterPath = '',
    this.backdropPath = '',
    this.releaseDate,
    this.rating = 0,
    this.voteCount = 0,
    List<String> genres = const [],
    this.runtime = 0,
    this.originalLanguage = '',
    this.originalTitle = '',
    List<String> productionCountries = const [],
    List<String> directors = const [],
    this.revenue = 0,
    this.budget = 0,
  }) : genres = List.unmodifiable(genres),
       productionCountries = List.unmodifiable(productionCountries),
       directors = List.unmodifiable(directors);

  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final DateTime? releaseDate;
  final double rating;
  final int voteCount;
  final List<String> genres;
  final int runtime;
  final String originalLanguage;
  final String originalTitle;
  final List<String> productionCountries;
  final List<String> directors;
  final int revenue;
  final int budget;

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    rating,
    voteCount,
    genres,
    runtime,
    originalLanguage,
    originalTitle,
    productionCountries,
    directors,
    revenue,
    budget,
  ];
}
