/*package com.example.tarefas.controller;

import com.example.tarefas.dto.TarefaRequestDTO;
import com.example.tarefas.dto.TarefaResponseDTO;
import com.example.tarefas.model.StatusTarefa;
import com.example.tarefas.service.TarefaService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.data.domain.PageImpl;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.core.Authentication;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(TarefaController.class)
class TarefaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private TarefaService tarefaService;

    @MockBean
    private Authentication authentication;

    @Test
    void deveListarMinhasTarefas() throws Exception {

        TarefaResponseDTO tarefa = new TarefaResponseDTO(
                1L,
                "Estudar testes",
                "Testar controller",
                StatusTarefa.PENDENTE,
                1L,
                "Francisco",
                null,
                null,
                List.of()
        );

        when(authentication.getName())
                .thenReturn("francisco@email.com");

        when(tarefaService.listarMinhas(
                anyString(),
                isNull(),
                isNull(),
                any()
        )).thenReturn(new PageImpl<>(List.of(tarefa)));

        mockMvc.perform(get("/tarefas/minhas")
                        .principal(authentication))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].titulo")
                        .value("Estudar testes"));
    }
}*/