import 'package:equatable/equatable.dart';

/// Parses the existing "Title (YYYY)" search syntax without depending on Flutter.
class MovieQuery extends Equatable {
  const MovieQuery(this.title, {this.year});

  factory MovieQuery.parse(String input) {
    final text = input.trim();
    final match = RegExp(r'\((\d{4})\)$').firstMatch(text);
    return MovieQuery(
      match == null ? text : text.substring(0, match.start).trim(),
      year: match?.group(1),
    );
  }

  final String title;
  final String? year;

  @override
  List<Object?> get props => [title, year];
}
