import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.name,
    this.character = '',
    this.profilePath = '',
  });

  final String name;
  final String character;
  final String profilePath;

  @override
  List<Object?> get props => [name, character, profilePath];
}
