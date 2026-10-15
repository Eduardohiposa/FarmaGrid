# Carregamento e listas

O MaterialApp instala CamadaCarregamento sobre o Navigator, incluindo diálogos.
Carregamento.executar usa try/finally e identifica cada operação; requisições
simultâneas mantêm a camada aberta até a última finalizar. A camada bloqueia
toques, desfoca o fundo e anuncia a operação aos leitores de tela.

As listas de dados usam List<Objeto>, fromJson e ListView.builder com itemCount
e acesso por índice. Cartões, cores e seções existentes foram preservados.
Listas internas em páginas com seções usam shrinkWrap e deixam a rolagem para
a página. Opções de formulário e chips continuam como controles próprios.
A loja usa o estoque da API; falhas não são substituídas por produtos fictícios.

## Farmácias

Reinicie a API Java para aplicar a correção. A busca usa a região do cadastro,
não o GPS do celular. Google Places continua opcional por GOOGLE_PLACES_API_KEY.
Sem chave, com erro ou sem resultados, consulta OpenStreetMap/Overpass.
O fallback usa CEP, bairro, cidade e estado; a distância é aproximada.
Horários complexos OSM são mostrados sem afirmar que a farmácia está fechada.

Configurações Spring opcionais:
- farmacias.geocoding-url
- farmacias.overpass-urls (endpoints separados por vírgula)
- farmacias.google-url

O Nominatim público exige no máximo 1 requisição/segundo para toda a aplicação,
identificação e atribuição. O serviço serializa chamadas e mantém cache de
resultados por 5 minutos (até 256 endereços) em uma instância da API.
Em múltiplas instâncias, é necessário limite e cache compartilhados ou um
provedor dedicado. Política: https://operations.osmfoundation.org/policies/nominatim/
Atribuição OSM aparece na lista. Os provedores públicos podem ficar indisponíveis;
nesses casos o app oferece nova tentativa, sem apresentar falha como lista vazia.
