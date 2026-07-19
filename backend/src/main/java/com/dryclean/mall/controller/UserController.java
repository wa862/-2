package com.dryclean.mall.controller;

import com.dryclean.mall.dto.UserCreateRequest;
import com.dryclean.mall.dto.UserDTO;
import com.dryclean.mall.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/list")
    public ResponseEntity<List<UserDTO>> list(Authentication auth) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(userService.list());
    }

    @PostMapping("/create")
    public ResponseEntity<UserDTO> create(Authentication auth, @Valid @RequestBody UserCreateRequest req) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        String operatorRole = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replaceFirst("^ROLE_", ""))
                .orElse("USER");
        return ResponseEntity.ok(userService.create(req, operatorRole));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> update(Authentication auth, @PathVariable Long id, @RequestBody UserDTO dto) {
        if (auth == null || auth.getPrincipal() == null) {
            return ResponseEntity.status(401).build();
        }
        String operatorRole = auth.getAuthorities().stream()
                .findFirst()
                .map(a -> a.getAuthority().replaceFirst("^ROLE_", ""))
                .orElse("USER");
        return ResponseEntity.ok(userService.update(id, dto, operatorRole));
    }
}
