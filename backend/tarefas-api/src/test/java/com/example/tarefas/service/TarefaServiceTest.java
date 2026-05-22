package com.example.tarefas.service;

import com.example.tarefas.dto.TarefaRequestDTO;
import com.example.tarefas.dto.TarefaResponseDTO;
import com.example.tarefas.exception.RecursoNaoEncontradoException;
import com.example.tarefas.model.StatusTarefa;
import com.example.tarefas.model.Tarefa;
import com.example.tarefas.model.Usuario;
import com.example.tarefas.repository.TarefaRepository;
import com.example.tarefas.repository.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import com.example.tarefas.exception.RegraNegocioException;
import com.example.tarefas.model.TarefaCompartilhamento;
import com.example.tarefas.model.PermissaoTarefa;
import com.example.tarefas.repository.TarefaCompartilhamentoRepository;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class TarefaServiceTest {

    @Mock
    private TarefaRepository tarefaRepository;

    @Mock
    private UsuarioRepository usuarioRepository;

    @Mock
    private TarefaCompartilhamentoRepository compartilhamentoRepository;

    @InjectMocks
    private TarefaService tarefaService;

    @Test
    void deveCriarTarefaComSucesso() {

        Usuario usuario = new Usuario();
        usuario.setNome("Francisco");
        usuario.setEmail("francisco@email.com");

        TarefaRequestDTO dto = new TarefaRequestDTO();
        dto.setTitulo("Estudar testes");
        dto.setDescricao("Aprender JUnit");

        when(usuarioRepository.findByEmail(usuario.getEmail()))
                .thenReturn(Optional.of(usuario));

        Tarefa tarefaSalva = new Tarefa();
        tarefaSalva.setTitulo(dto.getTitulo());
        tarefaSalva.setDescricao(dto.getDescricao());
        tarefaSalva.setStatus(StatusTarefa.PENDENTE);
        tarefaSalva.setCriador(usuario);

        when(tarefaRepository.save(any(Tarefa.class)))
                .thenReturn(tarefaSalva);

        TarefaResponseDTO resposta =
                tarefaService.criar(dto, usuario.getEmail());

        assertNotNull(resposta);

        assertEquals(
                "Estudar testes",
                resposta.getTitulo()
        );

        assertEquals(
                StatusTarefa.PENDENTE,
                resposta.getStatus()
        );

        verify(tarefaRepository, times(1))
                .save(any(Tarefa.class));
    }

    @Test
    void deveLancarErroQuandoUsuarioNaoForEncontradoAoCriarTarefa() {

        TarefaRequestDTO dto = new TarefaRequestDTO();
        dto.setTitulo("Teste");
        dto.setDescricao("Teste erro");

        when(usuarioRepository.findByEmail("naoexiste@email.com"))
                .thenReturn(Optional.empty());

        RecursoNaoEncontradoException exception =
                assertThrows(
                        RecursoNaoEncontradoException.class,
                        () -> tarefaService.criar(
                                dto,
                                "naoexiste@email.com"
                        )
                );

        assertEquals(
                "Usuário não encontrado",
                exception.getMessage()
        );

        verify(tarefaRepository, never())
                .save(any(Tarefa.class));
    }

    @Test
    void deveAtualizarStatusComSucesso() {

        Usuario usuario = new Usuario();
        usuario.setNome("Francisco");
        usuario.setEmail("francisco@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Estudar testes");
        tarefa.setDescricao("Aprender Mockito");
        tarefa.setStatus(StatusTarefa.PENDENTE);
        tarefa.setCriador(usuario);

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        when(tarefaRepository.save(any(Tarefa.class)))
                .thenReturn(tarefa);

        TarefaResponseDTO resposta =
                tarefaService.atualizarStatus(
                        1L,
                        StatusTarefa.CONCLUIDA,
                        "francisco@email.com"
                );

        assertNotNull(resposta);
        assertEquals(StatusTarefa.CONCLUIDA, resposta.getStatus());

        verify(tarefaRepository, times(1))
                .findById(1L);

        verify(tarefaRepository, times(1))
                .save(tarefa);
    }

    @Test
    void deveLancarErroQuandoUsuarioNaoPossuiAcesso() {

        Usuario criador = new Usuario();
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa privada");
        tarefa.setStatus(StatusTarefa.PENDENTE);
        tarefa.setCriador(criador);

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        RegraNegocioException exception =
                assertThrows(
                        RegraNegocioException.class,
                        () -> tarefaService.atualizarStatus(
                                1L,
                                StatusTarefa.CONCLUIDA,
                                "maria@email.com"
                        )
                );

        assertEquals(
                "Você não possui acesso a esta tarefa",
                exception.getMessage()
        );

        verify(tarefaRepository, never())
                .save(any(Tarefa.class));
    }

    @Test
    void deveCompartilharTarefaComSucesso() {

        Usuario criador = new Usuario();
        criador.setId(1L);
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Usuario maria = new Usuario();
        maria.setId(2L);
        maria.setNome("Maria");
        maria.setEmail("maria@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa compartilhada");
        tarefa.setStatus(StatusTarefa.PENDENTE);
        tarefa.setCriador(criador);



        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        when(usuarioRepository.findById(2L))
                .thenReturn(Optional.of(maria));

        when(tarefaRepository.save(any(Tarefa.class)))
                .thenReturn(tarefa);

        TarefaResponseDTO resposta =
                tarefaService.compartilhar(
                        1L,
                        "maria@email.com",
                        "francisco@email.com"
                );

        assertNotNull(resposta);

        verify(compartilhamentoRepository, times(1))
                .save(any(TarefaCompartilhamento.class));



        verify(tarefaRepository, times(1))
                .save(tarefa);
    }

    @Test
    void deveLancarErroAoCompartilharUsuarioDuplicado() {

        Usuario criador = new Usuario();
        criador.setId(1L);
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Usuario maria = new Usuario();
        maria.setId(2L);
        maria.setNome("Maria");
        maria.setEmail("maria@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa");
        tarefa.setCriador(criador);

        when(compartilhamentoRepository.findByTarefaAndUsuario(tarefa, maria))
                .thenReturn(Optional.of(
                        new TarefaCompartilhamento(
                                tarefa,
                                maria,
                                PermissaoTarefa.EDICAO_STATUS
                        )
                ));

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        when(usuarioRepository.findById(2L))
                .thenReturn(Optional.of(maria));

        RegraNegocioException exception =
                assertThrows(
                        RegraNegocioException.class,
                        () -> tarefaService.compartilhar(
                                1L,
                                "maria@email.com",
                                "francisco@email.com"
                        )
                );

        assertEquals(
                "Usuário já possui acesso a esta tarefa",
                exception.getMessage()
        );

        verify(tarefaRepository, never())
                .save(any(Tarefa.class));
    }

    @Test
    void deveLancarErroAoCompartilharComProprioCriador() {

        Usuario criador = new Usuario();
        criador.setId(1L);
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa");
        tarefa.setCriador(criador);

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        when(usuarioRepository.findById(1L))
                .thenReturn(Optional.of(criador));

        RegraNegocioException exception =
                assertThrows(
                        RegraNegocioException.class,
                        () -> tarefaService.compartilhar(
                                1L,
                                "maria@email.com",
                                "francisco@email.com"
                        )
                );

        assertEquals(
                "O criador da tarefa já possui acesso a ela",
                exception.getMessage()
        );

        verify(tarefaRepository, never())
                .save(any(Tarefa.class));
    }

    @Test
    void deveDeletarTarefaComSoftDelete() {

        Usuario criador = new Usuario();
        criador.setId(1L);
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa para deletar");
        tarefa.setCriador(criador);
        tarefa.setDeleted(false);

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        tarefaService.deletar(1L, "francisco@email.com");

        assertTrue(tarefa.isDeleted());

        verify(tarefaRepository, times(1))
                .save(tarefa);
    }

    @Test
    void deveLancarErroAoDeletarTarefaJaDeletada() {

        Usuario criador = new Usuario();
        criador.setId(1L);
        criador.setNome("Francisco");
        criador.setEmail("francisco@email.com");

        Tarefa tarefa = new Tarefa();
        tarefa.setTitulo("Tarefa");
        tarefa.setCriador(criador);
        tarefa.setDeleted(true);

        when(tarefaRepository.findById(1L))
                .thenReturn(Optional.of(tarefa));

        RegraNegocioException exception =
                assertThrows(
                        RegraNegocioException.class,
                        () -> tarefaService.deletar(
                                1L,
                                "francisco@email.com"
                        )
                );

        assertEquals(
                "Esta tarefa já está deletada",
                exception.getMessage()
        );

        verify(tarefaRepository, never())
                .save(any(Tarefa.class));
    }
}
