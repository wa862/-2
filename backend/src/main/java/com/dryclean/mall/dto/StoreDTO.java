package com.dryclean.mall.dto;

import com.dryclean.mall.entity.MallStore;
import lombok.Data;

@Data
public class StoreDTO {

    private Long id;
    private String name;
    private String address;
    private String phone;
    private String businessHours;
    private Integer sortOrder;

    public static StoreDTO fromEntity(MallStore s) {
        StoreDTO dto = new StoreDTO();
        dto.setId(s.getId());
        dto.setName(s.getName());
        dto.setAddress(s.getAddress());
        dto.setPhone(s.getPhone());
        dto.setBusinessHours(s.getBusinessHours());
        dto.setSortOrder(s.getSortOrder());
        return dto;
    }
}
