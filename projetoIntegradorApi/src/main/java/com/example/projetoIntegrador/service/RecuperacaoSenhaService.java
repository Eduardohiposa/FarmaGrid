package com.example.projetoIntegrador.service;

import com.example.projetoIntegrador.repository.LoginRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.time.Duration;
import java.util.*;

@Service
public class RecuperacaoSenhaService {
    private final LoginRepository logins;
    private final PasswordEncoder encoder;
    private final String apiKey;
    private final String remetente;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, Desafio> desafios = new HashMap<>();
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();

    private static class Desafio {
        byte[] hash;
        long criado;
        int tentativas;
        Desafio(byte[] hash, long criado) { this.hash = hash; this.criado = criado; }
    }

    public RecuperacaoSenhaService(LoginRepository logins, PasswordEncoder encoder,
            @Value("${BREVO_API_KEY:}") String apiKey,
            @Value("${BREVO_SENDER_EMAIL:}") String remetente) {
        this.logins = logins;
        this.encoder = encoder;
        this.apiKey = apiKey;
        this.remetente = remetente;
    }

    private String email(String valor) {
        if (valor == null || valor.length() > 100 || !valor.trim().matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+"))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Informe um e-mail válido.");
        return valor.trim().toLowerCase(Locale.ROOT);
    }

    private byte[] hash(String codigo) {
        try {
            return MessageDigest.getInstance("SHA-256").digest(codigo.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) { throw new IllegalStateException(e); }
    }

    public synchronized void solicitar(String valor) {
        String email = email(valor);
        long agora = System.currentTimeMillis();
        desafios.entrySet().removeIf(e -> agora - e.getValue().criado >= 600_000);
        Desafio anterior = desafios.get(email);
        if (anterior != null && agora - anterior.criado < 60_000)
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Aguarde um minuto para solicitar outro código.");
        if (apiKey.isBlank() || remetente.isBlank())
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Envio de e-mail ainda não configurado.");
        if (desafios.size() >= 10000)
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Tente novamente mais tarde.");
        String codigo = String.format(Locale.ROOT, "%06d", random.nextInt(1000000));
        Desafio desafio = new Desafio(hash(codigo), agora);
        desafios.put(email, desafio);
        if (logins.findAllByEmailIgnoreCase(email).isEmpty()) return;
        try {
            String body = new ObjectMapper().writeValueAsString(Map.of(
                "sender", Map.of("name", "FarmaGrid", "email", remetente),
                "to", List.of(Map.of("email", email)),
                "subject", "Código de recuperação de senha - FarmaGrid",
                "htmlContent", montarEmailHtml(codigo),
                "textContent", "Seu código de recuperação é: " + codigo +
                    ". Ele expira em 10 minutos. Se você não solicitou, ignore este e-mail."));
            HttpRequest request = HttpRequest.newBuilder(URI.create("https://api.brevo.com/v3/smtp/email"))
                .timeout(Duration.ofSeconds(20))
                .header("api-key", apiKey).header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body)).build();
            HttpResponse<Void> response = http.send(request, HttpResponse.BodyHandlers.discarding());
            if (response.statusCode() < 200 || response.statusCode() >= 300)
                throw new IllegalStateException("Brevo HTTP " + response.statusCode());
        } catch (Exception e) {
            desafios.remove(email);
            if (e instanceof InterruptedException) Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Não foi possível enviar o código. Tente novamente.");
        }
    }

    private String montarEmailHtml(String codigo) {
        StringBuilder quadradinhos = new StringBuilder();
        for (int i = 0; i < codigo.length(); i++) {
            if (i > 0) quadradinhos.append("<td width=\"8\" style=\"width:8px;\"></td>");
            quadradinhos.append("<td align=\"center\" width=\"36\" height=\"52\" "
                + "style=\"width:36px;height:52px;border:1px solid #b9d8bb;border-radius:10px;"
                + "background-color:#f0f7f0;color:#355e3b;font-family:Arial,sans-serif;"
                + "font-size:26px;font-weight:700;line-height:52px;\">")
                .append(codigo.charAt(i)).append("</td>");
        }
        return """
            <!DOCTYPE html>
            <html lang="pt-BR">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Recuperação de senha | FarmaGrid</title>
            </head>
            <body style="margin:0;padding:0;background-color:#f0f5ef;color:#2e462e;font-family:Arial,Helvetica,sans-serif;">
              <div style="display:none;max-height:0;overflow:hidden;mso-hide:all;">Seu código FarmaGrid chegou. Ele é válido por 10 minutos.</div>
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f5ef;">
                <tr><td align="center" style="padding:32px 12px;">
                  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background-color:#ffffff;border:1px solid #dce8db;border-radius:20px;">
                    <tr><td style="padding:28px 24px;border-bottom:1px solid #e6eee4;">
                      <span style="font-size:28px;font-weight:700;letter-spacing:0.5px;color:#355e3b;">FarmaGrid<span style="color:#4ba94b;">+</span></span>
                      <p style="margin:6px 0 0;font-size:12px;color:#647664;">Cuidado em cada conexão.</p>
                    </td></tr>
                    <tr><td style="padding:30px 24px 12px;">
                      <p style="margin:0 0 12px;font-size:11px;font-weight:700;letter-spacing:1.5px;color:#397c39;">RECUPERAÇÃO DE SENHA</p>
                      <h1 style="margin:0 0 14px;font-size:26px;line-height:1.3;color:#2e462e;">Vamos recuperar seu acesso?</h1>
                      <p style="margin:0;font-size:15px;line-height:1.7;color:#5c6c5c;">Recebemos uma solicitação para alterar sua senha. Digite o código abaixo na tela de recuperação do FarmaGrid para continuar.</p>
                    </td></tr>
                    <tr><td align="center" style="padding:20px 12px 12px;">
                      <table role="presentation" cellpadding="0" cellspacing="0" align="center"><tr>
            """ + quadradinhos + """
                      </tr></table>
                      <p style="margin:18px 0 0;font-size:13px;color:#647664;">Este código expira em <strong style="color:#355e3b;">10 minutos</strong>.</p>
                    </td></tr>
                    <tr><td style="padding:20px 24px 30px;">
                      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f8f3;border-radius:10px;">
                        <tr><td style="padding:16px;font-size:13px;line-height:1.7;color:#5c6c5c;">
                          <strong style="color:#355e3b;">Mantenha seu acesso seguro</strong><br>
                          Não compartilhe este código com ninguém. Se você não solicitou a alteração, ignore este e-mail. Sua senha continuará a mesma.
                        </td></tr>
                      </table>
                    </td></tr>
                  </table>
                  <p style="margin:20px 0 0;font-size:12px;line-height:1.6;color:#748174;">FarmaGrid+ &bull; E-mail automático, não responda.</p>
                </td></tr>
              </table>
            </body>
            </html>
            """;
    }

    public synchronized void redefinir(String valor, String codigo, String novaSenha) {
        String email = email(valor);
        if (novaSenha == null || novaSenha.length() < 6 || novaSenha.getBytes(StandardCharsets.UTF_8).length > 72)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Use uma senha de pelo menos 6 caracteres e até 72 bytes.");
        Desafio desafio = desafios.get(email);
        if (desafio == null || System.currentTimeMillis() - desafio.criado >= 600_000 || desafio.tentativas >= 5) {
            desafios.remove(email);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Código inválido ou expirado. Solicite outro.");
        }
        desafio.tentativas++;
        if (codigo == null || !codigo.matches("[0-9]{6}") || !MessageDigest.isEqual(desafio.hash, hash(codigo)))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Código inválido ou expirado.");
        var contas = logins.findAllByEmailIgnoreCase(email);
        if (contas.isEmpty())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Código inválido ou expirado.");
        String senhaHash = encoder.encode(novaSenha);
        contas.forEach(login -> login.setSenha(senhaHash));
        logins.saveAllAndFlush(contas);
        desafios.remove(email);
    }
}