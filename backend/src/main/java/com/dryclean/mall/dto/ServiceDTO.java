package com.dryclean.mall.dto;

import com.dryclean.mall.entity.DryService;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ServiceDTO {

    private Long id;
    private String name;
    private String category;
    private BigDecimal price;
    private String description;
    private String specs;
    private String cycle;
    private String image;
    private Integer status;

    public static ServiceDTO fromEntity(DryService s) {
        ServiceDTO dto = new ServiceDTO();
        dto.setId(s.getId());
        dto.setName(s.getName());
        dto.setCategory(s.getCategory());
        dto.setPrice(s.getPrice());
        dto.setDescription(s.getDescription());
        dto.setSpecs(s.getSpecs());
        dto.setCycle(s.getCycle());
        dto.setImage(s.getImage());
        dto.setStatus(s.getStatus());
        return dto;
    }
}
