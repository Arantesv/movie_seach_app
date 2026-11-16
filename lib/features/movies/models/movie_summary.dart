import 'package:equatable/equatable.dart';

class MovieSummary extends Equatable {
  const MovieSummary({
    required this.id,
    required this.title,
    this.posterPath = '',
    this.releaseDate,
    this.rating = 0,
  });

  final int id;
  final String title;
  final String posterPath;
  final DateTime? releaseDate;
  final double rating;

  @override
  List<Object?> get props => [id, title, posterPath, releaseDate, rating];
}
