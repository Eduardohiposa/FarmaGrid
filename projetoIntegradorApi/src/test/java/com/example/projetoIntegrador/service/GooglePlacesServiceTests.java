package com.example.projetoIntegrador.service;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.*;
import org.springframework.test.util.ReflectionTestUtils;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicInteger;
import static org.junit.jupiter.api.Assertions.*;

class GooglePlacesServiceTests {
    private HttpServer server;
    private GooglePlacesService service;
    private String url;
    private final AtomicInteger geocodificacoes = new AtomicInteger();
    private String geo = "[{\"lat\":\"-23.55\",\"lon\":\"-46.63\"}]";
    private String poi = "{}";
    private final AtomicInteger overpassChamadas = new AtomicInteger();
    private String osm = """
        {"elements":[
          {"type":"node","id":1,"lat":-23.56,"lon":-46.63,"tags":{"name":"Mais distante","opening_hours":"Mo-Fr 08:00-18:00"}},
          {"type":"way","id":2,"center":{"lat":-23.5501,"lon":-46.63},"tags":{"name":"Próxima","opening_hours":"24/7"}},
          {"type":"node","id":3,"lat":-23.55011,"lon":-46.63,"tags":{"name":"Próxima"}},
          {"type":"relation","id":4,"center":{"lat":-23.5505,"lon":-46.63},"tags":{"brand":"Rede","opening_hours":"PH off"}},
          {"type":"node","id":5,"lat":-24.55,"lon":-46.63,"tags":{"name":"Fora do raio"}}
        ]}
        """;

    @BeforeEach void iniciar() throws Exception {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/", exchange -> {
            String path = exchange.getRequestURI().getPath();
            int status = path.equals("/falha") || path.equals("/google") ? 503 : 200;
            String body = switch (path) {
                case "/geo" -> { geocodificacoes.incrementAndGet(); yield geo; }
                case "/osm" -> { overpassChamadas.incrementAndGet(); yield osm; }
                case "/poi" -> poi;
                default -> "{}";
            };
            byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(status, bytes.length);
            try (var out = exchange.getResponseBody()) { out.write(bytes); }
        });
        server.start();
        url = "http://127.0.0.1:" + server.getAddress().getPort();
        service = new GooglePlacesService();
        ReflectionTestUtils.setField(service, "apiKey", "chave-teste");
        ReflectionTestUtils.setField(service, "googleUrl", url + "/google");
        ReflectionTestUtils.setField(service, "geocodingUrl", url + "/geo");
        ReflectionTestUtils.setField(service, "poiUrl", url + "/poi");
        ReflectionTestUtils.setField(service, "overpassUrls", url + "/falha," + url + "/osm");
    }

    @AfterEach void parar() { server.stop(0); }

    @Test void usaAlternativasOrdenaRemoveDuplicadosEReaproveitaCache() throws Exception {
        var resultado = service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000");
        assertEquals(3, resultado.size());
        assertEquals("Próxima", resultado.get(0).get("nome"));
        assertEquals(true, resultado.get(0).get("aberto"));
        assertEquals("Rede", resultado.get(1).get("nome"));
        assertNull(resultado.get(1).get("aberto"));
        assertNull(resultado.get(2).get("aberto"));
        assertTrue(((Number) resultado.get(0).get("distanciaMetros")).doubleValue() <
            ((Number) resultado.get(2).get("distanciaMetros")).doubleValue());
        assertEquals(resultado, service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000"));
        assertEquals(1, geocodificacoes.get());
    }

    @Test void naoTrataErroDoOverpassComoListaVazia() {
        osm = "{\"remark\":\"runtime error: timeout\",\"elements\":[]}";
        assertThrows(IllegalStateException.class,
            () -> service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000"));
    }

    @Test void aceitaListaVaziaValida() throws Exception {
        osm = "{\"elements\":[]}";
        assertTrue(service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000").isEmpty());
    }

    @Test void enderecoNaoEncontradoTemMensagemUtil() {
        geo = "[]";
        var erro = assertThrows(IllegalStateException.class,
            () -> service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000"));
        assertTrue(erro.getMessage().contains("Endereço não localizado"));
    }

    @Test void rejeitaEnderecoVazioSemConsultarProvedor() {
        assertThrows(IllegalStateException.class, () -> service.buscarFarmacias(""));
        assertEquals(0, geocodificacoes.get());
    }

    @Test void buscaFarmaciasSemDependerDoOverpass() throws Exception {
        poi = """
            [{"osm_type":"node","osm_id":42,"type":"pharmacy","lat":"-23.5501","lon":"-46.6301",
              "name":"Farmácia alternativa","address":{"road":"Rua Teste","house_number":"10","city":"São Paulo"},
              "extratags":{"opening_hours":"24/7"}}]
            """;
        var resultado = service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000");
        assertEquals(1, resultado.size());
        assertEquals("Farmácia alternativa", resultado.get(0).get("nome"));
        assertEquals(true, resultado.get(0).get("aberto"));
        assertEquals("Rua Teste, 10, São Paulo", resultado.get(0).get("endereco"));
        assertEquals(0, overpassChamadas.get());
    }

    @Test void buscaAlternativaVaziaValidaNaoEIndisponibilidade() throws Exception {
        poi = "[]";
        assertTrue(service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000").isEmpty());
        assertEquals(0, overpassChamadas.get());
    }

    @Test void coordenadasInvalidasNaoSaoAceitasComoResultados() throws Exception {
        poi = """
            [{"type":"pharmacy","lat":"invalido","lon":"-46.63"}]
            """;
        assertEquals(3, service.buscarFarmacias("Rua, 1, Centro, São Paulo, SP, 01001000").size());
        assertEquals(1, overpassChamadas.get());
    }
}
