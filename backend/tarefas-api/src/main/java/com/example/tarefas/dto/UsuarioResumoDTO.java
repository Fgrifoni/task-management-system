package com.example.tarefas.dto;

public class UsuarioResumoDTO {

    private Long id;
    private String nome;
    private String email;

    public UsuarioResumoDTO(Long id, String nome, String email) {
        this.id = id;
        this.nome = nome;
        this.email = email;
    }

    public Long getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public String getEmail() {
        return email;
    }
}