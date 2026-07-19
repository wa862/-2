package com.dryclean.mall.service;

import com.dryclean.mall.dto.ProductDTO;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.repository.MallProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProductService {

    private final MallProductRepository productRepository;

    public List<ProductDTO> list() {
        return list(false);
    }

    /** @param all true 时返回全部（管理端），否则仅返回 status=1 */
    public List<ProductDTO> list(boolean all) {
        try {
            List<MallProduct> entities = all
                    ? productRepository.findAll(Sort.by("sortOrder").ascending())
                    : productRepository.findByStatusOrderBySortOrderAsc(1);
            return entities.stream().map(ProductDTO::fromEntity).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("商品列表查询失败: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    public Optional<ProductDTO> getById(Long id) {
        try {
            return productRepository.findById(id).map(ProductDTO::fromEntity);
        } catch (Exception e) {
            log.warn("商品详情查询失败: {}", e.getMessage());
            return Optional.empty();
        }
    }

    public ProductDTO update(Long id, ProductDTO dto) {
        MallProduct entity = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("商品不存在"));
        if (dto.getName() != null) entity.setName(dto.getName());
        if (dto.getCategory() != null) entity.setCategory(dto.getCategory());
        if (dto.getBrand() != null) entity.setBrand(dto.getBrand());
        if (dto.getManufacturer() != null) entity.setManufacturer(dto.getManufacturer());
        if (dto.getProductionDate() != null) entity.setProductionDate(dto.getProductionDate());
        if (dto.getSpecification() != null) entity.setSpecification(dto.getSpecification());
        if (dto.getPrice() != null) entity.setPrice(dto.getPrice());
        if (dto.getDescription() != null) entity.setDescription(dto.getDescription());
        if (dto.getImage() != null) entity.setImage(dto.getImage());
        if (dto.getStock() != null) entity.setStock(dto.getStock());
        if (dto.getSales() != null) entity.setSales(dto.getSales());
        if (dto.getStatus() != null) entity.setStatus(dto.getStatus());
        entity = productRepository.save(entity);
        return ProductDTO.fromEntity(entity);
    }

    public ProductDTO create(ProductDTO dto) {
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new RuntimeException("商品名称不能为空");
        }
        MallProduct entity = new MallProduct();
        entity.setName(dto.getName().trim());
        entity.setCategory(dto.getCategory());
        entity.setBrand(dto.getBrand());
        entity.setManufacturer(dto.getManufacturer());
        entity.setProductionDate(dto.getProductionDate());
        entity.setSpecification(dto.getSpecification());
        entity.setPrice(dto.getPrice());
        entity.setDescription(dto.getDescription());
        entity.setImage(dto.getImage());
        if (dto.getStock() != null) entity.setStock(dto.getStock());
        if (dto.getSales() != null) entity.setSales(dto.getSales());
        if (dto.getStatus() != null) entity.setStatus(dto.getStatus());
        entity = productRepository.save(entity);
        return ProductDTO.fromEntity(entity);
    }
}
