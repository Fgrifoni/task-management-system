package com.example.tarefas.repository;

import com.example.tarefas.model.Tarefa;
import com.example.tarefas.model.TarefaCompartilhamento;
import com.example.tarefas.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TarefaCompartilhamentoRepository
        extends JpaRepository<TarefaCompartilhamento, Long> {

    List<TarefaCompartilhamento> findByTarefa(Tarefa tarefa);

    Optional<TarefaCompartilhamento>
    findByTarefaAndUsuario(
            Tarefa tarefa,
            Usuario usuario
    );
}