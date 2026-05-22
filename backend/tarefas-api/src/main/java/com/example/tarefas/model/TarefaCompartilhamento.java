package com.example.tarefas.model;

import jakarta.persistence.*;

@Entity
public class TarefaCompartilhamento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Tarefa tarefa;

    @ManyToOne
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    private PermissaoTarefa permissao;

    public TarefaCompartilhamento() {
    }

    public TarefaCompartilhamento(
            Tarefa tarefa,
            Usuario usuario,
            PermissaoTarefa permissao
    ) {
        this.tarefa = tarefa;
        this.usuario = usuario;
        this.permissao = permissao;
    }

    public Long getId() {
        return id;
    }

    public Tarefa getTarefa() {
        return tarefa;
    }

    public void setTarefa(Tarefa tarefa) {
        this.tarefa = tarefa;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public PermissaoTarefa getPermissao() {
        return permissao;
    }

    public void setPermissao(PermissaoTarefa permissao) {
        this.permissao = permissao;
    }
}