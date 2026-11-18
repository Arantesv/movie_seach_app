# 🎬 Movie Search App

Um aplicativo Flutter para descobrir filmes, encontrar seus títulos favoritos e explorar os detalhes de cada história. Os dados são fornecidos pela API do [The Movie Database (TMDB)](https://www.themoviedb.org/).

Desenvolvido originalmente para um processo seletivo, o projeto foi retomado como portfólio para demonstrar a evolução em desenvolvimento mobile, arquitetura e qualidade de código.

## 📱 Conheça o aplicativo

<p align="center">
  <img src="https://i.imgur.com/vTna4Z4.png" width="200" alt="Tela inicial com categorias de filmes" />
  <img src="https://i.imgur.com/uKMvaxJ.png" width="200" alt="Busca de filmes por título" />
  <img src="https://i.imgur.com/3YHrZKl.png" width="200" alt="Detalhes e sinopse do filme" />
  <img src="https://i.imgur.com/jsD9fDJ.png" width="200" alt="Elenco e ficha técnica do filme" />
</p>

*Imagens da interface original, preservada durante a reestruturação do projeto.*

## ✨ Funcionalidades

- **Exploração de filmes:** navegue pelas categorias da tela inicial, incluindo populares e melhor avaliados.
- **Busca por título e ano:** encontre filmes e refine a pesquisa com o formato `Harry Potter (2009)`.
- **Rolagem infinita:** carregue mais resultados ao descer a lista, mantendo a ordem retornada pelo TMDB.
- **Detalhes completos:** consulte sinopse, gêneros, duração, avaliação, direção, elenco e dados de produção.
- **Trailers e filmes similares:** assista ao trailer no YouTube e descubra títulos relacionados.
- **Continuidade na navegação:** volte dos detalhes sem perder sua busca e os resultados.
- **Tratamento de falhas:** estados de carregamento, resultados vazios e opção de tentar novamente.

## 🛠️ Tecnologias

| Tecnologia | Uso no projeto |
| --- | --- |
| **Flutter e Dart** | Desenvolvimento da interface e da aplicação para Android e iOS |
| **Cubit · flutter_bloc** | Gerenciamento de estado dos fluxos de início, busca e detalhes |
| **Equatable** | Comparação de modelos e estados por valor |
| **HTTP · TMDB API** | Consulta ao catálogo de filmes |
| **intl · url_launcher · carousel_slider** | Formatação, abertura de trailers e carrosséis |
| **flutter_test · bloc_test** | Testes de dados, estado, widgets e navegação |
| **GitHub Actions** | Verificação automática de qualidade e builds |

## 🧩 Arquitetura

A organização segue uma abordagem **feature-first**, reunindo a funcionalidade de filmes e separando suas responsabilidades:

- **Apresentação:** páginas, widgets e Cubits de cada fluxo.
- **Dados:** integração com o TMDB, conversão das respostas e implementação do repositório.
- **Modelos e contratos:** representações dos filmes e interfaces utilizadas pela aplicação.
- **App e core:** inicialização, navegação, tema e infraestrutura compartilhada.

As dependências são injetadas por construtor, permitindo testar as regras e os estados sem depender de chamadas reais à API. Cada categoria e seção de detalhes pode carregar ou apresentar falhas de forma independente.

As [decisões de arquitetura](docs/adr/0001-feature-first-cubit.md) estão disponíveis para quem quiser conhecer os trade-offs da implementação.

## ✅ Qualidade

O projeto conta com **56 testes automatizados**, cobrindo integração HTTP simulada, tratamento de dados, transições de estado, concorrência, navegação e recuperação de falhas.

A CI verifica formatação, análise estática, testes e empacotamento Android. O funcionamento em **Android e iOS** foi confirmado em smoke tests pelo autor.

```sh
flutter analyze
flutter test
```

## 🚀 Como executar

Utilize **Flutter 3.47.9**, versão fixada no projeto, e um ambiente configurado para a plataforma desejada.

1. Clone o repositório e instale as dependências:

   ```sh
   git clone https://github.com/Arantesv/movie_seach_app.git
   cd movie_seach_app
   flutter pub get
   ```

2. Obtenha uma API Key nas [configurações do TMDB](https://www.themoviedb.org/settings/api).
3. Copie `config/example.json` para `config/development.local.json` e preencha `TMDB_API_KEY` com sua chave. O arquivo local é ignorado pelo Git.
4. Execute o aplicativo:

   ```sh
   flutter run --dart-define-from-file=config/development.local.json
   ```

## 📚 Sobre o desenvolvimento

O histórico utiliza **GitFlow simplificado** e **Conventional Commits**, com melhorias organizadas em pull requests. As convenções de contribuição estão em [CONTRIBUTING.md](CONTRIBUTING.md).

As [referências da implementação original](docs/references.md) foram preservadas como parte da trajetória de aprendizado do projeto.

---

Este produto usa a API do TMDB, mas não é endossado ou certificado pelo TMDB.
