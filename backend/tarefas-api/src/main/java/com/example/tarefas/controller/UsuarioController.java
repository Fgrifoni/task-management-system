package com.example.tarefas.controller;

import com.example.tarefas.dto.UsuarioRequestDTO;
import com.example.tarefas.dto.UsuarioResponseDTO;
import com.example.tarefas.model.Usuario;
import com.example.tarefas.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    private final UsuarioService service;

    public UsuarioController(UsuarioService service) {
        this.service = service;
    }

    @PostMapping
    public UsuarioResponseDTO salvar(
            @RequestBody @Valid UsuarioRequestDTO dto
    ) {
        return service.salvar(dto);
    }

    @GetMapping
    public List<Usuario> listar() {
        return service.listar();
    }

    @GetMapping("/{id}")
    public Usuario buscar(@PathVariable Long id) {
        return service.buscarPorId(id);
    }
}
