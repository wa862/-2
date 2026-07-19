package com.dryclean.mall.dto;

import lombok.Data;

import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
public class CommentCreateRequest {

    @NotNull(message = "订单ID不能为空")
    private Long orderId;

    @Size(max = 500, message = "评价内容最多500字")
    private String content;

    @Min(value = 1, message = "评分1-5分")
    @Max(value = 5, message = "评分1-5分")
    private Integer score = 5;
}
