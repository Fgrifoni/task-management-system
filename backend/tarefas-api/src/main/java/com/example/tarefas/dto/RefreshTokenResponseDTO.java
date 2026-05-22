package com.example.tarefas.dto;

public class RefreshTokenResponseDTO {

    private String accessToken;

    public RefreshTokenResponseDTO(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getAccessToken() {
        return accessToken;
    }
}