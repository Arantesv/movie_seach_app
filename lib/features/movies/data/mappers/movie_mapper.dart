import 'package:movie_search_app/features/movies/models/cast_member.dart';
import 'package:movie_search_app/features/movies/models/movie_details.dart';
import 'package:movie_search_app/features/movies/models/movie_summary.dart';

class MovieMapper {
  static MovieSummary summary(Map<String, dynamic> json) => MovieSummary(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    posterPath: json['poster_path'] as String? ?? '',
    releaseDate: _date(json['release_date'] as String?),
    rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
  );

  static MovieDetails details(Map<String, dynamic> json) {
    final movie = summary(json);
    final crew =
        (json['credits'] as Map<String, dynamic>?)?['crew'] as List? ?? [];
    return MovieDetails(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      rating: movie.rating,
      overview: json['overview'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      genres: _names(json['genres']),
      runtime: (json['runtime'] as num?)?.toInt() ?? 0,
      originalLanguage: json['original_language'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? movie.title,
      productionCountries: _names(json['production_countries']),
      directors: crew
          .where((member) => member['job'] == 'Director')
          .map((member) => member['name'] as String)
          .toList(),
      revenue: (json['revenue'] as num?)?.toInt() ?? 0,
      budget: (json['budget'] as num?)?.toInt() ?? 0,
    );
  }

  static CastMember cast(Map<String, dynamic> json) => CastMember(
    name: json['name'] as String,
    character: json['character'] as String? ?? '',
    profilePath: json['profile_path'] as String? ?? '',
  );

  static List<String> _names(dynamic value) =>
      (value as List? ?? []).map((item) => item['name'] as String).toList();

  static DateTime? _date(String? value) {
    if (value == null || value.isEmpty) return null;
    final date = DateTime.tryParse(value);
    // DateTime.tryParse normalizes impossible dates; reject them instead.
    return date != null && date.toIso8601String().substring(0, 10) == value
        ? date
        : null;
  }
}
