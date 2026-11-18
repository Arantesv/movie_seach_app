# Organização por funcionalidade com Cubit e repositório injetável

Status: aceita em 2026-11-16.

O app possui um domínio de filmes compartilhado entre início, busca e detalhes. Adotamos uma funcionalidade `movies` com esses três fluxos de apresentação, modelos compartilhados e um contrato `MoviesRepository`; conversão de JSON e integração TMDB ficam na camada de dados. Isso evita duplicar o acesso ao catálogo entre telas e permite testar o comportamento sem rede.

Escolhemos Cubit porque as ações atuais são chamadas diretas, incluindo uma busca enviada manualmente. A troca por BLoC com eventos deve ser justificada por necessidades de composição ou transformação de eventos. O índice da aba continua sendo estado local da interface. A injeção ocorre por construtor, com providers no ponto de composição; os widgets não instanciam serviços.

`MovieSummary` representa os dados necessários às listas e `MovieDetails` os dados detalhados de um título. São modelos independentes de JSON e Flutter; mappers concentram a tradução do contrato externo. `CastMember` representa uma pessoa e seu personagem nos créditos desse filme. Datas desconhecidas são ausentes, sem valores sentinela.

Consideramos Clean Architecture completa com entidades, DTOs e casos de uso para cada operação. Optamos por não duplicar representações nem criar casos de uso que apenas repassem chamadas: a complexidade atual não justifica esse custo. Regras novas que combinem operações ou sejam reutilizadas poderão ganhar casos de uso sem alterar os widgets.

Cada categoria e seção complementar possui estado independente. Resultados assíncronos antigos ou recebidos após o fechamento do Cubit são ignorados; isso não cancela o transporte HTTP. O cliente tem timeout e seu ciclo de vida pertence ao bootstrap. Uma falha de tradução da sinopse preserva os detalhes localizados já obtidos.

Referências: [recomendações de arquitetura Flutter](https://docs.flutter.dev/app-architecture/recommendations) e [conceitos do Bloc](https://bloclibrary.dev/bloc-concepts/).
