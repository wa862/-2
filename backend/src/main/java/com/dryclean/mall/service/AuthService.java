package com.dryclean.mall.service;

import com.dryclean.mall.dto.AuthResponse;
import com.dryclean.mall.dto.LoginRequest;
import com.dryclean.mall.dto.RegisterRequest;
import com.dryclean.mall.entity.SysUser;
import com.dryclean.mall.repository.SysUserRepository;
import com.dryclean.mall.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    /** 简单内存验证码存储（key -> code, expireAt），示例用，生产可换成 Redis */
    private static final Map<String, CaptchaRecord> CAPTCHA_STORE = new ConcurrentHashMap<>();

    private static class CaptchaRecord {
        final String code;
        final long expireAt;
        CaptchaRecord(String code, long expireAt) {
            this.code = code;
            this.expireAt = expireAt;
        }
    }

    /** 中国大陆手机号：1 开头第二位 3-9，共 11 位 */
    private static final java.util.regex.Pattern PHONE_PATTERN =
            java.util.regex.Pattern.compile("^1[3-9]\\d{9}$");

    public AuthResponse login(LoginRequest req) {
        String account = req.getUsername() != null ? req.getUsername().trim() : "";
        if (!PHONE_PATTERN.matcher(account).matches()) {
            throw new RuntimeException("请使用手机号登录");
        }
        SysUser user = userRepository.findByPhone(account)
                .orElseThrow(() -> new RuntimeException("手机号或密码错误"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new RuntimeException("手机号或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() != 1) {
            throw new RuntimeException("账号已被禁用");
        }
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        long expireAt = System.currentTimeMillis() + 24 * 3600 * 1000L;
        AuthResponse resp = new AuthResponse();
        resp.setToken(token);
        resp.setExpireAt(expireAt);
        AuthResponse.UserDTO u = new AuthResponse.UserDTO();
        u.setId(user.getId());
        u.setUsername(user.getUsername());
        u.setRealName(user.getRealName());
        u.setPhone(user.getPhone());
        u.setAvatar(user.getAvatar());
        u.setRole(user.getRole());
        resp.setUser(u);
        return resp;
    }

    /** 根据当前登录用户 ID 获取用户信息（用于刷新后恢复） */
    public AuthResponse.UserDTO getCurrentUser(Long userId) {
        SysUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        AuthResponse.UserDTO u = new AuthResponse.UserDTO();
        u.setId(user.getId());
        u.setUsername(user.getUsername());
        u.setRealName(user.getRealName());
        u.setPhone(user.getPhone());
        u.setAvatar(user.getAvatar());
        u.setRole(user.getRole());
        return u;
    }

    @Transactional
    public AuthResponse.UserDTO updateProfile(Long userId, String username, String realName, String avatar,
                                              String currentPassword, String newPassword) {
        SysUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (username != null) {
            String name = username.trim();
            if (!name.isEmpty() && !name.equals(user.getUsername())
                    && userRepository.existsByUsernameAndIdNot(name, userId)) {
                throw new RuntimeException("用户名已被占用");
            }
            if (!name.isEmpty()) user.setUsername(name);
        }
        if (realName != null) user.setRealName(realName.trim().isEmpty() ? null : realName.trim());
        if (avatar != null) user.setAvatar(avatar.trim().isEmpty() ? null : avatar.trim());
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                throw new RuntimeException("修改密码请输入当前密码");
            }
            if (!passwordEncoder.matches(currentPassword.trim(), user.getPassword())) {
                throw new RuntimeException("当前密码错误");
            }
            user.setPassword(passwordEncoder.encode(newPassword.trim()));
        }
        user = userRepository.save(user);
        AuthResponse.UserDTO u = new AuthResponse.UserDTO();
        u.setId(user.getId());
        u.setUsername(user.getUsername());
        u.setRealName(user.getRealName());
        u.setPhone(user.getPhone());
        u.setAvatar(user.getAvatar());
        u.setRole(user.getRole());
        return u;
    }

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByUsername(req.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        // 优先使用 uuid + code，新老字段都兼容
        String key = req.getUuid() != null ? req.getUuid() : req.getCaptchaKey();
        String code = req.getCode() != null ? req.getCode() : req.getCaptchaCode();
        validateCaptcha(key, code);
        SysUser user = new SysUser();
        user.setUsername(req.getUsername());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setRealName(req.getRealName());
        user.setPhone(req.getPhone());
        user.setRole("USER");
        user.setStatus(1);
        user = userRepository.save(user);
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        long expireAt = System.currentTimeMillis() + 24 * 3600 * 1000L;
        AuthResponse resp = new AuthResponse();
        resp.setToken(token);
        resp.setExpireAt(expireAt);
        AuthResponse.UserDTO u = new AuthResponse.UserDTO();
        u.setId(user.getId());
        u.setUsername(user.getUsername());
        u.setRealName(user.getRealName());
        u.setPhone(user.getPhone());
        u.setAvatar(user.getAvatar());
        u.setRole(user.getRole());
        resp.setUser(u);
        return resp;
    }

    /** 旧版验证码结构（兼容保留，可选） */
    public Map<String, String> captcha() {
        Map<String, Object> v2 = captchaImageInternal();
        Map<String, String> map = new HashMap<>();
        map.put("captchaKey", (String) v2.get("uuid"));
        map.put("captchaImage", "data:image/png;base64," + v2.get("img"));
        return map;
    }

    /** 登录 / 注册使用的新结构：{ captchaEnabled, img, uuid } */
    public Map<String, Object> captchaImage() {
        Map<String, Object> map = captchaImageInternal();
        map.put("captchaEnabled", true);
        return map;
    }

    private Map<String, Object> captchaImageInternal() {
        String uuid = UUID.randomUUID().toString();
        String code = String.valueOf((int) (Math.random() * 9000) + 1000);
        long expireAt = System.currentTimeMillis() + 5 * 60 * 1000L; // 5 分钟
        CAPTCHA_STORE.put(uuid, new CaptchaRecord(code.toLowerCase(), expireAt));

        int width = 110;
        int height = 40;
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        g.setColor(new Color(240, 244, 255));
        g.fillRect(0, 0, width, height);
        g.setFont(new Font("Arial", Font.BOLD, 24));

        g.setColor(new Color(200, 210, 230));
        for (int i = 0; i < 6; i++) {
            int x1 = (int) (Math.random() * width);
            int y1 = (int) (Math.random() * height);
            int x2 = (int) (Math.random() * width);
            int y2 = (int) (Math.random() * height);
            g.drawLine(x1, y1, x2, y2);
        }

        g.setColor(new Color(70, 100, 180));
        int x = 12;
        for (char c : code.toCharArray()) {
            double rotate = (Math.random() - 0.5) * 0.4;
            g.rotate(rotate, x, 25);
            g.drawString(String.valueOf(c), x, 28);
            g.rotate(-rotate, x, 25);
            x += 22;
        }
        g.dispose();

        String base64;
        try (ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
            javax.imageio.ImageIO.write(image, "png", bos);
            base64 = Base64.getEncoder().encodeToString(bos.toByteArray());
        } catch (Exception e) {
            throw new RuntimeException("验证码生成失败");
        }

        Map<String, Object> map = new HashMap<>();
        map.put("img", base64);
        map.put("uuid", uuid);
        return map;
    }

    private void validateCaptcha(String key, String code) {
        if (key == null || key.isEmpty() || code == null || code.isEmpty()) {
            throw new RuntimeException("验证码不能为空");
        }
        CaptchaRecord record = CAPTCHA_STORE.remove(key);
        if (record == null || record.expireAt < System.currentTimeMillis()) {
            throw new RuntimeException("验证码已过期，请重新获取");
        }
        if (!record.code.equalsIgnoreCase(code.trim())) {
            throw new RuntimeException("验证码错误");
        }
    }
}
