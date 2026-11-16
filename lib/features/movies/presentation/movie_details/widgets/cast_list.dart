import 'package:movie_search_app/features/movies/presentation/shared/widgets/tmdb_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_search_app/features/movies/models/cast_member.dart';

/// Exibe uma lista horizontal do elenco do filme.
///
/// O [CastList] recebe uma lista de objetos [CastMember] e exibe cada ator
/// em um item de elenco utilizando o widget [CastItem].
class CastList extends StatelessWidget {
  const CastList({super.key, required this.castList});

  final List<CastMember> castList;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: screenWidth * 0.04,
        children: castList.map((cast) => CastItem(cast: cast)).toList(),
      ),
    );
  }
}

/// Representa um único membro do elenco.
///
/// O [CastItem], utilizando o [ClipRRect] para arredondamento da bordas, exibe
/// a imagem de perfil, nome e personagem do ator.
///
/// Referência: https://youtu.be/eI43jkQkrvs
class CastItem extends StatelessWidget {
  const CastItem({super.key, required this.cast});

  final CastMember cast;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final castImageWidth = screenWidth * 0.2;
    final castImageHeight = castImageWidth * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          child: TmdbImage(
            path: cast.profilePath,
            width: castImageWidth,
            height: castImageHeight,
            isPortrait: true,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        SizedBox(
          width: castImageWidth,
          child: Text(
            cast.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        SizedBox(
          width: castImageWidth,
          child: Text(
            cast.character,
            style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
