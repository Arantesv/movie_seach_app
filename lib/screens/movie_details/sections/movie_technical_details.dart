import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/movie_details/widgets/movie_info_row.dart';
import 'package:sealed_languages/sealed_languages.dart';

/// Seção que exibe a ficha técnica de um filme.
///
/// O [MovieTechnicalDetails] exibe informações como diretores, idioma
/// original, países de produção, orçamento e receita do filme, utilizando o
/// widget [MovieInfoRow] para exibir cada informação com ícones correspondentes.
class MovieTechnicalDetails extends StatelessWidget {
  const MovieTechnicalDetails({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Junta os diretores do filme em uma única string separada por vírgulas.
    final String directors = movie.directors.join(', ');

    // Converte o código de idioma curto em um nome legível.
    final String language =
        NaturalLanguage.fromCodeShort(movie.originalLanguage).name;

    // Junta os países de produção do filme em uma única string separada por vírgulas.    
    final String productionCountries = movie.productionCountries.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ficha Técnica',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        MovieInfoRow(icon: Icons.person, info: 'Direção: $directors'),
        SizedBox(height: screenWidth * 0.007),
        MovieInfoRow(icon: Icons.language, info: 'Idioma Original: $language'),
        SizedBox(height: screenWidth * 0.007),
        MovieInfoRow(icon: Icons.public, info: 'País: $productionCountries'),
        if (movie.budget > 0) ...[
          SizedBox(height: screenWidth * 0.007),
          MovieInfoRow(
              icon: Icons.account_balance_wallet,
              info: 'Orçamento: ${formatCurrency(movie.budget)}'),
        ],
        if (movie.revenue > 0) ...[
          SizedBox(height: screenWidth * 0.007),
          MovieInfoRow(
              icon: Icons.monetization_on,
              info: 'Receita: ${formatCurrency(movie.revenue)}'),
        ],
      ],
    );
  }
}

/// Formata um valor numérico para o formato de moeda.
///
/// Utiliza [NumberFormat.currency] para formatar valores monetários com o símbolo
/// de dólar e duas casas decimais.
/// 
/// Referência: https://api.flutter.dev/flutter/intl/NumberFormat/NumberFormat.currency.html
String formatCurrency(int amount) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  ).format(amount);
}
