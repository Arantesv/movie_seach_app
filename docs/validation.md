# Registro de validação

## Reestruturação — 2026-11-16

- Flutter 3.47.9 / Dart 3.13.7 em Windows.
- 39 testes automatizados de dados, Cubits, widgets e navegação passaram.
- `flutter analyze --no-pub`: sem problemas após restauração dos lints padrão.
- Credenciais reais não são usadas pelos testes.
- O fluxo de widgets verifica busca manual, filtro por ano, troca de abas, abertura dos detalhes e retorno preservando consulta e resultados.
- Rebuild da rota não gera novas consultas. Testes cobrem respostas fora de ordem, fechamento dos Cubits e retries independentes.
- Launcher de trailer testado com app externo, fallback e falha nas duas opções; o sistema operacional não foi acionado por esses testes.

## Validações de plataforma pendentes

`flutter build apk --debug` foi tentado localmente e bloqueado pela ausência do Android SDK. O ambiente também não possui dispositivo Android conectado. A CI inclui o build em um runner com Android SDK; seu resultado deve ser confirmado antes da release.

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
- Registrar resultado do build Android e evidência do smoke test.
- Conferir os checks da PR de release antes da tag estável.
