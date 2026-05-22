package com.example.tarefas.dto;

public class TarefaResumoDTO {

    private long pendentes;
    private long emAndamento;
    private long concluidas;

    public TarefaResumoDTO(long pendentes, long emAndamento, long concluidas) {
        this.pendentes = pendentes;
        this.emAndamento = emAndamento;
        this.concluidas = concluidas;
    }

    public long getPendentes() {
        return pendentes;
    }

    public long getEmAndamento() {
        return emAndamento;
    }

    public long getConcluidas() {
        return concluidas;
    }
}