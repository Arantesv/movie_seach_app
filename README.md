
# 🎥 Movie Search App - Flutter

Este aplicativo de busca de filmes foi desenvolvido para um processo seletivo, com o objetivo de facilitar a exploração de filmes para entusiastas de cinema. Utilizando a API do TMDB (The Movie Database), o app permite aos usuários buscar títulos específicos e navegar por em cartaz, melhor avaliados e populares.

## Screenshots 📱

![home](https://i.imgur.com/vTna4Z4.png)
![search](https://i.imgur.com/uKMvaxJ.png)
![deitails](https://i.imgur.com/3YHrZKl.png)
![details2](https://i.imgur.com/jsD9fDJ.png)


## Funcionalidades ⚙️

- Tela Inicial:
    - Exibe os filmes mais populares, os mais bem avaliados e os que estão atualmente em cartaz nos cinemas.
- Tela de busca:
    - Permite aos usuários buscar filmes pelo título.
    - Apresenta os resultados ordenados pelo ano de lançamento (do mais recente ao mais antigo) e, em seguida, em ordem alfabética.
    - Mostra o título em português do filme, ano de lançamento e avalição no TMDB.
    - O usuário pode pesquisar um filme e filtrar por um ano específico, adicionando-o entre parênteses no final do título. Exemplo: "Harry Potter (2009)".
- Tela de detalhes do filme:
    - Ao selecionar um filme, são fornecidas informações detalhadas:
    - Título Original;
    - Avalição no TMDB (com quantidade de votos);
    - Data de lançamento;
    - Gêneros
    - Trailer;
    - Sinopse;
    - Elenco principal;
    - Direção;
    - Idioma original;
    - Orçamento e Receita;
    - Filmes Similares.


## API 🌐

Este aplicativo utiliza a API do The Movie Database (TMDB) para buscar, filtrar e exibir informações detalhadas sobre filmes. 

### Funcionalidades

- **Busca de Filmes:**  
  O método `searchMovies` permite buscar filmes por título e, opcionalmente, filtrar os resultados por ano de lançamento.

- **Detalhes de Filmes:**  
  O método `getMovieDetails` obtém informações detalhadas de um filme específico, incluindo sinopse, elenco, e direção. Utiliza o parâmetro `append_to_response=credits` para incluir os diretoes do filme na resposta.

- **Elenco de Filmes:**  
  O método `getMovieCast` retorna uma lista dos principais membros do elenco de um filme.

- **Trailer de Filmes:**  
  O método `getMovieTrailer` busca o trailer do filme em diferentes idiomas, retornando o primeiro resultado válido.

- **Filmes Similares:**  
  O método `getSimilarMovies` retorna uma lista de filmes similares ao filme especificado.

- **Listas de Filmes:**  
  Métodos como `fetchUpcomingMovies`, `fetchTopRatedMovies`, e `fetchPopularMovies` são usados para obter listas de filmes que estão por vir, filmes bem avaliados e filmes populares.
  
## Referências 📚

Aqui estão algumas referências que foram utilizadas no desenvolvimento deste projeto:

- **Primeiro App Flutter:**  
   Vídeo introdutório que ajuda a criar seu primeiro aplicativo no Flutter: [YouTube](https://youtu.be/Zqz_76JYPSc)

- **Parâmetros de Imagens do TMDB:**  
   Guia para entender os parâmetros de imagem na API TMDB: [TMDB Talk](https://www.themoviedb.org/talk/5aeaaf56c3a3682ddf0010de)

- **Estruturação de Widgets no Flutter:**  
   Vídeo que aborda como estruturar widgets em um projeto Flutter: [YouTube](https://youtu.be/IOyq-eTRhvo)

- **Axis Alignment no Flutter:**  
    Tutorial sobre alinhamento de eixos no Flutter: [YouTube](https://youtu.be/S5P-rWFGZkI)

- **Bottom App Bar:**  
   Tutorial de como implementar o `bottomNavigationBar`: [Youtube](https://youtu.be/dryIXZJ8lDk)

- **Material Page Route**  
   Vídeo mostrando como utilizar o `MaterialPageRoute` para navegar entre telas: [YouTube](https://youtu.be/Wgl7yj8Uidg)

- **Gerenciamento de Estado (MainState):**  
   Documentação oficial do Flutter sobre gerenciamento de estado: [Docs Flutter](https://docs.flutter.dev/data-and-backend/state-mgmt/ephemeral-vs-app)

- **Cartão de Filmes:**  
   Tutorial sobre como criar um cartão de filmes implementando na tela de pesquisa: [YouTube](https://youtu.be/AniCEAbmibA)

- **Arredondar Bordas de Imagens:**  
   Tutorial sobre `ClipRRect` para arredondar bordas de imagens no Flutter: [YouTube](https://youtu.be/eI43jkQkrvs)

- **Uso do FutureBuilder:**  
   Vídeo explicando como utilizar o `FutureBuilder` no Flutter: [YouTube](https://youtu.be/zEdw_1B7JHY)

- **Widgets Stateful:**  
    Tutorial sobre como criar widgets Stateful no Flutter: [YouTube](https://youtu.be/mIqbraKbgyA)

- **Criação de App Intuitivo com TMDB API:**  
   Tutorial sobre como criar um aplicativo intuitivo utilizando a API do TMDB: [Medium](https://medium.com/@przyczynski/flutter-creating-an-intuitive-app-based-on-the-movie-database-api-90a07b989bf9)

- **Modelo de App para Consumo da API TMDB:**  
   Tutorial detalhado sobre como criar um aplicativo para consumir a API de filmes do TMDB: [Medium](https://medium.com/flutter-comunidade-br/criando-um-aplicativo-em-flutter-para-consumir-uma-api-de-filmes-tmdb-2b5a9982bfcd)

- **Guia Completo da API TMDB:**  
    Vídeo sobre como consumir a API do TMDB no Flutter: [YouTube](https://youtu.be/1uxnXwN0s5Q)

- **Append to Response na API do TMDB:**  
    Guia oficial sobre o uso do parâmetro `append_to_response` para adicionar informações extras na resposta da API em uma única requisição: [TMDB Docs](https://developer.themoviedb.org/docs/append-to-response)

- **Uso de Expressão Regular para Cortar String (YYYY):**  
    Documentação oficial sobre o uso de `RegExp` no Dart: [API Flutter](https://api.flutter.dev/flutter/dart-core/RegExp-class.html)

- **Trailers na TMDB API:**  
    Discussão sobre como trabalhar com trailers na API TMDB: [TMDB Talk](https://www.themoviedb.org/talk/62db7e45ea84c7004fc5a8c7)

- **Formato de Moeda em Dólares:**  
    Guia sobre como formatar números utilizando `NumberFormat` no Flutter: [API Flutter](https://api.flutter.dev/flutter/intl/NumberFormat/NumberFormat.currency.html)

- **Carrossel de Filmes:**  
    Tutorial sobre como criar um carrossel de filmes com `carousel_slider` no Flutter: [YouTube](https://youtu.be/hkExmbmsCvQ)  
    Código de referência para carrossel de filmes implementado na página inicial: [GitHub](https://github.com/ShubhGupta001/PopcornFlix/blob/main/lib/widgets/trending_slider_series.dart#L6)

- **Bloqueio de Modo Paisagem:**  
    Solução para bloquear a rotação da tela no Flutter: [Stack Overflow](https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait)

- **Uso de TextOverflow:**  
    Solução para lidar com overflow de texto no Flutter: [Stack Overflow](https://stackoverflow.com/a/54222581)

- **Guia Documentação do Dart:**  
   Guia oficial do Dart de como fazer uma documentação efetiva: [Dart Dev](https://dart.dev/effective-dart/documentation)

## Possíveis Melhorias 🔧

Para futuras versões, é necessário implementar uma adaptação para o modo paisagem em celulares e tablets, a fim de aprimorar a responsividade e oferecer uma melhor experiência de uso em diferentes orientações de tela. 

Além disso, o design do aplicativo pode ser aprimorado. Como esta foi minha primeira experiência na criação de layouts, acredito que há diversas oportunidades para melhorias no visual e na usabilidade, tornando a interface mais intuitiva e atraente.
