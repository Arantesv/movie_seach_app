/// Build-time configuration. Embedded API keys are extractable from a binary.
class AppConfig {
  const AppConfig({required this.tmdbApiKey});

  factory AppConfig.fromEnvironment() =>
      const AppConfig(tmdbApiKey: String.fromEnvironment('TMDB_API_KEY'));

  final String tmdbApiKey;

  bool get isConfigured => tmdbApiKey.trim().isNotEmpty;
}
