package com.dryclean.mall.controller;

import com.dryclean.mall.dto.StoreDTO;
import com.dryclean.mall.service.StoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/store")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;

    @GetMapping("/list")
    public ResponseEntity<List<StoreDTO>> list(@RequestParam(value = "all", defaultValue = "false") boolean all) {
        return ResponseEntity.ok(storeService.list(all));
    }

    @PostMapping
    public ResponseEntity<StoreDTO> create(@RequestBody StoreDTO dto) {
        return ResponseEntity.ok(storeService.create(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<StoreDTO> update(@PathVariable Long id, @RequestBody StoreDTO dto) {
        return ResponseEntity.ok(storeService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        storeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
