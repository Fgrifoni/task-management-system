package com.example.tarefas.repository;

import com.example.tarefas.model.StatusTarefa;
import com.example.tarefas.model.Tarefa;
import com.example.tarefas.model.Usuario;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TarefaRepository extends JpaRepository<Tarefa, Long> {

    List<Tarefa> findByDeletedFalse();

    Page<Tarefa> findByDeletedFalseAndCriador(
            Usuario criador,
            Pageable pageable
    );

    Page<Tarefa> findByDeletedFalseAndStatusAndCriador(
            StatusTarefa status,
            Usuario criador,
            Pageable pageable
    );

    long countByDeletedFalseAndStatusAndCriador(
            StatusTarefa status,
            Usuario criador
    );

    @Query("""
        SELECT DISTINCT t
        FROM Tarefa t
        LEFT JOIN t.compartilhamentos tc
        LEFT JOIN tc.usuario u
        WHERE t.deleted = false
        AND (
            t.criador = :usuario
            OR u = :usuario
        )
        AND (
            LOWER(t.titulo) LIKE LOWER(CONCAT('%', :texto, '%'))
            OR LOWER(t.descricao) LIKE LOWER(CONCAT('%', :texto, '%'))
        )
    """)
    Page<Tarefa> buscarMinhasPorTexto(
            @Param("usuario") Usuario usuario,
            @Param("texto") String texto,
            Pageable pageable
    );

    @Query("""
    SELECT DISTINCT t
    FROM Tarefa t
    LEFT JOIN t.compartilhamentos tc
    LEFT JOIN tc.usuario u
    WHERE t.deleted = false
    AND (
        t.criador = :usuario
        OR u = :usuario
    )
""")
    Page<Tarefa> buscarMinhas(
            Usuario usuario,
            Pageable pageable
    );

    @Query("""
    SELECT DISTINCT t
    FROM Tarefa t
    LEFT JOIN t.compartilhamentos tc
    LEFT JOIN tc.usuario u
    WHERE t.deleted = false
    AND t.status = :status
    AND (
        t.criador = :usuario
        OR u = :usuario
    )
""")
    Page<Tarefa> buscarMinhasPorStatus(
            Usuario usuario,
            StatusTarefa status,
            Pageable pageable
    );

    @Query("""
    SELECT DISTINCT t
    FROM Tarefa t
    LEFT JOIN t.compartilhamentos tc
    LEFT JOIN tc.usuario u
    WHERE t.deleted = false
    AND (
        t.criador = :usuario
        OR u = :usuario
    )
""")
    List<Tarefa> buscarMinhasSemPaginacao(
            Usuario usuario
    );

    Page<Tarefa> findByDeletedTrueAndCriador(
            Usuario criador,
            Pageable pageable
    );

    @Query("""
    SELECT DISTINCT t
    FROM Tarefa t
    LEFT JOIN t.compartilhamentos tc
    LEFT JOIN tc.usuario u
    WHERE t.deleted = false
    AND (
        t.criador = :usuario
        OR u = :usuario
    )
    AND (
        :status IS NULL
        OR t.status = :status
    )
    AND (
        :texto IS NULL
        OR :texto = ''
        OR LOWER(t.titulo) LIKE LOWER(CONCAT('%', :texto, '%'))
        OR LOWER(t.descricao) LIKE LOWER(CONCAT('%', :texto, '%'))
    )
""")
    Page<Tarefa> buscarMinhasComFiltros(
            Usuario usuario,
            StatusTarefa status,
            String texto,
            Pageable pageable
    );
}