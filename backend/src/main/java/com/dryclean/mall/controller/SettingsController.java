package com.dryclean.mall.controller;

import com.dryclean.mall.dto.ProductDTO;
import com.dryclean.mall.dto.ServiceDTO;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.entity.SysBanner;
import com.dryclean.mall.entity.SysContact;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.MallProductRepository;
import com.dryclean.mall.repository.SysBannerRepository;
import com.dryclean.mall.repository.SysContactRepository;
import com.dryclean.mall.service.HomeModuleService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/admin/settings")
@RequiredArgsConstructor
public class SettingsController {

    private final SysBannerRepository bannerRepository;
    private final SysContactRepository contactRepository;
    private final HomeModuleService homeModuleService;
    private final DryServiceRepository serviceRepository;
    private final MallProductRepository productRepository;

    @GetMapping("/banners")
    public ResponseEntity<List<BannerDTO>> listBanners() {
        try {
            List<SysBanner> list = bannerRepository.findAllByOrderBySortOrderAscIdAsc();
            if (list.isEmpty()) {
                return ResponseEntity.ok(defaultBanners());
            }
            return ResponseEntity.ok(list.stream().map(BannerDTO::fromEntity).collect(Collectors.toList()));
        } catch (Exception e) {
            log.warn("查询轮播图失败: {}", e.getMessage());
            return ResponseEntity.ok(defaultBanners());
        }
    }

    @PostMapping("/banners")
    public ResponseEntity<Void> saveBanners(@RequestBody List<BannerDTO> dtos) {
        try {
            bannerRepository.deleteAll();
            List<SysBanner> list = new ArrayList<>();
            int sort = 0;
            for (BannerDTO dto : dtos) {
                SysBanner b = new SysBanner();
                b.setImage(dto.getImage());
                b.setTitle(dto.getTitle());
                b.setSubtitle(dto.getSubtitle());
                b.setLink(dto.getLink() != null ? dto.getLink().trim() : "");
                b.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : sort++);
                b.setEnabled(dto.getEnabled() != null ? dto.getEnabled() : Boolean.TRUE);
                list.add(b);
            }
            bannerRepository.saveAll(list);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.warn("保存轮播图失败: {}", e.getMessage());
            throw new RuntimeException("轮播图配置保存失败，请先执行 database/add_settings_tables.sql 并重启后端");
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
            log.warn("查询客服配置失败: {}", e.getMessage());
            ContactDTO dto = new ContactDTO();
            dto.setPhone("");
            dto.setHours("");
            dto.setQr("");
            return ResponseEntity.ok(dto);
        }
    }

    @PostMapping("/contact")
    public ResponseEntity<Void> saveContact(@RequestBody ContactDTO dto) {
        try {
            SysContact c = contactRepository.findAll().stream().findFirst().orElseGet(SysContact::new);
            c.setPhone(dto.getPhone());
            c.setHours(dto.getHours());
            c.setQr(dto.getQr());
            contactRepository.save(c);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.warn("保存客服配置失败: {}", e.getMessage());
            throw new RuntimeException("客服配置保存失败，请先执行 database/add_settings_tables.sql 并重启后端");
        }
    }

    @GetMapping("/home-modules")
    public ResponseEntity<HomeModuleConfigResponse> getHomeModuleConfig() {
        try {
            HomeModuleConfigResponse res = new HomeModuleConfigResponse();
            res.setHotServiceIds(homeModuleService.getConfigHotServiceIds());
            res.setRecommendProductIds(homeModuleService.getConfigRecommendProductIds());
            List<DryService> services = serviceRepository.findByStatusOrderBySortOrderAsc(1);
            List<MallProduct> products = productRepository.findByStatusOrderBySortOrderAsc(1);
            res.setAllServices(services.stream().map(ServiceDTO::fromEntity).collect(Collectors.toList()));
            res.setAllProducts(products.stream().map(ProductDTO::fromEntity).collect(Collectors.toList()));
            return ResponseEntity.ok(res);
        } catch (Exception e) {
            log.warn("查询首页模块配置失败: {}", e.getMessage());
            HomeModuleConfigResponse res = new HomeModuleConfigResponse();
            res.setHotServiceIds(Collections.emptyList());
            res.setRecommendProductIds(Collections.emptyList());
            res.setAllServices(Collections.emptyList());
            res.setAllProducts(Collections.emptyList());
            return ResponseEntity.ok(res);
        }
    }

    @PostMapping("/home-modules")
    public ResponseEntity<Void> saveHomeModuleConfig(@RequestBody HomeModuleConfigRequest req) {
        try {
            homeModuleService.saveConfig(req.getHotServiceIds(), req.getRecommendProductIds());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.warn("保存首页模块配置失败: {}", e.getMessage());
            throw new RuntimeException("首页模块配置保存失败，请先执行 database/add_home_config.sql 并重启后端");
        }
    }

    @Data
    public static class HomeModuleConfigRequest {
        private List<Long> hotServiceIds;
        private List<Long> recommendProductIds;
    }

    @Data
    public static class HomeModuleConfigResponse {
        private List<Long> hotServiceIds;
        private List<Long> recommendProductIds;
        private List<ServiceDTO> allServices;
        private List<ProductDTO> allProducts;
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
            dto.setLink(b.getLink());
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

