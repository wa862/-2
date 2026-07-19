package com.dryclean.mall.controller;

import com.dryclean.mall.dto.AddressCreateRequest;
import com.dryclean.mall.dto.UserAddressDTO;
import com.dryclean.mall.service.UserAddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/address")
@RequiredArgsConstructor
public class AddressController {

    private final UserAddressService addressService;

    @GetMapping("/list")
    public ResponseEntity<List<UserAddressDTO>> list(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.ok(List.of());
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(addressService.listByUser(userId));
    }

    @PostMapping("/create")
    public ResponseEntity<UserAddressDTO> create(Authentication auth, @Valid @RequestBody AddressCreateRequest req) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(addressService.create(userId, req));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserAddressDTO> update(Authentication auth, @PathVariable Long id,
                                                  @Valid @RequestBody AddressCreateRequest req) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(addressService.update(userId, id, req));
    }

    @PostMapping("/{id}/default")
    public ResponseEntity<Void> setDefault(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        addressService.setDefault(userId, id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(Authentication auth, @PathVariable Long id) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        Long userId = (Long) auth.getPrincipal();
        addressService.delete(userId, id);
        return ResponseEntity.ok().build();
    }
}
