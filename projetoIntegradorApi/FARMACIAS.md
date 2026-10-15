# Busca de farmácias

O mobile usa https://farmagrid.onrender.com (ApiConfig.baseUrl).
Alterar os arquivos Java locais ou reiniciar o Flutter não altera a API publicada.
Publique a revisão no serviço Java correspondente no Render; não é preciso
recriar o banco nem alterar as credenciais do Brevo.

1. Envie as alterações ao repositório/branch configurado no serviço Render.
2. Em Manual Deploy, publique a revisão mais recente (ou acompanhe o deploy automático).
3. Aguarde o deploy concluir e abra Farmácias próximas no celular.
4. Confira cidade, estado (UF) e CEP nas configurações e salve.
5. Se persistir, veja os logs do serviço no horário da consulta. As mensagens
   'Busca de farmácias Nominatim indisponível' e 'Overpass indisponível' identificam
   o provedor que falhou. Os logs não incluem chaves nem endereço do paciente.

Fluxo: Google Places (se configurado) → busca de farmácias Nominatim → Overpass.
O teste de disponibilidade foi feito fora do Render; o deploy e a consulta
autenticada no ambiente publicado ainda devem ser verificados.

A busca usa a região do cadastro, não o GPS, e retorna até 15 resultados,
ordenados por distância entre os resultados recebidos. Não cobre necessariamente
todos os estabelecimentos da região. Sem chave Google, utiliza OpenStreetMap.
Opcional: GOOGLE_PLACES_API_KEY com Places API habilitada no projeto Google.

Configurações Spring: farmacias.geocoding-url, farmacias.poi-url,
farmacias.overpass-urls (separados por vírgula).
Nominatim: cache de 5 minutos, chamadas serializadas e intervalo mínimo de 1,1 s.
Em múltiplas instâncias da API, é necessário controle de limite compartilhado.
Política: https://operations.osmfoundation.org/policies/nominatim/
Busca por categoria: https://nominatim.org/release-docs/latest/api/Search/
