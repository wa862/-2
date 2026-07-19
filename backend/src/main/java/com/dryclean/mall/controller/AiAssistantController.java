package com.dryclean.mall.controller;

import com.dryclean.mall.dto.AiChatRequest;
import com.dryclean.mall.dto.AiChatResponse;
import com.dryclean.mall.dto.AiKnowledgeDTO;
import com.dryclean.mall.service.AiAssistantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiAssistantController {

    private final AiAssistantService aiAssistantService;

    @PostMapping("/chat")
    public ResponseEntity<AiChatResponse> chat(@Valid @RequestBody AiChatRequest request) {
        return ResponseEntity.ok(aiAssistantService.chat(request));
    }

    @GetMapping("/knowledge")
    public ResponseEntity<List<AiKnowledgeDTO>> listKnowledge(
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "all", defaultValue = "false") boolean all) {
        return ResponseEntity.ok(aiAssistantService.listKnowledge(keyword, all));
    }

    @PostMapping("/knowledge")
    public ResponseEntity<AiKnowledgeDTO> createKnowledge(@RequestBody AiKnowledgeDTO dto) {
        return ResponseEntity.ok(aiAssistantService.createKnowledge(dto));
    }

    @PutMapping("/knowledge/{id}")
    public ResponseEntity<AiKnowledgeDTO> updateKnowledge(@PathVariable Long id, @RequestBody AiKnowledgeDTO dto) {
        return ResponseEntity.ok(aiAssistantService.updateKnowledge(id, dto));
    }

    @DeleteMapping("/knowledge/{id}")
    public ResponseEntity<Void> deleteKnowledge(@PathVariable Long id) {
        aiAssistantService.deleteKnowledge(id);
        return ResponseEntity.ok().build();
    }
}
