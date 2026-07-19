package com.dryclean.mall.service;

import com.dryclean.mall.dto.AiChatRequest;
import com.dryclean.mall.dto.AiChatResponse;
import com.dryclean.mall.dto.AiKnowledgeDTO;
import com.dryclean.mall.entity.AiChatMessage;
import com.dryclean.mall.entity.AiKnowledge;
import com.dryclean.mall.entity.DryService;
import com.dryclean.mall.entity.MallProduct;
import com.dryclean.mall.entity.MallStore;
import com.dryclean.mall.entity.OrderInfo;
import com.dryclean.mall.entity.SysContact;
import com.dryclean.mall.repository.AiChatMessageRepository;
import com.dryclean.mall.repository.AiKnowledgeRepository;
import com.dryclean.mall.repository.DryServiceRepository;
import com.dryclean.mall.repository.MallProductRepository;
import com.dryclean.mall.repository.MallStoreRepository;
import com.dryclean.mall.repository.OrderInfoRepository;
import com.dryclean.mall.repository.SysContactRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiAssistantService {

    private static final double LOCAL_MATCH_THRESHOLD = 0.34;

    private final AiKnowledgeRepository knowledgeRepository;
    private final AiChatMessageRepository chatMessageRepository;
    private final DryServiceRepository dryServiceRepository;
    private final MallProductRepository mallProductRepository;
    private final MallStoreRepository mallStoreRepository;
    private final OrderInfoRepository orderInfoRepository;
    private final SysContactRepository sysContactRepository;
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${openai.api-key:}")
    private String openaiApiKey;

    @Value("${openai.api-url:https://api.openai.com/v1/responses}")
    private String openaiApiUrl;

    @Value("${openai.model:gpt-5}")
    private String openaiModel;

    @Value("${zhipu.api-key:}")
    private String zhipuApiKey;

    @Value("${zhipu.api-url:https://open.bigmodel.cn/api/paas/v4/chat/completions}")
    private String zhipuApiUrl;

    @Value("${zhipu.model:glm-4-flash}")
    private String zhipuModel;

    public AiChatResponse chat(AiChatRequest request) {
        String question = normalize(request.getQuestion());
        if (question.isEmpty()) {
            throw new RuntimeException("问题不能为空");
        }

        MatchResult match = findBestKnowledge(question);
        AiChatResponse response;
        if (match != null && match.score >= LOCAL_MATCH_THRESHOLD) {
            AiKnowledge knowledge = match.knowledge;
            knowledge.setHitCount((knowledge.getHitCount() == null ? 0 : knowledge.getHitCount()) + 1);
            knowledgeRepository.save(knowledge);
            response = AiChatResponse.of(knowledge.getAnswer(), "KNOWLEDGE", knowledge.getId(), knowledge.getQuestion(), match.score);
        } else {
            response = answerFromBusinessData(question, request.getUserId());
            if (response == null) {
                response = askRemoteAi(question, request.getUserId());
            }
        }

        saveChatLog(request.getUserId(), question, response);
        return response;
    }

    private AiChatResponse askRemoteAi(String question, Long userId) {
        String siteContext = buildSiteContext(userId);
        // 智谱在国内网络下通常更稳定，优先用于在线客服兜底。
        AiChatResponse zhipuResponse = askZhipu(question, siteContext);
        if (zhipuResponse != null) return zhipuResponse;

        AiChatResponse openaiResponse = askOpenAI(question, siteContext);
        if (openaiResponse != null) return openaiResponse;

        return AiChatResponse.of("知识库没有找到完全匹配的答案，且当前两个 AI 服务都暂时不可用。你可以换一种问法，或到“干洗服务、商城、附近门店、我的订单”页面查看网站实际信息。", "FALLBACK", null, null, 0.0);
    }

    public List<AiKnowledgeDTO> listKnowledge(String keyword, boolean all) {
        Sort sort = Sort.by(Sort.Order.asc("sortOrder"), Sort.Order.desc("hitCount"), Sort.Order.desc("id"));
        List<AiKnowledge> list;
        String kw = normalize(keyword);
        if (!kw.isEmpty()) {
            list = knowledgeRepository.findByQuestionContainingIgnoreCaseOrAnswerContainingIgnoreCaseOrKeywordsContainingIgnoreCase(kw, kw, kw, sort);
            if (!all) {
                list = list.stream().filter(item -> Objects.equals(item.getStatus(), 1)).collect(Collectors.toList());
            }
        } else {
            list = all ? knowledgeRepository.findAll(sort) : knowledgeRepository.findByStatusOrderBySortOrderAsc(1);
        }
        return list.stream().map(AiKnowledgeDTO::fromEntity).collect(Collectors.toList());
    }

    public AiKnowledgeDTO createKnowledge(AiKnowledgeDTO dto) {
        AiKnowledge entity = new AiKnowledge();
        fillKnowledge(entity, dto);
        return AiKnowledgeDTO.fromEntity(knowledgeRepository.save(entity));
    }

    public AiKnowledgeDTO updateKnowledge(Long id, AiKnowledgeDTO dto) {
        AiKnowledge entity = knowledgeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("知识库条目不存在"));
        fillKnowledge(entity, dto);
        return AiKnowledgeDTO.fromEntity(knowledgeRepository.save(entity));
    }

    public void deleteKnowledge(Long id) {
        knowledgeRepository.deleteById(id);
    }

    private void fillKnowledge(AiKnowledge entity, AiKnowledgeDTO dto) {
        if (dto.getQuestion() == null || dto.getQuestion().trim().isEmpty()) {
            throw new RuntimeException("问题不能为空");
        }
        if (dto.getAnswer() == null || dto.getAnswer().trim().isEmpty()) {
            throw new RuntimeException("答案不能为空");
        }
        entity.setQuestion(dto.getQuestion().trim());
        entity.setAnswer(dto.getAnswer().trim());
        entity.setCategory(defaultIfBlank(dto.getCategory(), "干洗咨询"));
        entity.setKeywords(dto.getKeywords());
        entity.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());
        entity.setSortOrder(dto.getSortOrder() == null ? 0 : dto.getSortOrder());
    }

    private MatchResult findBestKnowledge(String question) {
        List<AiKnowledge> list = knowledgeRepository.findByStatusOrderBySortOrderAsc(1);
        MatchResult best = null;
        for (AiKnowledge knowledge : list) {
            String haystack = String.join(" ",
                    nullToEmpty(knowledge.getQuestion()),
                    nullToEmpty(knowledge.getAnswer()),
                    nullToEmpty(knowledge.getKeywords()));
            double score = score(question, haystack);
            if (best == null || score > best.score) {
                best = new MatchResult(knowledge, score);
            }
        }
        return best;
    }

    private double score(String question, String haystack) {
        String q = normalize(question);
        String h = normalize(haystack);
        if (h.contains(q) || q.contains(normalize(haystack.split("\\s+")[0]))) return 1.0;
        Set<String> qTokens = tokenize(q);
        Set<String> hTokens = tokenize(h);
        if (qTokens.isEmpty() || hTokens.isEmpty()) return 0;
        int hit = 0;
        for (String token : qTokens) {
            if (hTokens.contains(token) || h.contains(token)) hit++;
        }
        return hit * 1.0 / qTokens.size();
    }

    private Set<String> tokenize(String text) {
        Set<String> tokens = new HashSet<>();
        String cleaned = text.replaceAll("[，。！？、；：,.!?;:\\s]+", " ");
        for (String part : cleaned.split(" ")) {
            if (part.length() >= 2) tokens.add(part);
        }
        for (int i = 0; i < text.length() - 1; i++) {
            String token = text.substring(i, i + 2).trim();
            if (token.length() == 2) tokens.add(token);
        }
        return tokens;
    }

    @SuppressWarnings("unchecked")
    private AiChatResponse askOpenAI(String question, String siteContext) {
        if (openaiApiKey == null || openaiApiKey.trim().isEmpty()) {
            return null;
        }
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(openaiApiKey.trim());

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("model", openaiModel);
            body.put("store", false);
            body.put("input", List.of(
                    Map.of("role", "system", "content", buildSystemPrompt(siteContext)),
                    Map.of("role", "user", "content", question)
            ));

            ResponseEntity<Map> entity = restTemplate.exchange(openaiApiUrl, HttpMethod.POST, new HttpEntity<>(body, headers), Map.class);
            Map<String, Object> responseBody = entity.getBody();
            String answer = extractOpenAIText(responseBody);
            if (!answer.isEmpty()) {
                return AiChatResponse.of(answer, "OPENAI", null, null, 0.0);
            }
        } catch (HttpStatusCodeException e) {
            log.warn("OpenAI 调用失败: status={}, body={}", e.getStatusCode(), e.getResponseBodyAsString());
        } catch (Exception e) {
            log.warn("OpenAI 调用失败: {}", e.getMessage());
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private AiChatResponse askZhipu(String question, String siteContext) {
        if (zhipuApiKey == null || zhipuApiKey.trim().isEmpty()) {
            return null;
        }
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(zhipuApiKey.trim());

            Map<String, Object> body = new LinkedHashMap<>();
            body.put("model", zhipuModel);
            body.put("temperature", 0.4);
            body.put("messages", List.of(
                    Map.of("role", "system", "content", buildSystemPrompt(siteContext)),
                    Map.of("role", "user", "content", question)
            ));

            ResponseEntity<Map> entity = restTemplate.exchange(zhipuApiUrl, HttpMethod.POST, new HttpEntity<>(body, headers), Map.class);
            Map<String, Object> responseBody = entity.getBody();
            List<Map<String, Object>> choices = responseBody == null ? null : (List<Map<String, Object>>) responseBody.get("choices");
            if (choices != null && !choices.isEmpty()) {
                Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                Object content = message == null ? null : message.get("content");
                if (content != null && !content.toString().trim().isEmpty()) {
                    return AiChatResponse.of(content.toString().trim(), "ZHIPU", null, null, 0.0);
                }
            }
        } catch (HttpStatusCodeException e) {
            log.warn("智谱 AI 调用失败: status={}, body={}", e.getStatusCode(), e.getResponseBodyAsString());
        } catch (Exception e) {
            log.warn("智谱 AI 调用失败: {}", e.getMessage());
        }
        return null;
    }

    private String buildSystemPrompt(String siteContext) {
        return "你是“洗衣优选｜专业干洗”网站的智能客服。必须根据下面的网站实际数据回答，不能编造不存在的服务、商品、门店、价格、周期或政策。"
                + "如果数据里没有答案，请明确说当前网站未配置该信息，并引导用户查看干洗服务、商城、附近门店、我的订单或联系门店客服。"
                + "回答要简洁、礼貌、直接，优先给出可操作建议。\n\n"
                + siteContext;
    }

    private AiChatResponse answerFromBusinessData(String question, Long userId) {
        if (isOrderQuestion(question)) {
            if (userId == null) {
                return AiChatResponse.of("你可以登录后让我查询订单状态，也可以到“我的订单”页面查看全部订单。", "BUSINESS", null, null, 1.0);
            }
            List<OrderInfo> orders = orderInfoRepository.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(0, 5));
            if (orders.isEmpty()) {
                return AiChatResponse.of("当前账号还没有订单记录。你可以先到“干洗服务”页面选择服务并预约下单。", "BUSINESS", null, null, 1.0);
            }
            StringBuilder sb = new StringBuilder("我查到你最近的订单：\n");
            for (OrderInfo order : orders) {
                sb.append("- 订单号：").append(order.getOrderNo())
                        .append("，类型：").append(orderTypeText(order.getOrderType()))
                        .append("，状态：").append(statusText(order.getStatus()))
                        .append("，支付：").append(payStatusText(order.getPayStatus()))
                        .append("，金额：").append(order.getTotalPrice()).append("元");
                appendOrderItemName(sb, order);
                if (order.getPickupDate() != null) sb.append("，取衣日期：").append(order.getPickupDate());
                sb.append("\n");
            }
            sb.append("更完整的信息可以在“我的订单”页面查看。");
            return AiChatResponse.of(sb.toString(), "BUSINESS", null, null, 1.0);
        }

        if (isProductQuestion(question)) {
            List<MallProduct> products = mallProductRepository.findByStatusOrderBySortOrderAsc(1);
            List<MallProduct> matched = products.stream()
                    .filter(p -> score(question, String.join(" ", nullToEmpty(p.getName()), nullToEmpty(p.getCategory()), nullToEmpty(p.getBrand()), nullToEmpty(p.getSpecification()), nullToEmpty(p.getDescription()))) > 0)
                    .limit(5)
                    .collect(Collectors.toList());
            if (matched.isEmpty()) matched = products.stream().limit(5).collect(Collectors.toList());
            if (matched.isEmpty()) return null;
            StringBuilder sb = new StringBuilder("商城里可以购买这些商品：\n");
            for (MallProduct p : matched) {
                sb.append("- ").append(p.getName()).append("：").append(p.getPrice()).append("元，库存：").append(p.getStock());
                if (p.getSpecification() != null && !p.getSpecification().trim().isEmpty()) sb.append("，规格：").append(p.getSpecification());
                sb.append("\n");
            }
            sb.append("你可以到“商城”页面加入购物车。");
            return AiChatResponse.of(sb.toString(), "BUSINESS", null, null, 1.0);
        }

        if (isServiceQuestion(question)) {
            List<DryService> services = dryServiceRepository.findByStatusOrderBySortOrderAsc(1);
            List<DryService> matched = services.stream()
                    .filter(s -> score(question, String.join(" ", nullToEmpty(s.getName()), nullToEmpty(s.getCategory()), nullToEmpty(s.getDescription()), nullToEmpty(s.getSpecs()))) > 0)
                    .limit(5)
                    .collect(Collectors.toList());
            if (matched.isEmpty()) matched = services.stream().limit(5).collect(Collectors.toList());
            if (matched.isEmpty()) return null;
            StringBuilder sb = new StringBuilder("当前可预约的干洗服务有：\n");
            for (DryService s : matched) {
                sb.append("- ").append(s.getName()).append("：").append(s.getPrice()).append("元起");
                if (s.getSpecs() != null && !s.getSpecs().trim().isEmpty()) sb.append("，规格：").append(s.getSpecs());
                if (s.getCycle() != null && !s.getCycle().trim().isEmpty()) sb.append("，周期：").append(s.getCycle());
                sb.append("\n");
            }
            sb.append("你可以到“干洗服务”页面选择对应服务预约。");
            return AiChatResponse.of(sb.toString(), "BUSINESS", null, null, 1.0);
        }

        return null;
    }

    private String buildSiteContext(Long userId) {
        StringBuilder sb = new StringBuilder();
        sb.append("【网站实际数据】\n");
        appendServices(sb);
        appendProducts(sb);
        appendStores(sb);
        appendUserOrders(sb, userId);
        appendContact(sb);
        return sb.toString();
    }

    private void appendServices(StringBuilder sb) {
        sb.append("【上架干洗服务】\n");
        try {
            List<DryService> services = dryServiceRepository.findByStatusOrderBySortOrderAsc(1);
            if (services.isEmpty()) {
                sb.append("暂无上架干洗服务。\n");
                return;
            }
            for (DryService s : services) {
                sb.append("- ").append(s.getName())
                        .append("，分类：").append(nullToEmpty(s.getCategory()))
                        .append("，起步价：").append(s.getPrice()).append("元");
                if (s.getSpecs() != null && !s.getSpecs().trim().isEmpty()) sb.append("，规格：").append(s.getSpecs());
                if (s.getCycle() != null && !s.getCycle().trim().isEmpty()) sb.append("，周期：").append(s.getCycle());
                if (s.getDescription() != null && !s.getDescription().trim().isEmpty()) sb.append("，说明：").append(s.getDescription());
                sb.append("\n");
            }
        } catch (Exception e) {
            log.warn("构建服务上下文失败: {}", e.getMessage());
            sb.append("服务数据读取失败。\n");
        }
    }

    private void appendProducts(StringBuilder sb) {
        sb.append("【上架商城商品】\n");
        try {
            List<MallProduct> products = mallProductRepository.findByStatusOrderBySortOrderAsc(1);
            if (products.isEmpty()) {
                sb.append("暂无上架商城商品。\n");
                return;
            }
            for (MallProduct p : products) {
                sb.append("- ").append(p.getName())
                        .append("，分类：").append(nullToEmpty(p.getCategory()))
                        .append("，价格：").append(p.getPrice()).append("元")
                        .append("，库存：").append(p.getStock());
                if (p.getBrand() != null && !p.getBrand().trim().isEmpty()) sb.append("，品牌：").append(p.getBrand());
                if (p.getSpecification() != null && !p.getSpecification().trim().isEmpty()) sb.append("，规格：").append(p.getSpecification());
                if (p.getDescription() != null && !p.getDescription().trim().isEmpty()) sb.append("，说明：").append(p.getDescription());
                sb.append("\n");
            }
        } catch (Exception e) {
            log.warn("构建商品上下文失败: {}", e.getMessage());
            sb.append("商品数据读取失败。\n");
        }
    }

    private void appendStores(StringBuilder sb) {
        sb.append("【营业门店】\n");
        try {
            List<MallStore> stores = mallStoreRepository.findByStatusOrderBySortOrderAsc(1);
            if (stores.isEmpty()) {
                sb.append("暂无营业门店。\n");
                return;
            }
            for (MallStore store : stores) {
                sb.append("- ").append(store.getName())
                        .append("，地址：").append(nullToEmpty(store.getAddress()))
                        .append("，电话：").append(nullToEmpty(store.getPhone()));
                if (store.getBusinessHours() != null && !store.getBusinessHours().trim().isEmpty()) {
                    sb.append("，营业时间：").append(store.getBusinessHours());
                }
                sb.append("\n");
            }
        } catch (Exception e) {
            log.warn("构建门店上下文失败: {}", e.getMessage());
            sb.append("门店数据读取失败。\n");
        }
    }

    private void appendContact(StringBuilder sb) {
        sb.append("【客服联系方式】\n");
        try {
            List<SysContact> contacts = sysContactRepository.findAll();
            if (contacts.isEmpty()) {
                sb.append("暂无客服电话配置。\n");
                return;
            }
            SysContact contact = contacts.get(0);
            sb.append("客服电话：").append(nullToEmpty(contact.getPhone()));
            if (contact.getHours() != null && !contact.getHours().trim().isEmpty()) {
                sb.append("，服务时间：").append(contact.getHours());
            }
            sb.append("\n");
        } catch (Exception e) {
            log.warn("构建联系方式上下文失败: {}", e.getMessage());
            sb.append("客服联系方式读取失败。\n");
        }
    }

    private void appendUserOrders(StringBuilder sb, Long userId) {
        sb.append("【当前用户最近订单】\n");
        if (userId == null) {
            sb.append("用户未登录或未传用户ID，不能查询个人订单。\n");
            return;
        }
        try {
            List<OrderInfo> orders = orderInfoRepository.findByUserIdOrderByCreatedAtDesc(userId, PageRequest.of(0, 5));
            if (orders.isEmpty()) {
                sb.append("当前用户暂无订单。\n");
                return;
            }
            for (OrderInfo order : orders) {
                sb.append("- 订单号：").append(order.getOrderNo())
                        .append("，状态：").append(statusText(order.getStatus()))
                        .append("，支付状态：").append(payStatusText(order.getPayStatus()))
                        .append("，金额：").append(order.getTotalPrice()).append("元");
                appendOrderItemName(sb, order);
                if (order.getPickupDate() != null) sb.append("，预约取衣日期：").append(order.getPickupDate());
                sb.append("\n");
            }
        } catch (Exception e) {
            log.warn("构建用户订单上下文失败: {}", e.getMessage());
            sb.append("用户订单读取失败。\n");
        }
    }

    private boolean isOrderQuestion(String question) {
        return containsAny(question, "订单", "我的预约", "取衣", "送达", "状态", "付款", "支付", "洗好", "完成", "物流");
    }

    private boolean isServiceQuestion(String question) {
        return containsAny(question, "干洗", "清洗", "洗衣", "护理", "服务", "羽绒服", "西装", "大衣", "衬衫", "鞋", "箱包", "皮衣", "价格", "多少钱");
    }

    private boolean isProductQuestion(String question) {
        return containsAny(question, "商品", "商城", "购买", "买", "洗衣液", "护理剂", "库存", "用品");
    }

    private boolean containsAny(String text, String... words) {
        for (String word : words) {
            if (text.contains(word)) return true;
        }
        return false;
    }

    private String statusText(String status) {
        if ("PENDING".equals(status)) return "待处理";
        if ("PAID".equals(status)) return "已支付";
        if ("PICKED_UP".equals(status)) return "已取件";
        if ("WASHING".equals(status)) return "清洗中";
        if ("READY".equals(status)) return "待取/待配送";
        if ("DELIVERING".equals(status)) return "配送中";
        if ("COMPLETED".equals(status)) return "已完成";
        if ("CANCELLED".equals(status)) return "已取消";
        return nullToEmpty(status);
    }

    private String payStatusText(String payStatus) {
        if ("UNPAID".equals(payStatus)) return "未支付";
        if ("PAID".equals(payStatus)) return "已支付";
        if ("REFUNDED".equals(payStatus)) return "已退款";
        return nullToEmpty(payStatus);
    }

    private String orderTypeText(String orderType) {
        if ("SERVICE".equals(orderType)) return "干洗服务";
        if ("PRODUCT".equals(orderType)) return "商城商品";
        return nullToEmpty(orderType);
    }

    private void appendOrderItemName(StringBuilder sb, OrderInfo order) {
        try {
            if (order.getServiceId() != null) {
                dryServiceRepository.findById(order.getServiceId())
                        .ifPresent(service -> sb.append("，服务：").append(service.getName()));
            }
            if (order.getProductId() != null) {
                mallProductRepository.findById(order.getProductId())
                        .ifPresent(product -> sb.append("，商品：").append(product.getName()));
            }
        } catch (Exception e) {
            log.warn("读取订单关联项目失败: {}", e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private String extractOpenAIText(Map<String, Object> responseBody) {
        if (responseBody == null) return "";
        Object outputText = responseBody.get("output_text");
        if (outputText != null && !outputText.toString().trim().isEmpty()) {
            return outputText.toString().trim();
        }
        Object outputObj = responseBody.get("output");
        if (!(outputObj instanceof List)) return "";
        StringBuilder sb = new StringBuilder();
        for (Object itemObj : (List<?>) outputObj) {
            if (!(itemObj instanceof Map)) continue;
            Object contentObj = ((Map<String, Object>) itemObj).get("content");
            if (!(contentObj instanceof List)) continue;
            for (Object contentItemObj : (List<?>) contentObj) {
                if (!(contentItemObj instanceof Map)) continue;
                Map<String, Object> contentItem = (Map<String, Object>) contentItemObj;
                Object text = contentItem.get("text");
                if (text != null && !text.toString().trim().isEmpty()) {
                    if (sb.length() > 0) sb.append("\n");
                    sb.append(text.toString().trim());
                }
            }
        }
        return sb.toString();
    }

    private void saveChatLog(Long userId, String question, AiChatResponse response) {
        AiChatMessage message = new AiChatMessage();
        message.setUserId(userId);
        message.setQuestion(question);
        message.setAnswer(response.getAnswer());
        message.setSourceType(response.getSourceType());
        message.setMatchedKnowledgeId(response.getMatchedKnowledgeId());
        chatMessageRepository.save(message);
    }

    private String normalize(String text) {
        return text == null ? "" : text.trim().toLowerCase(Locale.ROOT);
    }

    private String defaultIfBlank(String text, String fallback) {
        return text == null || text.trim().isEmpty() ? fallback : text.trim();
    }

    private String nullToEmpty(String text) {
        return text == null ? "" : text;
    }

    private static class MatchResult {
        private final AiKnowledge knowledge;
        private final double score;

        private MatchResult(AiKnowledge knowledge, double score) {
            this.knowledge = knowledge;
            this.score = score;
        }
    }
}
