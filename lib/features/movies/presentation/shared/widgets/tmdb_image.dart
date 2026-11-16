import 'package:flutter/material.dart';

/// Consistent handling of missing paths and failed image downloads.
class TmdbImage extends StatelessWidget {
  const TmdbImage({
    super.key,
    required this.path,
    this.size = 'w185',
    this.width,
    this.height,
    this.isPortrait = false,
  });

  final String path;
  final String size;
  final double? width;
  final double? height;
  final bool isPortrait;

  Widget _placeholder() => isPortrait
      ? Image.asset(
          'assets/images/default_avatar.png',
          width: width,
          height: height,
          fit: BoxFit.cover,
        )
      : Container(
          width: width,
          height: height,
          color: Colors.grey[700],
          child: const Center(child: Icon(Icons.movie, color: Colors.white70)),
        );

  @override
  Widget build(BuildContext context) => path.isEmpty
      ? _placeholder()
      : Image.network(
          Uri.https('image.tmdb.org', '/t/p/$size$path').toString(),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _placeholder(),
        );
}
