package com.dryclean.mall.repository;

import com.dryclean.mall.entity.SysUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SysUserRepository extends JpaRepository<SysUser, Long> {

    Optional<SysUser> findByUsername(String username);

    Optional<SysUser> findByPhone(String phone);

    List<SysUser> findByUsernameContainingIgnoreCaseOrRealNameContainingIgnoreCaseOrPhoneContaining(
            String username, String realName, String phone);

    boolean existsByUsername(String username);

    /** 是否存在该用户名且不是当前用户（用于修改用户名时唯一性校验） */
    boolean existsByUsernameAndIdNot(String username, Long id);
}
