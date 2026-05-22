package com.example.tarefas.controller;

import com.example.tarefas.dto.TarefaRequestDTO;
import com.example.tarefas.dto.TarefaResponseDTO;
import com.example.tarefas.model.StatusTarefa;
import com.example.tarefas.model.Tarefa;
import com.example.tarefas.service.TarefaService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import com.example.tarefas.dto.TarefaResumoDTO;
import org.springframework.security.core.Authentication;


import java.util.List;

@RestController
@RequestMapping("/tarefas")
public class TarefaController {

    private final TarefaService service;

    public TarefaController(TarefaService service) {
        this.service = service;
    }

    @PostMapping
    public TarefaResponseDTO criar(
            @RequestBody @Valid TarefaRequestDTO dto,
            Authentication authentication
    ) {
        return service.criar(dto, authentication.getName());
    }

    @GetMapping
    public List<TarefaResponseDTO> listar() {
        return service.listar();
    }

    @PutMapping("/{id}/status")
    public TarefaResponseDTO atualizarStatus(
            @PathVariable Long id,
            @RequestParam StatusTarefa status,
            Authentication authentication
    ) {
        return service.atualizarStatus(id, status, authentication.getName());
    }

    @PutMapping("/{id}/compartilhar")
    public TarefaResponseDTO compartilhar(
            @PathVariable Long id,
            @RequestParam String email,
            Authentication authentication
    ) {
        return service.compartilhar(id, email, authentication.getName());
    }

    @PutMapping("/{id}")
    public TarefaResponseDTO editar(
            @PathVariable Long id,
            @RequestBody TarefaRequestDTO dto,
            Authentication authentication
    ) {
        return service.editar(
                id,
                dto,
                authentication.getName()
        );
    }

    @GetMapping("/minhas")
    public Page<TarefaResponseDTO> listarMinhas(

            org.springframework.security.core.Authentication authentication,

            @RequestParam(required = false)
            StatusTarefa status,

            @RequestParam(required = false)
            String texto,

            @RequestParam(defaultValue = "0")
            int page,

            @RequestParam(defaultValue = "5")
            int size,

            @RequestParam(defaultValue = "createdAt")
            String sortBy,

            @RequestParam(defaultValue = "desc")
            String direction
    ) {

        String email = authentication.getName();

        Sort sort = direction.equalsIgnoreCase("desc")
                ? Sort.by(sortBy).descending()
                : Sort.by(sortBy).ascending();

        Pageable pageable = PageRequest.of(page, size, sort);

        return service.listarMinhas(email, status, texto, pageable);
    }

    @DeleteMapping("/{id}")
    public void deletar(
            @PathVariable Long id,
            Authentication authentication
    ) {
        service.deletar(id, authentication.getName());
    }

    @PutMapping("/{id}/restaurar")
    public TarefaResponseDTO restaurar(
            @PathVariable Long id,
            Authentication authentication
    ) {
        return service.restaurar(id, authentication.getName());
    }

    @DeleteMapping("/{id}/compartilhar/{usuarioId}")
    public TarefaResponseDTO removerCompartilhamento(
            @PathVariable Long id,
            @PathVariable Long usuarioId,
            Authentication authentication
    ) {
        return service.removerCompartilhamento(
                id,
                usuarioId,
                authentication.getName()
        );
    }

    @GetMapping("/minhas/pendentes")
    public Page<TarefaResponseDTO> listarMinhasPendentes(
            Authentication authentication,

            @RequestParam(defaultValue = "0")
            int page,

            @RequestParam(defaultValue = "5")
            int size
    ) {

        String email = authentication.getName();

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by("createdAt").descending()
        );

        return service.listarMinhas(
                email,
                StatusTarefa.PENDENTE,
                null,
                pageable
        );
    }

    @GetMapping("/minhas/resumo")
    public TarefaResumoDTO resumo(Authentication authentication) {

        String email = authentication.getName();

        return service.resumo(email);
    }

    @GetMapping("/deletadas")
    public Page<TarefaResponseDTO> listarDeletadas(
            Authentication authentication,

            @RequestParam(defaultValue = "0")
            int page,

            @RequestParam(defaultValue = "20")
            int size
    ) {
        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by("updatedAt").descending()
        );

        return service.listarDeletadas(
                authentication.getName(),
                pageable
        );
    }
}