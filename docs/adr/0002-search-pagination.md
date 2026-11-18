# Paginação da busca com ordem estável

Status: aceita em 2026-11-17.

A busca passa a preservar a ordem do TMDB e acrescentar páginas, em vez de reordenar os resultados por data. Reordenar toda a coleção após cada resposta deslocaria filmes já apresentados; ordenar apenas cada página também não garantiria uma ordenação global. Categorias e similares mantêm sua ordenação anterior.

O repositório retorna `MovieSearchPage`, sem tipos de JSON ou Flutter, com filmes e metadados de continuidade. O limite de 500 páginas acessíveis do TMDB é aplicado na camada de dados; a interface não depende desse detalhe do provedor. A filtragem local por ano pode remover todos os filmes de uma página, portanto ausência de itens visíveis não encerra a consulta enquanto houver páginas seguintes.

O Cubit coordena a consulta, impede cargas simultâneas, ignora respostas de gerações anteriores e mantém resultados durante falhas incrementais. A apresentação solicita mais dados perto do fim ou para completar uma tela curta, apenas quando a busca está ativa. O estado de falha incremental aguarda retry explícito para evitar loops de requisições.
