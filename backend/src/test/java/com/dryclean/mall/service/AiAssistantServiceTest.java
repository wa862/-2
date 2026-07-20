package com.dryclean.mall.service;

import com.dryclean.mall.dto.AiChatRequest;
import com.dryclean.mall.dto.AiChatResponse;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.repository.AiChatMessageRepository;
import com.dryclean.mall.repository.AiKnowledgeRepository;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.MallProductRepository;
import com.dryclean.mall.repository.MallStoreRepository;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.SysContactRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AiAssistantServiceTest {

    @Mock
    private AiKnowledgeRepository knowledgeRepository;
    @Mock
    private AiChatMessageRepository chatMessageRepository;
    @Mock
    private DryServiceRepository dryServiceRepository;
    @Mock
    private MallProductRepository mallProductRepository;
    @Mock
    private MallStoreRepository mallStoreRepository;
    @Mock
    private OrderInfoRepository orderInfoRepository;
    @Mock
    private SysContactRepository sysContactRepository;

    @InjectMocks
    private AiAssistantService aiAssistantService;

    @Test
    void bookingSportsShoesReturnsMatchedServiceInsteadOfUnrelatedList() {
        when(dryServiceRepository.findByStatusOrderBySortOrderAsc(1)).thenReturn(List.of(
                service("衬衫洗烫", "衣物", "普通衬衫|15;免烫衬衫|20", "2-3天左右", "衬衫清洗护理", "15.00"),
                service("运动鞋清洗", "鞋类", "普通运动鞋|28;跑步鞋|32;篮球鞋|38", "5-7天左右", "运动鞋去污、除臭、护理", "28.00"),
                service("T恤清洗", "衣物", "短袖T恤|12;长袖T恤|15", "2-3天左右", "日常T恤清洗护理", "12.00")
        ));
        when(chatMessageRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        AiChatResponse response = aiAssistantService.chat(request("我需要清洗运动鞋请帮我下单"));

        assertThat(response.getSourceType()).isEqualTo("BUSINESS");
        assertThat(response.getAnswer()).contains("运动鞋清洗", "普通运动鞋28元", "干洗服务");
        assertThat(response.getAnswer()).doesNotContain("衬衫洗烫", "T恤清洗");
    }

    @Test
    void orderLookupWithoutUserAsksUserToLogin() {
        when(chatMessageRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        AiChatResponse response = aiAssistantService.chat(request("帮我查一下订单状态"));

        assertThat(response.getSourceType()).isEqualTo("BUSINESS");
        assertThat(response.getAnswer()).contains("登录", "我的订单");
    }

    @Test
    void unmatchedBookingDoesNotInventService() {
        when(dryServiceRepository.findByStatusOrderBySortOrderAsc(1)).thenReturn(List.of(
                service("运动鞋清洗", "鞋类", "普通运动鞋|28;跑步鞋|32", "5-7天左右", "运动鞋去污、除臭、护理", "28.00")
        ));
        when(chatMessageRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        AiChatResponse response = aiAssistantService.chat(request("我要洗潜水服帮我下单"));

        assertThat(response.getSourceType()).isEqualTo("BUSINESS");
        assertThat(response.getAnswer()).contains("没有在当前服务列表里匹配到");
        assertThat(response.getAnswer()).doesNotContain("运动鞋清洗");
    }

    @Test
    void priceQuestionReturnsSpecificServicePrice() {
        when(dryServiceRepository.findByStatusOrderBySortOrderAsc(1)).thenReturn(List.of(
                service("西装干洗", "衣物", "上衣|28;套装|48", "3-5天左右", "西装定型护理", "28.00"),
                service("运动鞋清洗", "鞋类", "普通运动鞋|28;跑步鞋|32", "5-7天左右", "运动鞋去污、除臭、护理", "28.00")
        ));
        when(chatMessageRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        AiChatResponse response = aiAssistantService.chat(request("西装怎么收费"));

        assertThat(response.getSourceType()).isEqualTo("BUSINESS");
        assertThat(response.getAnswer()).contains("西装干洗", "上衣28元", "套装48元");
        assertThat(response.getAnswer()).doesNotContain("运动鞋清洗");
    }

    @Test
    void broadClothesBookingShowsClothingCandidates() {
        when(dryServiceRepository.findByStatusOrderBySortOrderAsc(1)).thenReturn(List.of(
                service("衬衫洗烫", "衣物", "普通衬衫|15;免烫衬衫|20", "2-3天左右", "衬衫清洗护理", "15.00"),
                service("运动鞋清洗", "鞋类", "普通运动鞋|28;跑步鞋|32", "5-7天左右", "运动鞋去污、除臭、护理", "28.00")
        ));
        when(chatMessageRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        AiChatResponse response = aiAssistantService.chat(request("我想洗衣服"));

        assertThat(response.getSourceType()).isEqualTo("BUSINESS");
        assertThat(response.getAnswer()).contains("衬衫洗烫", "确认");
        assertThat(response.getAnswer()).doesNotContain("运动鞋清洗");
    }

    private AiChatRequest request(String question) {
        AiChatRequest request = new AiChatRequest();
        request.setQuestion(question);
        return request;
    }

    private DryService service(String name, String category, String specs, String cycle, String description, String price) {
        DryService service = new DryService();
        service.setName(name);
        service.setCategory(category);
        service.setSpecs(specs);
        service.setCycle(cycle);
        service.setDescription(description);
        service.setPrice(new BigDecimal(price));
        service.setStatus(1);
        return service;
    }
}
