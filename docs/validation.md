# Registro de validação

## Reestruturação — 2026-11-16

- Flutter 3.47.9 / Dart 3.13.7 em Windows.
- 39 testes automatizados de dados, Cubits, widgets e navegação passaram.
- `flutter analyze --no-pub`: sem problemas após restauração dos lints padrão.
- Credenciais reais não são usadas pelos testes.
- O fluxo de widgets verifica busca manual, filtro por ano, troca de abas, abertura dos detalhes e retorno preservando consulta e resultados.
- Rebuild da rota não gera novas consultas. Testes cobrem respostas fora de ordem, fechamento dos Cubits e retries independentes.
- Launcher de trailer testado com app externo, fallback e falha nas duas opções; o sistema operacional não foi acionado por esses testes.

## Build Android validado na CI

A [execução 43811827143](https://github.com/Arantesv/movie_seach_app/actions/runs/43811827143), referente à PR de qualidade, passou nos jobs `Quality` e `Android debug`. O APK debug foi gerado e disponibilizado como artefato `android-debug-unconfigured`, sem credencial TMDB real embutida.

A base Android usa AGP 8.11.1, Gradle 8.14.3, Kotlin 2.2.20 e JDK 17. A compatibilidade de AGP com API 36/JDK 17 está documentada nas [notas oficiais do Android](https://developer.android.com/build/releases/agp-8-11-0-release-notes).

## Build iOS validado na CI

A [execução 44199671256](https://github.com/Arantesv/movie_seach_app/actions/runs/44199671256) gerou o IPA com configuração TMDB fornecida por GitHub Actions Secret. A correção foi integrada pela PR #8.

## Smoke tests e credenciais — 2026-11-17

O autor confirmou nesta data a conclusão dos smoke tests em **Android e iOS** e a revogação da credencial TMDB antiga. A confirmação de execução nos dispositivos foi fornecida pelo autor; os testes automatizados e builds possuem evidências separadas na CI.

Cenários confirmados pelo autor:

1. Carregamento das categorias.
2. Busca por título e filtro por ano.
3. Detalhes, elenco e filmes similares.
4. Abertura de trailer.
5. Retorno preservando consulta e resultados.
6. Troca de abas sem recarregamento desnecessário.
7. Tratamento de falhas de conexão e nova tentativa.

## Versão 1.1.0

Critérios de validação atendidos para fechamento da release `1.1.0+2`: checks automatizados aprovados, builds Android/iOS, smoke tests confirmados pelo autor e revogação da credencial anterior confirmada.

A release e a tag `v1.0.0`, publicadas em 2024-08-20, foram preservadas. Esta evolução utiliza a versão `1.1.0+2`.

## Paginação da busca — 2026-11-17

- “Em Cartaz” foi renomeado para “Em Breve”, mantendo o endpoint `upcoming` (PR #10).
- A busca recebe páginas e metadados, preserva a ordem da API e elimina duplicatas por ID. O filtro local por ano permanece ativo.
- 56 testes automatizados passaram localmente, junto com formatação e análise estática.
- Os novos cenários cobrem concorrência, última página, limite de acesso do TMDB, metadados inválidos, páginas filtradas vazias, duplicatas, fechamento do Cubit, retry, conteúdo curto, aba inativa e preservação da posição ao navegar.
- Smoke tests desta funcionalidade em Android/iOS serão executados manualmente pelo autor, conforme combinado. Permanecem pendentes; a confirmação da versão 1.1.0 acima não cobre automaticamente esta entrega.

Roteiro pendente: buscar um título com várias páginas, rolar até carregar novas páginas, abrir detalhes e retornar, trocar abas, iniciar nova pesquisa e interromper a conexão durante a carga seguinte. Confirmar que o retry preserva os resultados e a posição.

## Em Cartaz no Brasil — 2026-11-18

A categoria agora usa `MovieCategory.nowPlaying`, endpoint `movie/now_playing`, `region=BR` e idioma `pt-BR`. A região é aplicada apenas a essa categoria. Os testes verificam o caminho e os parâmetros; populares e melhor avaliados permanecem sem alteração.

56 testes automatizados e análise estática passaram. Build configurado instalado no emulador Android 17 / API 37 (`emulator-5554`). Smoke realizado pelo agente: rótulo Em Cartaz, carregamento das três categorias, busca Star, novas páginas, falha de conexão com resultados mantidos e retry após reconectar. Sem entradas no buffer de crashes durante a verificação.

A execução Android anterior também verificou filtro por ano, estados vazio/erro inicial, detalhes, similares, trailer e preservação da posição entre abas. Evidências locais: `C:/Users/Administrator/Documents/movie-smoke-20261118/` (XML, screenshots e logs). O iOS não foi reexecutado nesta correção; não se presume novo smoke iOS a partir da validação anterior.

`now_playing` é uma seleção regional do TMDB por janela de lançamentos, não uma confirmação de sessões em cinemas específicos. Datas principais e relançamentos podem diferir.

## Release 1.2.0

Versão 1.2.0+3: paginação da busca e categoria Em Cartaz regional. Smoke Android executado pelo agente em 2026-11-18; iOS não reexecutado. Os critérios automatizados são exigidos pelas PRs antes da integração.
