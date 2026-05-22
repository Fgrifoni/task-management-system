package com.example.tarefas.dto;

import com.example.tarefas.model.StatusTarefa;

import java.time.LocalDateTime;
import java.util.List;

public class TarefaResponseDTO {

    private Long id;
    private String titulo;
    private String descricao;
    private StatusTarefa status;
    private Long criadorId;
    private String criadorNome;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private List<UsuarioResumoDTO> compartilhados;

    public TarefaResponseDTO(
            Long id,
            String titulo,
            String descricao,
            StatusTarefa status,
            Long criadorId,
            String criadorNome,
            LocalDateTime createdAt,
            LocalDateTime updatedAt,
            List<UsuarioResumoDTO> compartilhados
    ) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.status = status;
        this.criadorId = criadorId;
        this.criadorNome = criadorNome;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.compartilhados = compartilhados;
    }

    public Long getId() {
        return id;
    }

    public String getTitulo() {
        return titulo;
    }

    public String getDescricao() {
        return descricao;
    }

    public StatusTarefa getStatus() {
        return status;
    }

    public Long getCriadorId() {
        return criadorId;
    }

    public String getCriadorNome() {
        return criadorNome;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<UsuarioResumoDTO> getCompartilhados() {
        return compartilhados;
    }
}