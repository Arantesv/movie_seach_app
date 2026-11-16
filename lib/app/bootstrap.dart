import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:movie_search_app/app/app.dart';
import 'package:movie_search_app/app/theme/app_theme.dart';
import 'package:movie_search_app/core/config/app_config.dart';
import 'package:movie_search_app/core/network/tmdb_client.dart';
import 'package:movie_search_app/features/movies/data/repositories/tmdb_movies_repository.dart';
import 'package:movie_search_app/features/movies/data/services/tmdb_service.dart';
import 'package:movie_search_app/features/movies/repositories/movies_repository.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final config = AppConfig.fromEnvironment();
  if (!config.isConfigured) {
    runApp(const ConfigurationErrorApp());
    return;
  }
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<http.Client>(
          create: (_) => http.Client(),
          dispose: (client) => client.close(),
        ),
        RepositoryProvider<MoviesRepository>(
          create: (context) => TmdbMoviesRepository(
            TmdbService(
              TmdbClient(
                client: context.read<http.Client>(),
                apiKey: config.tmdbApiKey,
              ),
            ),
          ),
        ),
      ],
      child: const MoviesApp(),
    ),
  );
}

class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.darkTheme,
    home: const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Configure TMDB_API_KEY para iniciar o aplicativo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
