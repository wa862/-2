package com.dryclean.mall.dto;

import com.dryclean.mall.entity.UserAddress;
import lombok.Data;

@Data
public class UserAddressDTO {

    private Long id;
    private Long userId;
    private String contactName;
    private String phone;
    private String province;
    private String city;
    private String district;
    private String detailAddress;
    private Boolean isDefault;

    public static UserAddressDTO fromEntity(UserAddress a) {
        UserAddressDTO dto = new UserAddressDTO();
        dto.setId(a.getId());
        dto.setUserId(a.getUserId());
        dto.setContactName(a.getContactName());
        dto.setPhone(a.getPhone());
        dto.setProvince(a.getProvince());
        dto.setCity(a.getCity());
        dto.setDistrict(a.getDistrict());
        dto.setDetailAddress(a.getDetailAddress());
        dto.setIsDefault(a.getIsDefault() != null && a.getIsDefault());
        return dto;
    }
}
