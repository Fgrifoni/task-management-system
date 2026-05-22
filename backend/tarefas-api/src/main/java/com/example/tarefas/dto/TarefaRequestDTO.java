package com.example.tarefas.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class TarefaRequestDTO {

    @NotBlank(message = "Título obrigatório")
    private String titulo;

    @NotBlank(message = "Descrição obrigatória")
    private String descricao;

    @NotNull(message = "ID do criador obrigatório")
    //private Long criadorId;

    public String getTitulo() {
        return titulo;
    }

    public String getDescricao() {
        return descricao;
    }

    //public Long getCriadorId() {
        //return criadorId;
    //}

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    //public void setCriadorId(Long criadorId) {
        //this.criadorId = criadorId;
   // }
}
