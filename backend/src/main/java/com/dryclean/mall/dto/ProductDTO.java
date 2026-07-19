package com.dryclean.mall.dto;

import com.dryclean.mall.entity.MallProduct;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class ProductDTO {

    private Long id;
    private String name;
    private String category;
    private String brand;
    private String manufacturer;
    private LocalDate productionDate;
    private String specification;
    private BigDecimal price;
    private String description;
    private String image;
    private Integer stock;
    private Integer sales;
    private Integer status;

    public static ProductDTO fromEntity(MallProduct p) {
        ProductDTO dto = new ProductDTO();
        dto.setId(p.getId());
        dto.setName(p.getName());
        dto.setCategory(p.getCategory());
        dto.setBrand(p.getBrand());
        dto.setManufacturer(p.getManufacturer());
        dto.setProductionDate(p.getProductionDate());
        dto.setSpecification(p.getSpecification());
        dto.setPrice(p.getPrice());
        dto.setDescription(p.getDescription());
        dto.setImage(p.getImage());
        dto.setStock(p.getStock());
        dto.setSales(p.getSales());
        dto.setStatus(p.getStatus());
        return dto;
    }
}
