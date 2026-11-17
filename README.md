# Movie Search App

Aplicativo Flutter para explorar e buscar filmes no [TMDB](https://www.themoviedb.org/). Criado originalmente para um processo seletivo e retomado como projeto de portfólio, com foco em organização, estado previsível e testes.

## Funcionalidades

- Categorias de filmes populares, melhor avaliados e próximos lançamentos.
- Busca manual por título, com filtro opcional no formato `Harry Potter (2009)`.
- Resultados ordenados por data de lançamento decrescente e depois por título.
- Detalhes com sinopse, elenco, direção, ficha técnica, trailer e similares.
- Retry independente por categoria e seção, estados de vazio e erro e preservação da busca ao navegar.

O rótulo legado “Em Cartaz” ainda usa o endpoint `upcoming`. A correção desse comportamento está fora desta reestruturação. As listas mostram a primeira página retornada pelo TMDB; paginação é uma evolução futura.

## Executar

Pré-requisitos: Flutter **3.47.9** (Dart **3.13.7** no ambiente validado), dispositivo ou emulador. Android requer Android SDK e JDK 17; iOS requer macOS e Xcode.

A versão está fixada em `.fvmrc`. Se usar FVM, execute `fvm install` e prefixe os comandos Flutter/Dart com `fvm`. `flutter pub upgrade` atualiza dependências; o SDK é atualizado separadamente com Flutter/FVM.

```sh
flutter --version
flutter pub get --enforce-lockfile
```

Crie uma credencial no [TMDB](https://developer.themoviedb.org/docs/getting-started), copie `config/example.json` para `config/development.local.json` e preencha `TMDB_API_KEY` somente na cópia local, ignorada pelo Git.

```sh
flutter run --dart-define-from-file=config/development.local.json
```

Também é possível usar `--dart-define=TMDB_API_KEY=<sua-chave>`. Sem configuração, o app exibe uma mensagem de orientação e não inicia chamadas ao catálogo. Uma chave embarcada em app mobile pode ser extraída do binário; `dart-define` evita versionar o valor, mas não é um cofre de segredos. Rotacione a credencial da versão original antes de usar uma nova configuração.

## iPhone via MobAI e GitHub Actions

Nos [secrets do repositório](https://github.com/Arantesv/movie_seach_app/settings/secrets/actions), crie um **Repository secret** chamado `TMDB_API_KEY`, usando a API Key do TMDB (não o Read Access Token). Não coloque o valor em `builder.json`, workflow, commit ou chat.

Os workflows `ios-build.yml` e `ios-share.yml` criam uma configuração temporária no runner, passam `--dart-define-from-file` aos builds Flutter e removem o arquivo ao final. Se o secret estiver ausente, o build falha com uma mensagem de configuração. O arquivo local ignorado pelo Git não é enviado ao runner.

O `builder v0.11.0` usa o workflow da branch padrão (`main`) no dispatch, embora envie um snapshot do código local. Portanto, `builder ios build` passa a usar esta integração quando o workflow corrigido estiver em `main`.

Para validar antes da release, a alternativa documentada é disparar pelo tag temporário `ios-build/<id>` a partir do commit que contém o workflow corrigido; nesse caminho o GitHub usa o workflow do próprio tag. O workflow remove esse tag ao terminar. Após o build, baixe o artefato `ipa` para `dist/` e execute `builder dev flutter --ipa <caminho-do-ipa>`. Um IPA unsigned pode ser assinado localmente pelo MobAI durante a instalação. Não use `builder ios share` para o telefone físico: ele inicia um simulador na CI.

Instale o novo build no iPhone e abra o app. Confirme categorias, busca por título e detalhes para validar a chave. Um IPA antigo não recebe a nova configuração; é preciso recompilar. O secret protege o valor no repositório e nos logs, mas a chave permanece extraível do aplicativo compilado.

## Arquitetura

```text
lib/
  main.dart                    # Entrada
  app/                         # Bootstrap, providers, navegação e tema
  core/                        # Configuração, HTTP e falhas
  features/movies/
    models/                    # MovieSummary, MovieDetails, CastMember e consulta
    repositories/              # Contrato MoviesRepository
    data/                      # Serviço TMDB, mappers e repositório
    presentation/
      home/                    # Cubit, página e widgets das categorias
      search/                  # Cubit, página e widgets de busca
      movie_details/           # Cubit, página e widgets de detalhes
      shared/                  # Estados e widgets compartilhados
```

Fluxo: **widget → Cubit → MoviesRepository → serviço TMDB → cliente HTTP**. A resposta é convertida pelos mappers antes de voltar à apresentação. Dependências são injetadas por construtor e compostas no bootstrap. O cliente HTTP é fechado pelo provider responsável por sua criação.

Cada seção possui estado independente. Cubits ignoram respostas antigas e conclusões após o fechamento; widgets não iniciam rede no `build`. A aba selecionada continua como estado local com `setState`, e `IndexedStack` preserva as páginas. O launcher de trailer é uma dependência da página, testada separadamente do estado do filme.

Decisões e trade-offs: [ADR de arquitetura](docs/adr/0001-feature-first-cubit.md). Vocabulário: [CONTEXT.md](CONTEXT.md).

## Qualidade

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test --coverage
flutter build apk --debug --dart-define-from-file=config/development.local.json
```

Os testes cobrem parsing e ordenação, contrato HTTP, falhas, transições de estado, concorrência, ciclo de vida, retries e navegação. Não dependem de rede nem de credenciais reais.

A CI executa `Quality` (formatação, análise e testes) e `Android debug` (empacotamento). O APK gerado pela CI não contém credencial TMDB e abre a orientação de configuração. O teste real com TMDB deve usar um build configurado localmente.

Consulte o [registro de validação](docs/validation.md) para distinguir testes automatizados, builds e verificações ainda pendentes em dispositivos.

## Desenvolvimento e versões

Adotamos GitFlow simplificado: branches de trabalho → PR para `develop` → `release/*` → PR para `main` → tag. Hotfixes partem de `main` e são sincronizados em `develop`. Commits e títulos de PR seguem Conventional Commits.

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para comandos, convenções e critérios de release.

## Interface original

O visual foi preservado nesta etapa. Estas imagens documentam a versão original:

![Tela inicial original](https://i.imgur.com/vTna4Z4.png)
![Busca original](https://i.imgur.com/uKMvaxJ.png)
![Detalhes originais](https://i.imgur.com/3YHrZKl.png)
![Ficha técnica original](https://i.imgur.com/jsD9fDJ.png)

As [referências originais](docs/references.md) foram mantidas para registrar as fontes usadas no desenvolvimento inicial.

## Próximas etapas

Smoke test Android e validação iOS, correção da categoria “Em Cartaz”, paginação, favoritos, persistência e evolução visual serão tratados separadamente.

Este produto usa a API do TMDB, mas não é endossado ou certificado pelo TMDB.
