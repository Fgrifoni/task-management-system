package com.example.tarefas.service;

import com.example.tarefas.dto.TarefaRequestDTO;
import com.example.tarefas.dto.TarefaResponseDTO;
import com.example.tarefas.dto.TarefaResumoDTO;
import com.example.tarefas.dto.UsuarioResumoDTO;
import com.example.tarefas.exception.RecursoNaoEncontradoException;
import com.example.tarefas.exception.RegraNegocioException;
import com.example.tarefas.model.PermissaoTarefa;
import com.example.tarefas.model.StatusTarefa;
import com.example.tarefas.model.Tarefa;
import com.example.tarefas.model.TarefaCompartilhamento;
import com.example.tarefas.model.Usuario;
import com.example.tarefas.repository.TarefaCompartilhamentoRepository;
import com.example.tarefas.repository.TarefaRepository;
import com.example.tarefas.repository.UsuarioRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TarefaService {

    private final TarefaRepository tarefaRepository;
    private final UsuarioRepository usuarioRepository;
    private final TarefaCompartilhamentoRepository compartilhamentoRepository;

    public TarefaService(
            TarefaRepository tarefaRepository,
            UsuarioRepository usuarioRepository,
            TarefaCompartilhamentoRepository compartilhamentoRepository
    ) {
        this.tarefaRepository = tarefaRepository;
        this.usuarioRepository = usuarioRepository;
        this.compartilhamentoRepository = compartilhamentoRepository;
    }

    public TarefaResponseDTO criar(TarefaRequestDTO dto, String email) {

        Usuario criador = usuarioRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo(dto.getTitulo());
        tarefa.setDescricao(dto.getDescricao());
        tarefa.setStatus(StatusTarefa.PENDENTE);
        tarefa.setCriador(criador);

        Tarefa salva = tarefaRepository.save(tarefa);

        return converterParaResponse(salva);
    }

    public List<TarefaResponseDTO> listar() {

        return tarefaRepository.findByDeletedFalse()
                .stream()
                .map(this::converterParaResponse)
                .toList();
    }

    public TarefaResponseDTO atualizarStatus(
            Long id,
            StatusTarefa status,
            String email
    ) {

        Tarefa tarefa = buscarTarefa(id);

        if (tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa foi deletada");
        }

        validarAcesso(tarefa, email);

        tarefa.setStatus(status);

        Tarefa atualizada = tarefaRepository.save(tarefa);

        return converterParaResponse(atualizada);
    }

    public TarefaResponseDTO compartilhar(
            Long tarefaId,
            String emailCompartilhado,
            String emailCriador
    ) {

        Tarefa tarefa = buscarTarefa(tarefaId);

        if (tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa foi deletada");
        }

        validarCriador(tarefa, emailCriador);

        Usuario usuario = usuarioRepository.findByEmail(emailCompartilhado)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        if (tarefa.getCriador().getEmail().equals(usuario.getEmail())) {
            throw new RegraNegocioException(
                    "O criador da tarefa já possui acesso a ela"
            );
        }

        boolean jaCompartilhado =
                compartilhamentoRepository
                        .findByTarefaAndUsuario(tarefa, usuario)
                        .isPresent();

        if (jaCompartilhado) {
            throw new RegraNegocioException(
                    "Usuário já possui acesso a esta tarefa"
            );
        }

        TarefaCompartilhamento compartilhamento =
                new TarefaCompartilhamento(
                        tarefa,
                        usuario,
                        PermissaoTarefa.EDICAO_STATUS
                );

        compartilhamentoRepository.save(compartilhamento);

        return converterParaResponse(tarefa);
    }

    public Page<TarefaResponseDTO> listarMinhas(
            String email,
            StatusTarefa status,
            String texto,
            Pageable pageable
    ) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        Page<Tarefa> tarefas = tarefaRepository.buscarMinhasComFiltros(
                usuario,
                status,
                texto,
                pageable
        );

        return tarefas.map(this::converterParaResponse);
    }

    public void deletar(Long id, String email) {

        Tarefa tarefa = buscarTarefa(id);

        if (tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa já está deletada");
        }

        validarCriador(tarefa, email);

        tarefa.setDeleted(true);

        tarefaRepository.save(tarefa);
    }

    public TarefaResponseDTO restaurar(Long id, String email) {

        Tarefa tarefa = buscarTarefa(id);

        validarCriador(tarefa, email);

        if (!tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa não está deletada");
        }

        tarefa.setDeleted(false);

        Tarefa restaurada = tarefaRepository.save(tarefa);

        return converterParaResponse(restaurada);
    }

    public TarefaResponseDTO removerCompartilhamento(
            Long tarefaId,
            Long usuarioId,
            String email
    ) {

        Tarefa tarefa = buscarTarefa(tarefaId);

        if (tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa foi deletada");
        }

        validarCriador(tarefa, email);

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        TarefaCompartilhamento compartilhamento =
                compartilhamentoRepository
                        .findByTarefaAndUsuario(tarefa, usuario)
                        .orElseThrow(() ->
                                new RegraNegocioException(
                                        "Usuário não possui acesso a esta tarefa"
                                ));

        compartilhamentoRepository.delete(compartilhamento);

        return converterParaResponse(tarefa);
    }

    public TarefaResumoDTO resumo(String email) {

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        List<Tarefa> tarefas = tarefaRepository.buscarMinhasSemPaginacao(usuario);

        long pendentes = tarefas.stream()
                .filter(t -> t.getStatus() == StatusTarefa.PENDENTE)
                .count();

        long emAndamento = tarefas.stream()
                .filter(t -> t.getStatus() == StatusTarefa.EM_ANDAMENTO)
                .count();

        long concluidas = tarefas.stream()
                .filter(t -> t.getStatus() == StatusTarefa.CONCLUIDA)
                .count();

        return new TarefaResumoDTO(
                pendentes,
                emAndamento,
                concluidas
        );
    }

    public TarefaResponseDTO editar(
            Long id,
            TarefaRequestDTO dto,
            String email
    ) {

        Tarefa tarefa = buscarTarefa(id);

        if (tarefa.isDeleted()) {
            throw new RegraNegocioException("Esta tarefa foi deletada");
        }

        validarCriador(tarefa, email);

        tarefa.setTitulo(dto.getTitulo());
        tarefa.setDescricao(dto.getDescricao());

        Tarefa editada = tarefaRepository.save(tarefa);

        return converterParaResponse(editada);
    }

    private Tarefa buscarTarefa(Long id) {

        return tarefaRepository.findById(id)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Tarefa não encontrada"));
    }

    private void validarCriador(Tarefa tarefa, String email) {

        if (!tarefa.getCriador().getEmail().equals(email)) {
            throw new RegraNegocioException(
                    "Apenas o criador da tarefa pode realizar esta ação"
            );
        }
    }

    private void validarAcesso(Tarefa tarefa, String email) {

        boolean ehCriador =
                tarefa.getCriador().getEmail().equals(email);

        boolean ehCompartilhado =
                compartilhamentoRepository.findByTarefa(tarefa)
                        .stream()
                        .anyMatch(compartilhamento ->
                                compartilhamento
                                        .getUsuario()
                                        .getEmail()
                                        .equals(email)
                        );

        if (!ehCriador && !ehCompartilhado) {
            throw new RegraNegocioException(
                    "Você não possui acesso a esta tarefa"
            );
        }
    }

    private TarefaResponseDTO converterParaResponse(Tarefa tarefa) {

        List<UsuarioResumoDTO> compartilhados =
                compartilhamentoRepository.findByTarefa(tarefa)
                        .stream()
                        .map(compartilhamento -> new UsuarioResumoDTO(
                                compartilhamento.getUsuario().getId(),
                                compartilhamento.getUsuario().getNome(),
                                compartilhamento.getUsuario().getEmail()
                        ))
                        .toList();

        return new TarefaResponseDTO(
                tarefa.getId(),
                tarefa.getTitulo(),
                tarefa.getDescricao(),
                tarefa.getStatus(),
                tarefa.getCriador().getId(),
                tarefa.getCriador().getNome(),
                tarefa.getCreatedAt(),
                tarefa.getUpdatedAt(),
                compartilhados
        );
    }

    public Page<TarefaResponseDTO> listarDeletadas(
            String email,
            Pageable pageable
    ) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() ->
                        new RecursoNaoEncontradoException("Usuário não encontrado"));

        Page<Tarefa> tarefas =
                tarefaRepository.findByDeletedTrueAndCriador(
                        usuario,
                        pageable
                );

        return tarefas.map(this::converterParaResponse);
    }
}