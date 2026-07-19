package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

@Data
public class AddressCreateRequest {

    @NotBlank(message = "收货人不能为空")
    @Size(max = 32)
    private String contactName;

    @NotBlank(message = "手机号不能为空")
    @Size(max = 20)
    private String phone;

    @Size(max = 64)
    private String province;

    @Size(max = 64)
    private String city;

    @Size(max = 64)
    private String district;

    @NotBlank(message = "详细地址不能为空")
    @Size(max = 256)
    private String detailAddress;

    private Boolean isDefault;
}
