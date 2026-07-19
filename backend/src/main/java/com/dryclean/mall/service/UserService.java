package com.dryclean.mall.service;

import com.dryclean.mall.dto.UserCreateRequest;
import com.dryclean.mall.dto.UserDTO;
import com.dryclean.mall.entity.SysUser;
import com.dryclean.mall.repository.SysUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final SysUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public List<UserDTO> list() {
        return userRepository.findAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserDTO create(UserCreateRequest req, String operatorRole) {
        if (userRepository.existsByUsername(req.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        String role = req.getRole() != null ? req.getRole().toUpperCase() : "USER";
        // 允许的角色集合
        if (!List.of("USER", "ADMIN", "SUPPERADMIN").contains(role)) {
            role = "USER";
        }
        // 只有超级管理员可以创建管理员/超级管理员账号，普通管理员创建的一律降级为普通用户
        if (!"SUPPERADMIN".equalsIgnoreCase(operatorRole) && !"USER".equals(role)) {
            role = "USER";
        }
        SysUser user = new SysUser();
        user.setUsername(req.getUsername());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setRealName(req.getRealName());
        user.setPhone(req.getPhone());
        user.setRole(role);
        user.setStatus(1);
        user = userRepository.save(user);
        return toDTO(user);
    }

    @Transactional
    public UserDTO update(Long id, UserDTO dto, String operatorRole) {
        SysUser user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("用户不存在"));
        if (dto.getRealName() != null) user.setRealName(dto.getRealName());
        if (dto.getPhone() != null) user.setPhone(dto.getPhone());
        if (dto.getRole() != null) {
            String newRole = dto.getRole().toUpperCase();
            if (!List.of("USER", "ADMIN", "SUPPERADMIN").contains(newRole)) {
                newRole = "USER";
            }
            // 只有超级管理员可以修改用户角色；普通管理员修改时忽略角色字段
            if ("SUPPERADMIN".equalsIgnoreCase(operatorRole)) {
                user.setRole(newRole);
            }
        }
        if (dto.getStatus() != null) user.setStatus(dto.getStatus());
        user = userRepository.save(user);
        return toDTO(user);
    }

    private UserDTO toDTO(SysUser u) {
        UserDTO dto = new UserDTO();
        dto.setId(u.getId());
        dto.setUsername(u.getUsername());
        dto.setRealName(u.getRealName());
        dto.setPhone(u.getPhone());
        dto.setRole(u.getRole());
        dto.setStatus(u.getStatus());
        dto.setCreatedAt(u.getCreatedAt());
        dto.setUpdatedAt(u.getUpdatedAt());
        return dto;
    }
}
