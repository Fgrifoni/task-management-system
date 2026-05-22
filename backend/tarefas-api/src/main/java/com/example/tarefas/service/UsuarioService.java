package com.example.tarefas.service;

import com.example.tarefas.dto.UsuarioRequestDTO;
import com.example.tarefas.dto.UsuarioResponseDTO;
import com.example.tarefas.model.Usuario;
import com.example.tarefas.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import com.example.tarefas.exception.RecursoNaoEncontradoException;

import java.util.List;

@Service
public class UsuarioService {

    private final UsuarioRepository repository;

    public UsuarioService(
            UsuarioRepository repository,
            BCryptPasswordEncoder passwordEncoder
    ) {

        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    public UsuarioResponseDTO salvar(UsuarioRequestDTO dto) {

        Usuario usuario = new Usuario();

        usuario.setNome(dto.getNome());
        usuario.setEmail(dto.getEmail());
        usuario.setSenha(
                passwordEncoder.encode(dto.getSenha())
        );

        Usuario salvo = repository.save(usuario);

        return new UsuarioResponseDTO(
                salvo.getId(),
                salvo.getNome(),
                salvo.getEmail()
        );
    }

    public List<Usuario> listar() {
        return repository.findAll();
    }

    public Usuario buscarPorId(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário não encontrado"));
    }
    private final BCryptPasswordEncoder passwordEncoder;
}