package com.dryclean.mall.controller;

import com.dryclean.mall.dto.ServiceDTO;
import com.dryclean.mall.service.DryServiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/service")
@RequiredArgsConstructor
public class ServiceController {

    private final DryServiceService dryServiceService;

    @GetMapping("/list")
    public ResponseEntity<List<ServiceDTO>> list(@RequestParam(value = "all", defaultValue = "false") boolean all) {
        try {
            return ResponseEntity.ok(dryServiceService.list(all));
        } catch (Exception e) {
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceDTO> getById(@PathVariable Long id) {
        return dryServiceService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ServiceDTO> create(@RequestBody ServiceDTO dto) {
        return ResponseEntity.ok(dryServiceService.create(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceDTO> update(@PathVariable Long id, @RequestBody ServiceDTO dto) {
        return ResponseEntity.ok(dryServiceService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dryServiceService.delete(id);
        return ResponseEntity.ok().build();
    }
}
