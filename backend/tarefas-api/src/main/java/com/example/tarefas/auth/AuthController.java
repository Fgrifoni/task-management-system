package com.example.tarefas.auth;

import com.example.tarefas.dto.LoginDTO;
import com.example.tarefas.model.Usuario;
import com.example.tarefas.repository.UsuarioRepository;
import com.example.tarefas.security.JWTService;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import com.example.tarefas.exception.RecursoNaoEncontradoException;
import com.example.tarefas.exception.RegraNegocioException;
import com.example.tarefas.dto.AuthResponseDTO;
import com.example.tarefas.dto.RefreshTokenResponseDTO;



@RestController
@RequestMapping("/auth")
public class AuthController {

    private final UsuarioRepository repository;

    private final JWTService jwtService;

    private final BCryptPasswordEncoder passwordEncoder;

    public AuthController(
            UsuarioRepository repository,
            JWTService jwtService,
            BCryptPasswordEncoder passwordEncoder
    ) {

        this.repository = repository;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/login")
    public AuthResponseDTO login(
            @RequestBody LoginDTO dto
    ) {

        Usuario usuario = repository.findByEmail(dto.getEmail())
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        if (!passwordEncoder.matches(
                dto.getSenha(),
                usuario.getSenha()
        )) {
            throw new RegraNegocioException("Senha inválida");
        }

        String accessToken =
                jwtService.gerarToken(usuario.getEmail());

        String refreshToken =
                jwtService.gerarRefreshToken(usuario.getEmail());

        return new AuthResponseDTO(
                accessToken,
                refreshToken
        );
    }

    @PostMapping("/refresh")
    public RefreshTokenResponseDTO refresh(
            @RequestHeader("Authorization") String authorization
    ) {

        if (authorization == null
                || !authorization.startsWith("Bearer ")) {

            throw new RegraNegocioException(
                    "Refresh token não enviado"
            );
        }

        String refreshToken =
                authorization.replace("Bearer ", "");

        if (!jwtService.refreshTokenValido(refreshToken)) {
            throw new RegraNegocioException(
                    "Refresh token inválido"
            );
        }

        String email =
                jwtService.getEmailDoToken(refreshToken);

        String novoAccessToken =
                jwtService.gerarToken(email);

        return new RefreshTokenResponseDTO(
                novoAccessToken
        );
    }
}
