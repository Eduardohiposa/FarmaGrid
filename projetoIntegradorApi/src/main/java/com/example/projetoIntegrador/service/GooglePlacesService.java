package com.example.projetoIntegrador.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.net.http.*;
import java.time.Duration;
import java.util.*;

@Service
public class GooglePlacesService {
    @Value("${google.places.api-key:}") private String apiKey;
    @Value("${farmacias.google-url:https://places.googleapis.com/v1/places:searchText}")
    private String googleUrl = "https://places.googleapis.com/v1/places:searchText";
    @Value("${farmacias.geocoding-url:https://nominatim.openstreetmap.org/search}")
    private String geocodingUrl = "https://nominatim.openstreetmap.org/search";
    @Value("${farmacias.overpass-urls:https://overpass-api.de/api/interpreter,https://overpass.private.coffee/api/interpreter}")
    private String overpassUrls = "https://overpass-api.de/api/interpreter,https://overpass.private.coffee/api/interpreter";
    private final ObjectMapper mapper = new ObjectMapper();
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final Map<String, Cache> cache = new LinkedHashMap<>();
    private long ultimaGeocodificacao;
    private record Cache(long instante, List<Map<String, Object>> dados) {}

    // Serializa consultas, limita o Nominatim a 1/s e reaproveita resultados por 10 minutos.
    public synchronized List<Map<String, Object>> buscarFarmacias(String endereco) throws Exception {
        if (endereco == null || endereco.isBlank()) throw new IllegalStateException("Complete seu endereço nas configurações.");
        String chave = endereco.trim().toLowerCase(Locale.ROOT);
        Cache anterior = cache.get(chave);
        if (anterior != null && System.currentTimeMillis() - anterior.instante() < 300_000) return anterior.dados();
        List<Map<String, Object>> resultado = null;
        if (apiKey != null && !apiKey.isBlank()) {
            try {
                resultado = buscarGoogle(endereco);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw e;
            } catch (Exception e) {
                // Credencial inválida, cota ou indisponibilidade: tenta o provedor alternativo.
            }
        }
        if (resultado == null || resultado.isEmpty()) resultado = buscarOpenStreetMap(endereco);
        if (cache.size() >= 256) cache.remove(cache.keySet().iterator().next());
        cache.put(chave, new Cache(System.currentTimeMillis(), resultado));
        return resultado;
    }

    private List<Map<String, Object>> buscarGoogle(String endereco) throws Exception {
        String body = mapper.writeValueAsString(Map.of(
            "textQuery", "farmácias próximas de " + endereco,
            "includedType", "pharmacy", "languageCode", "pt-BR", "pageSize", 15
        ));
        HttpRequest request = requisicao(googleUrl, 8)
            .header("Content-Type", "application/json").header("X-Goog-Api-Key", apiKey)
            .header("X-Goog-FieldMask", "places.id,places.displayName,places.formattedAddress,places.location,places.currentOpeningHours,places.googleMapsUri")
            .POST(HttpRequest.BodyPublishers.ofString(body)).build();
        JsonNode places = consultar(request).path("places");
        List<Map<String, Object>> result = new ArrayList<>();
        for (JsonNode p : places) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", p.path("id").asText());
            item.put("nome", p.path("displayName").path("text").asText("Farmácia"));
            item.put("endereco", p.path("formattedAddress").asText("Endereço não informado"));
            item.put("latitude", p.path("location").path("latitude").asDouble());
            item.put("longitude", p.path("location").path("longitude").asDouble());
            JsonNode horas = p.path("currentOpeningHours");
            item.put("aberto", horas.path("openNow").isBoolean() ? horas.path("openNow").asBoolean() : null);
            List<String> descricoes = new ArrayList<>();
            horas.path("weekdayDescriptions").forEach(d -> descricoes.add(d.asText()));
            item.put("horario", descricoes.isEmpty() ? "Horário não informado" : String.join(" • ", descricoes));
            item.put("fonte", "Google Places");
            item.put("googleMapsUri", p.path("googleMapsUri").asText());
            result.add(item);
        }
        return result;
    }

    private List<Map<String, Object>> buscarOpenStreetMap(String endereco) throws Exception {
        JsonNode geo = geocodificar(endereco);
        double lat = geo.path("lat").asDouble(), lon = geo.path("lon").asDouble();
        String consulta = "[out:json][timeout:15];(nwr[amenity=pharmacy](around:10000,"
            + lat + "," + lon + ");nwr[shop=chemist](around:10000," + lat + "," + lon + "););out center tags;";
        JsonNode elementos = null;
        for (String endpoint : overpassUrls.split(",")) {
            try {
                JsonNode resposta = consultar(requisicao(endpoint.trim(), 20)
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString("data=" + URLEncoder.encode(consulta, StandardCharsets.UTF_8))).build());
                // Overpass pode devolver HTTP 200 com erro/timeout; isso não é uma lista vazia.
                if (!resposta.path("elements").isArray() || resposta.has("remark")) throw new IllegalStateException("Consulta de farmácias indisponível.");
                elementos = resposta.path("elements");
                break;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw e;
            } catch (Exception e) {
                // Tenta a próxima instância antes de informar indisponibilidade.
            }
        }
        if (elementos == null) throw new IllegalStateException("O serviço de farmácias está indisponível. Tente novamente em alguns instantes.");
        List<Map<String, Object>> result = new ArrayList<>();
        for (JsonNode p : elementos) {
            JsonNode tags = p.path("tags");
            JsonNode posicao = p.has("lat") ? p : p.path("center");
            if (!posicao.has("lat") || !posicao.has("lon")) continue;
            double latitude = posicao.path("lat").asDouble(), longitude = posicao.path("lon").asDouble();
            double distancia = distancia(lat, lon, latitude, longitude);
            if (distancia > 10_000) continue;
            String nome = tags.path("name").asText(tags.path("brand").asText("Farmácia"));
            boolean duplicado = result.stream().anyMatch(item ->
                nome.equalsIgnoreCase(item.get("nome").toString()) &&
                distancia(latitude, longitude, ((Number)item.get("latitude")).doubleValue(),
                    ((Number)item.get("longitude")).doubleValue()) < 40);
            if (duplicado) continue;
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", "osm-" + p.path("type").asText() + "-" + p.path("id").asText());
            item.put("nome", nome);
            item.put("latitude", latitude); item.put("longitude", longitude);
            item.put("distanciaMetros", Math.round(distancia));
            String horario = tags.path("opening_hours").asText("");
            // Regras OSM complexas não podem ser interpretadas como 'fechada'.
            item.put("aberto", "24/7".equals(horario.trim()) ? Boolean.TRUE : null);
            item.put("horario", horario.isBlank() ? "Horário não informado" : horario);
            item.put("endereco", montarEndereco(tags));
            item.put("fonte", "OpenStreetMap");
            item.put("googleMapsUri", "https://www.google.com/maps/search/?api=1&query=" + latitude + "," + longitude);
            result.add(item);
        }
        result.sort(Comparator.comparingDouble(item -> ((Number)item.get("distanciaMetros")).doubleValue()));
        return new ArrayList<>(result.subList(0, Math.min(15, result.size())));
    }

    private JsonNode geocodificar(String endereco) throws Exception {
        List<String> partes = Arrays.stream(endereco.split(",")).map(String::trim).filter(v -> !v.isBlank()).toList();
        LinkedHashSet<String> consultas = new LinkedHashSet<>();
        // Usa CEP e bairro/cidade como referência aproximada, sem rua/número residencial.
        partes.stream().filter(v -> v.matches("\\d{5}-?\\d{3}")).findFirst()
            .ifPresent(cep -> consultas.add(cep + ", Brasil"));
        List<String> regiao = partes.stream().filter(v -> !v.matches("\\d{5}-?\\d{3}")).toList();
        if (regiao.size() >= 3) consultas.add(String.join(", ", regiao.subList(regiao.size() - 3, regiao.size())) + ", Brasil");
        if (regiao.size() >= 2) consultas.add(String.join(", ", regiao.subList(regiao.size() - 2, regiao.size())) + ", Brasil");
        if (consultas.isEmpty()) consultas.add(endereco);
        boolean respondeu = false;
        for (String consulta : consultas) {
            long esperar = 1100 - (System.currentTimeMillis() - ultimaGeocodificacao);
            if (esperar > 0) Thread.sleep(esperar);
            ultimaGeocodificacao = System.currentTimeMillis();
            try {
                String separador = geocodingUrl.contains("?") ? "&" : "?";
                JsonNode resposta = consultar(requisicao(geocodingUrl + separador
                    + "format=json&limit=1&countrycodes=br&q="
                    + URLEncoder.encode(consulta, StandardCharsets.UTF_8), 6).GET().build());
                if (!resposta.isArray()) continue;
                respondeu = true;
                if (!resposta.isEmpty() && resposta.get(0).has("lat") && resposta.get(0).has("lon")) return resposta.get(0);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw e;
            } catch (Exception e) {
                // Tenta uma referência menos específica.
            }
        }
        throw new IllegalStateException(respondeu
            ? "Endereço não localizado. Confira cidade, estado e CEP nas configurações."
            : "O serviço de localização está indisponível. Tente novamente em alguns instantes.");
    }

    private HttpRequest.Builder requisicao(String url, int segundos) {
        return HttpRequest.newBuilder(URI.create(url)).timeout(Duration.ofSeconds(segundos))
            .header("User-Agent", "FarmaGrid/1.0").header("Accept", "application/json").header("Accept-Language", "pt-BR");
    }

    private JsonNode consultar(HttpRequest request) throws Exception {
        HttpResponse<String> resposta = client.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        if (resposta.statusCode() / 100 != 2) throw new IllegalStateException("Provedor temporariamente indisponível.");
        return mapper.readTree(resposta.body());
    }

    private String montarEndereco(JsonNode tags) {
        String endereco = java.util.stream.Stream.of("addr:street", "addr:housenumber", "addr:suburb", "addr:city")
            .map(campo -> tags.path(campo).asText()).filter(v -> !v.isBlank())
            .collect(java.util.stream.Collectors.joining(", "));
        return endereco.isBlank() ? "Endereço não informado" : endereco;
    }

    private double distancia(double lat1, double lon1, double lat2, double lon2) {
        double dlat = Math.toRadians(lat2 - lat1), dlon = Math.toRadians(lon2 - lon1);
        double a = Math.pow(Math.sin(dlat / 2), 2)
            + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.pow(Math.sin(dlon / 2), 2);
        return 6_371_000 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(Math.max(0, 1 - a)));
    }
}
