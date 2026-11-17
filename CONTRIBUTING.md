# Como contribuir

Use Flutter 3.47.9, conforme `.fvmrc`, e o lockfile versionado. Execute `flutter pub get --enforce-lockfile` antes de trabalhar. O setup completo está no README.

## GitFlow simplificado

- `main`: versão estável; recebe releases e hotfixes por PR.
- `develop`: integração; recebe as branches de trabalho por PR.
- `feature/<descricao>`: nova funcionalidade.
- `refactor/<descricao>`: reorganização e alterações estruturais.
- `chore/<descricao>`: dependências, configuração, CI e documentação.
- `release/<major.minor.patch>`: preparação de uma versão a partir de `develop`.
- `hotfix/<descricao>`: correção urgente criada a partir de `main`.

Nomes em inglês, minúsculos e separados por hífen. Mantenha branches curtas, uma mudança coerente por PR.

```sh
git switch develop
git pull --ff-only
git switch -c feature/movie-favorites
```

Não faça push direto em `main` ou `develop`. PRs de trabalho usam squash merge, com o título no padrão Conventional Commits. Releases e hotfixes usam merge commit para preservar a relação entre as branches de longa duração. Depois de integrar uma release ou hotfix em `main`, abra a PR de `main` para `develop` e sincronize o histórico. Exclua branches temporárias após concluir as integrações.

## Commits e PRs

Formato: `<tipo>(<escopo opcional>): <descrição imperativa em inglês>`.

```text
feature branch: feature/movie-favorites
feat(favorites): persist saved movies locally
fix(search): ignore stale search responses
refactor(movies): isolate TMDB response mapping
test(movie-details): cover partial failures
chore(deps): update Flutter dependencies
docs: explain project setup
```

Use `feat` para funcionalidade, `fix` para correção, `refactor` para estrutura, `test` para testes, `docs` para documentação, `ci` para automação e `chore` para manutenção. Cada commit deve compilar. Inclua os testes relevantes junto da implementação; não faça commits de código deliberadamente quebrado.

A PR descreve o problema, o resultado e como foi validada. Seu título será o commit de squash. Informe limitações de plataforma e inclua evidência visual quando houver mudança de interface.

## Organização do código

- `app`: inicialização, navegação, composição de dependências e tema.
- `core`: configuração, transporte HTTP e falhas compartilhadas.
- `features/movies/models`: valores imutáveis sem dependências de Flutter ou JSON.
- `features/movies/repositories`: contrato consumido pelos Cubits.
- `features/movies/data`: TMDB, mappers e implementação do repositório.
- `features/movies/presentation`: páginas, Cubits, estados e widgets de cada fluxo.

Widgets recebem dados e callbacks. Cubits recebem o repositório por construtor. Não importe a implementação de dados na apresentação. Crie abstrações e pastas conforme uma necessidade concreta. Consulte o ADR antes de introduzir uma nova camada.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Os checks obrigatórios são `Quality` e `Android debug`. Testes usam HTTP simulado ou repositório fake, sem internet ou credencial real. O APK da CI valida empacotamento e não contém configuração TMDB.

## Release

Após integrar as entregas em `develop`, crie `release/1.1.0`. Confira a versão `1.1.0+2`, os checks e o smoke test Android com credencial local. Valide o build iOS em macOS (localmente ou na CI) e execute o smoke test em dispositivo antes de declarar suporte iOS validado. Registre os resultados em `docs/validation.md`.

Com esses critérios atendidos, integre a release por PR em `main`, crie a tag anotada `v1.1.0` no commit integrado e sincronize `develop` por PR. Não publique tag de versão estável enquanto a validação de dispositivo estiver pendente. Versões futuras seguem SemVer e incrementam o número de build.
