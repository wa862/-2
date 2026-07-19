package com.dryclean.mall.service;

import com.dryclean.mall.dto.ProductDTO;
import com.dryclean.mall.dto.ServiceDTO;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.entity.SysHomeConfig;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.MallProductRepository;
import com.dryclean.mall.repository.SysHomeConfigRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 首页「热门干洗服务」「推荐商品」模块配置与展示数据。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HomeModuleService {

    private static final ObjectMapper JSON = new ObjectMapper();
    private static final TypeReference<List<Long>> LONG_LIST = new TypeReference<List<Long>>() {};

    private final SysHomeConfigRepository homeConfigRepository;
    private final DryServiceRepository serviceRepository;
    private final MallProductRepository productRepository;

    /**
     * 获取当前首页配置（单行 id=1）。若不存在则返回空配置。
     */
    public SysHomeConfig getConfig() {
        return homeConfigRepository.findById(1L).orElseGet(() -> {
            SysHomeConfig c = new SysHomeConfig();
            c.setId(1L);
            c.setHotServiceIds(null);
            c.setRecommendProductIds(null);
            return c;
        });
    }

    /** 管理端：当前配置的热门服务 ID 列表（顺序）。 */
    public List<Long> getConfigHotServiceIds() {
        List<Long> ids = parseIds(getConfig().getHotServiceIds());
        return ids != null ? ids : Collections.emptyList();
    }

    /** 管理端：当前配置的推荐商品 ID 列表（顺序）。 */
    public List<Long> getConfigRecommendProductIds() {
        List<Long> ids = parseIds(getConfig().getRecommendProductIds());
        return ids != null ? ids : Collections.emptyList();
    }

    /**
     * 保存首页模块配置（热门服务 ID 列表、推荐商品 ID 列表）。
     */
    @Transactional
    public void saveConfig(List<Long> hotServiceIds, List<Long> recommendProductIds) {
        SysHomeConfig c = getConfig();
        c.setHotServiceIds(hotServiceIds == null || hotServiceIds.isEmpty() ? null : toJson(hotServiceIds));
        c.setRecommendProductIds(recommendProductIds == null || recommendProductIds.isEmpty() ? null : toJson(recommendProductIds));
        homeConfigRepository.save(c);
    }

    /**
     * 顾客端：按配置顺序返回首页热门服务与推荐商品；未配置时退回前 4 条（按排序）。
     */
    public HomeModulesVO getHomeModulesForPublic() {
        HomeModulesVO vo = new HomeModulesVO();
        SysHomeConfig config = homeConfigRepository.findById(1L).orElse(null);

        List<Long> serviceIds = parseIds(config != null ? config.getHotServiceIds() : null);
        List<Long> productIds = parseIds(config != null ? config.getRecommendProductIds() : null);

        if (serviceIds != null && !serviceIds.isEmpty()) {
            vo.setHotServices(resolveServicesInOrder(serviceIds));
        } else {
            List<DryService> defaultList = serviceRepository.findByStatusOrderBySortOrderAsc(1);
            vo.setHotServices(defaultList.stream().limit(4).map(ServiceDTO::fromEntity).collect(Collectors.toList()));
        }

        if (productIds != null && !productIds.isEmpty()) {
            vo.setRecommendProducts(resolveProductsInOrder(productIds));
        } else {
            List<MallProduct> defaultList = productRepository.findByStatusOrderBySortOrderAsc(1);
            vo.setRecommendProducts(defaultList.stream().limit(4).map(ProductDTO::fromEntity).collect(Collectors.toList()));
        }
        return vo;
    }

    private List<ServiceDTO> resolveServicesInOrder(List<Long> ids) {
        if (ids.isEmpty()) return Collections.emptyList();
        List<DryService> list = serviceRepository.findAllById(ids);
        Map<Long, DryService> map = list.stream().collect(Collectors.toMap(DryService::getId, s -> s));
        List<ServiceDTO> result = new ArrayList<>();
        for (Long id : ids) {
            DryService s = map.get(id);
            if (s != null && s.getStatus() != null && s.getStatus() == 1) result.add(ServiceDTO.fromEntity(s));
        }
        return result;
    }

    private List<ProductDTO> resolveProductsInOrder(List<Long> ids) {
        if (ids.isEmpty()) return Collections.emptyList();
        List<MallProduct> list = productRepository.findAllById(ids);
        Map<Long, MallProduct> map = list.stream().collect(Collectors.toMap(MallProduct::getId, p -> p));
        List<ProductDTO> result = new ArrayList<>();
        for (Long id : ids) {
            MallProduct p = map.get(id);
            if (p != null && p.getStatus() != null && p.getStatus() == 1) result.add(ProductDTO.fromEntity(p));
        }
        return result;
    }

    private List<Long> parseIds(String json) {
        if (json == null || json.trim().isEmpty()) return null;
        try {
            return JSON.readValue(json, LONG_LIST);
        } catch (Exception e) {
            log.warn("解析首页配置 ID 列表失败: {}", e.getMessage());
            return null;
        }
    }

    private String toJson(List<Long> ids) {
        try {
            return JSON.writeValueAsString(ids);
        } catch (Exception e) {
            throw new RuntimeException("序列化 ID 列表失败", e);
        }
    }

    @lombok.Data
    public static class HomeModulesVO {
        private List<ServiceDTO> hotServices = new ArrayList<>();
        private List<ProductDTO> recommendProducts = new ArrayList<>();
    }
}
