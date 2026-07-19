package com.dryclean.mall.controller;

import com.dryclean.mall.entity.SysBanner;
import com.dryclean.mall.entity.SysContact;
import com.dryclean.mall.repository.SysBannerRepository;
import com.dryclean.mall.repository.SysContactRepository;
import com.dryclean.mall.service.HomeModuleService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 顾客端读取系统设置的只读接口（不需要登录）。
 */
@Slf4j
@RestController
@RequestMapping("/settings")
@RequiredArgsConstructor
public class PublicSettingsController {

    private final SysBannerRepository bannerRepository;
    private final SysContactRepository contactRepository;
    private final HomeModuleService homeModuleService;

    @GetMapping("/banners")
    public ResponseEntity<List<BannerDTO>> listBanners() {
        try {
            List<SysBanner> list = bannerRepository.findAllByOrderBySortOrderAscIdAsc();
            if (list.isEmpty()) {
                return ResponseEntity.ok(defaultBanners());
            }
            return ResponseEntity.ok(list.stream().map(BannerDTO::fromEntity).collect(Collectors.toList()));
        } catch (Exception e) {
            log.warn("前台查询轮播图失败: {}", e.getMessage());
            return ResponseEntity.ok(defaultBanners());
        }
    }

    @GetMapping("/home-modules")
    public ResponseEntity<HomeModuleService.HomeModulesVO> getHomeModules() {
        try {
            return ResponseEntity.ok(homeModuleService.getHomeModulesForPublic());
        } catch (Exception e) {
            log.warn("前台查询首页模块失败: {}", e.getMessage());
            HomeModuleService.HomeModulesVO fallback = new HomeModuleService.HomeModulesVO();
            return ResponseEntity.ok(fallback);
        }
    }

    @GetMapping("/contact")
    public ResponseEntity<ContactDTO> getContact() {
        try {
            List<SysContact> list = contactRepository.findAll();
            SysContact c = list.isEmpty() ? null : list.get(0);
            if (c == null) {
                ContactDTO dto = new ContactDTO();
                dto.setPhone("");
                dto.setHours("");
                dto.setQr("");
                return ResponseEntity.ok(dto);
            }
            return ResponseEntity.ok(ContactDTO.fromEntity(c));
        } catch (Exception e) {
            log.warn("前台查询客服配置失败: {}", e.getMessage());
            ContactDTO dto = new ContactDTO();
            dto.setPhone("");
            dto.setHours("");
            dto.setQr("");
            return ResponseEntity.ok(dto);
        }
    }

    private List<BannerDTO> defaultBanners() {
        List<BannerDTO> list = new ArrayList<>();
        BannerDTO b1 = new BannerDTO();
        b1.setImage("/banners/dry-clean-blue.svg");
        b1.setTitle("专业干洗 洁净如新");
        b1.setSubtitle("专业设备 · 精细护理 · 上门取送");
        b1.setLink("/home/user/service");
        b1.setSortOrder(0);
        b1.setEnabled(Boolean.TRUE);
        list.add(b1);
        BannerDTO b2 = new BannerDTO();
        b2.setImage("/banners/laundry-green.svg");
        b2.setTitle("绿色洗护 呵护健康");
        b2.setSubtitle("天然配方 · 温和洁净 · 呵护全家");
        b2.setLink("/home/user/product");
        b2.setSortOrder(1);
        b2.setEnabled(Boolean.TRUE);
        list.add(b2);
        BannerDTO b3 = new BannerDTO();
        b3.setImage("/banners/pickup-orange.svg");
        b3.setTitle("一键下单 上门取送");
        b3.setSubtitle("足不出户 · 轻松享受 · 省时省力");
        b3.setLink("/home/user/service");
        b3.setSortOrder(2);
        b3.setEnabled(Boolean.TRUE);
        list.add(b3);
        return list;
    }

    @Data
    public static class BannerDTO {
        private Long id;
        private String image;
        private String title;
        private String subtitle;
        private String link;
        private Integer sortOrder;
        private Boolean enabled;

        public static BannerDTO fromEntity(SysBanner b) {
            BannerDTO dto = new BannerDTO();
            dto.setId(b.getId());
            dto.setImage(b.getImage());
            dto.setTitle(b.getTitle());
            dto.setSubtitle(b.getSubtitle());
            dto.setLink(b.getLink() != null ? b.getLink() : "");
            dto.setSortOrder(b.getSortOrder());
            dto.setEnabled(b.getEnabled());
            return dto;
        }
    }

    @Data
    public static class ContactDTO {
        private String phone;
        private String hours;
        private String qr;

        public static ContactDTO fromEntity(SysContact c) {
            ContactDTO dto = new ContactDTO();
            dto.setPhone(c.getPhone());
            dto.setHours(c.getHours());
            dto.setQr(c.getQr());
            return dto;
        }
    }
}

