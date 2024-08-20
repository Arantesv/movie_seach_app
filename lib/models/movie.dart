class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
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

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.rating,
    required this.genres,
    required this.runtime,
    required this.originalLanguage,
    required this.originalTitle,
    required this.voteCount,
    required this.productionCountries,
    required this.directors,
    required this.revenue,
    required this.budget,
  });

  factory Movie.fromJson(Map<String, dynamic> json, List<String> directors) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      releaseDate: json['release_date'] ?? '0000-00-00',
      rating: json['vote_average'].toDouble(),
      genres: (json['genres'] as List?)
          ?.map((genre) => genre['name'] as String)
          .toList() ?? [],
      runtime: json['runtime'] ?? 0,
      originalLanguage: json['original_language'],
      originalTitle: json['original_title'],
      voteCount: json['vote_count'],
      productionCountries: (json['production_countries'] as List?)
          ?.map((country) => country['name'] as String)
          .toList() ?? [],
      directors: directors,
      revenue: json['revenue'] ?? 0,
      budget: json['budget'] ?? 0,
    );
  }
}
