import 'package:flutter/material.dart';
import 'package:movie_search_app/api/api_service.dart';
import 'package:movie_search_app/models/movie.dart';
import 'package:movie_search_app/screens/search/sections/movie_list_section.dart';
import 'package:movie_search_app/screens/movie_details/movie_detail_screen.dart';

/// Tela com busca de filmes onde o usuário pode pesquisar por títulos e visualizar os resultados.
class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Movie> _movies = [];
  bool _loading = false;

  /// Realiza a busca de filmes com base no texto inserido no campo de busca.
  /// Se o texto contiver um ano entre parênteses, a expressão regular [yearRegExp]
  /// captura o ano para usá-lo como filtro nos resultados.
  ///
  /// - `\((\d{4})\)$`: Captura um número de 4 dígitos (ano) entre parênteses no final da string.
  ///
  /// Referência: https://api.flutter.dev/flutter/dart-core/RegExp-class.html
  void _searchMovies() async {
    setState(() {
      _loading = true;
    });

    final query = _controller.text.trim();
    final yearRegExp = RegExp(r'\((\d{4})\)$');
    String? year;
    String titleQuery = query;

    final match = yearRegExp.firstMatch(query);
    if (match != null) {
      year = match.group(1);
      titleQuery = query.substring(0, match.start).trim();
    }

    try {
      final movies = await ApiService().searchMovies(titleQuery, year: year);
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao buscar filmes: $e'),
        ));
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  labelText: 'Digite o título do filme que deseja buscar',
                  labelStyle: TextStyle(fontSize: fontSize),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, size: screenWidth * 0.06),
                    onPressed: _searchMovies,
                  ),
                ),
                onSubmitted: (_) => _searchMovies(),
              ),
              SizedBox(height: screenHeight * 0.003),
              _loading
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return MovieListSection(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailScreen(movieId: movie.id),
                                ),
                              ).then((_) {
                                _controller.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
