enum FailureKind {
  connection,
  timeout,
  unauthorized,
  server,
  invalidData,
  unknown,
}

/// Safe to expose to the presentation layer; never contains a request URL or key.
class AppFailure implements Exception {
  const AppFailure(this.kind);

  final FailureKind kind;

  String get message => switch (kind) {
    FailureKind.connection =>
      'Não foi possível conectar. Verifique sua conexão.',
    FailureKind.timeout => 'A conexão demorou demais. Tente novamente.',
    FailureKind.unauthorized =>
      'Não foi possível autenticar no serviço de filmes.',
    FailureKind.server =>
      'O serviço de filmes está indisponível. Tente novamente.',
    FailureKind.invalidData => 'Não foi possível ler os dados dos filmes.',
    FailureKind.unknown => 'Algo deu errado. Tente novamente.',
  };

  static AppFailure from(Object error) =>
      error is AppFailure ? error : const AppFailure(FailureKind.unknown);
}
