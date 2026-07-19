package com.dryclean.mall.service;

import com.dryclean.mall.dto.ServiceDTO;
import com.dryclean.mall.repository.DryServiceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import com.dryclean.mall.entity.DryService;
import org.springframework.data.domain.Sort;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DryServiceService {

    private final DryServiceRepository serviceRepository;

    public List<ServiceDTO> list() {
        return list(false);
    }

    /** @param all true 时返回全部（管理端），否则仅返回 status=1 */
    public List<ServiceDTO> list(boolean all) {
        try {
            List<DryService> entities = all
                    ? serviceRepository.findAll(Sort.by("sortOrder").ascending())
                    : serviceRepository.findByStatusOrderBySortOrderAsc(1);
            return entities.stream().map(ServiceDTO::fromEntity).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("干洗服务列表查询失败: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    public Optional<ServiceDTO> getById(Long id) {
        try {
            return serviceRepository.findById(id).map(ServiceDTO::fromEntity);
        } catch (Exception e) {
            log.warn("干洗服务详情查询失败: {}", e.getMessage());
            return Optional.empty();
        }
    }

    public ServiceDTO create(ServiceDTO dto) {
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new RuntimeException("服务名称不能为空");
        }
        DryService entity = new DryService();
        entity.setName(dto.getName().trim());
        entity.setCategory(dto.getCategory());
        entity.setPrice(dto.getPrice());
        entity.setDescription(dto.getDescription());
        entity.setSpecs(dto.getSpecs());
        entity.setCycle(dto.getCycle());
        entity.setImage(dto.getImage());
        entity.setStatus(dto.getStatus() != null ? dto.getStatus() : 1);
        entity = serviceRepository.save(entity);
        return ServiceDTO.fromEntity(entity);
    }

    public ServiceDTO update(Long id, ServiceDTO dto) {
        DryService entity = serviceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        if (dto.getName() != null) entity.setName(dto.getName());
        if (dto.getCategory() != null) entity.setCategory(dto.getCategory());
        if (dto.getPrice() != null) entity.setPrice(dto.getPrice());
        if (dto.getDescription() != null) entity.setDescription(dto.getDescription());
        if (dto.getSpecs() != null) entity.setSpecs(dto.getSpecs());
        if (dto.getCycle() != null) entity.setCycle(dto.getCycle());
        if (dto.getImage() != null) entity.setImage(dto.getImage());
        if (dto.getStatus() != null) entity.setStatus(dto.getStatus());
        entity = serviceRepository.save(entity);
        return ServiceDTO.fromEntity(entity);
    }

    public void delete(Long id) {
        DryService entity = serviceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("服务不存在"));
        serviceRepository.delete(entity);
    }
}
