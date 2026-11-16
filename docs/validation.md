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

## Validações de dispositivo pendentes

`flutter build apk --debug` foi tentado localmente e bloqueado pela ausência do Android SDK. O ambiente também não possui dispositivo Android conectado. O empacotamento foi validado na CI com Android SDK, mas não substitui a execução com TMDB em dispositivo.

Smoke test em Android real ou emulador, com credencial TMDB local:

1. Abrir o app e conferir as três categorias.
2. Buscar um título pelo botão e pelo teclado, incluindo `Título (2020)`.
3. Abrir os detalhes e verificar dados, elenco e similares.
4. Abrir o trailer no app externo ou navegador.
5. Voltar e confirmar que consulta e resultados foram preservados.
6. Trocar abas e confirmar que os dados não são recarregados desnecessariamente.
7. Conferir mensagens de falha e tentar novamente após restabelecer a conexão.

iOS requer macOS/Xcode e ainda não foi validado nesta etapa. Os workflows de distribuição iOS preexistentes foram preservados.

## Antes de publicar

- Rotacionar a credencial TMDB que esteve no histórico do repositório e configurar a nova apenas localmente.
- Registrar a evidência do smoke test Android com credencial local.
- Conferir os checks da PR de release antes da tag estável.

## Preparação da versão 1.1.0

As cinco entregas foram integradas por PR em `develop`. A branch `release/1.1.0` prepara a comparação final com `main`, com versão `1.1.0+2`. A PR de release permanece como rascunho e nenhuma nova tag estável será criada enquanto o smoke test com TMDB estiver pendente.

A release e a tag `v1.0.0` já existiam desde 2024-08-20 e foram preservadas. Esta evolução usa `1.1.0+2` para não sobrescrever a versão publicada.
