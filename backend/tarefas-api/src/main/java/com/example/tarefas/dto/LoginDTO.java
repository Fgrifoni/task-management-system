package com.example.tarefas.dto;

public class LoginDTO {

    private String email;

    private String senha;

    public LoginDTO() {
    }

    public String getEmail() {
        return email;
    }

    public String getSenha() {
        return senha;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }
}