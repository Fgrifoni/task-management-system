package com.example.tarefas.dto;

public class AuthResponseDTO {

    private String accessToken;
    private String refreshToken;

    public AuthResponseDTO(
            String accessToken,
            String refreshToken
    ) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }
}