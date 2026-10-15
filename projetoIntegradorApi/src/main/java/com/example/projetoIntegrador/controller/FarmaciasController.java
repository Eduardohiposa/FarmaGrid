package com.example.projetoIntegrador.controller;

import com.example.projetoIntegrador.model.Paciente;
import com.example.projetoIntegrador.repository.PacienteRepository;
import com.example.projetoIntegrador.service.GooglePlacesService;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController @RequestMapping("/api")
public class FarmaciasController {
    private final PacienteRepository pacientes; private final GooglePlacesService google;
    public FarmaciasController(PacienteRepository pacientes, GooglePlacesService google) { this.pacientes = pacientes; this.google = google; }
    @GetMapping("/pacientes/{id}/farmacias-proximas")
    public ResponseEntity<?> proximas(@PathVariable Long id) {
        Paciente p = pacientes.findById(id).orElse(null);
        if (p == null) return ResponseEntity.notFound().build();
        String numero = p.getNumCasa() == null ? null : p.getNumCasa().toString();
        String endereco = String.join(", ", java.util.stream.Stream.of(
            p.getRua(), numero, p.getBairro(), p.getCidade(), p.getEstado(), p.getCep()
        ).filter(v -> v != null && !v.isBlank()).toList());
        if (p.getCidade() == null || p.getCidade().isBlank() || p.getEstado() == null || p.getEstado().isBlank()) return ResponseEntity.badRequest().body("Complete seu endereço nas configurações.");
        try { return ResponseEntity.ok(google.buscarFarmacias(endereco)); }
        catch (IllegalStateException e) { return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(e.getMessage()); }
        catch (Exception e) { return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body("Não foi possível consultar as farmácias. Tente novamente."); }
    }
}
