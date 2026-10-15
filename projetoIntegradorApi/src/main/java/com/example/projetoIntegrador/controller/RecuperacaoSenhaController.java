package com.example.projetoIntegrador.controller;

import com.example.projetoIntegrador.service.RecuperacaoSenhaService;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import java.util.Map;

@RestController
@RequestMapping("/auth/recuperacao")
public class RecuperacaoSenhaController {
    private final RecuperacaoSenhaService service;
    public RecuperacaoSenhaController(RecuperacaoSenhaService service) { this.service = service; }
    public record Solicitar(String email) {}
    public record ValidarCodigo(String email, String codigo) {}
    public record Redefinir(String email, String codigo, String novaSenha) {}

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, Object>> erroRecuperacao(ResponseStatusException erro) {
        return ResponseEntity.status(erro.getStatusCode()).body(Map.of(
            "sucesso", false,
            "message", erro.getReason() == null ? "Não foi possível concluir a recuperação." : erro.getReason()
        ));
    }
    @PostMapping("/solicitar")
    public Map<String, Object> solicitar(@RequestBody Solicitar req) {
        service.solicitar(req.email());
        return Map.of("sucesso", true, "mensagem", "Se o e-mail estiver cadastrado, você receberá um código.");
    }

    @PostMapping("/validar-codigo")
    public Map<String, Object> validarCodigo(@RequestBody ValidarCodigo req) {
        service.validarCodigo(req.email(), req.codigo());
        return Map.of("sucesso", true);
    }
    @PostMapping("/redefinir")
    public Map<String, Object> redefinir(@RequestBody Redefinir req) {
        service.redefinir(req.email(), req.codigo(), req.novaSenha());
        return Map.of("sucesso", true);
    }
}