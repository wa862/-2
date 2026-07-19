package com.dryclean.mall.service;

import com.dryclean.mall.dto.StoreDTO;
import com.dryclean.mall.entity.MallStore;
import com.dryclean.mall.repository.MallStoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StoreService {

    private final MallStoreRepository storeRepository;

    public List<StoreDTO> list() {
        return list(false);
    }

    public List<StoreDTO> list(boolean all) {
        try {
            List<com.dryclean.mall.entity.MallStore> entities = all
                    ? storeRepository.findAll(Sort.by("sortOrder").ascending())
                    : storeRepository.findByStatusOrderBySortOrderAsc(1);
            return entities.stream().map(StoreDTO::fromEntity).collect(Collectors.toList());
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    public void delete(Long id) {
        if (!storeRepository.existsById(id)) {
            throw new RuntimeException("门店不存在");
        }
        storeRepository.deleteById(id);
    }

    public StoreDTO create(StoreDTO dto) {
        MallStore store = new MallStore();
        store.setName(dto.getName());
        store.setAddress(dto.getAddress());
        store.setPhone(dto.getPhone());
        store.setBusinessHours(dto.getBusinessHours());
        store.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);
        store.setStatus(1);
        store = storeRepository.save(store);
        return StoreDTO.fromEntity(store);
    }

    public StoreDTO update(Long id, StoreDTO dto) {
        MallStore store = storeRepository.findById(id).orElseThrow(() -> new RuntimeException("门店不存在"));
        if (dto.getName() != null && !dto.getName().isEmpty()) store.setName(dto.getName());
        if (dto.getAddress() != null) store.setAddress(dto.getAddress());
        if (dto.getPhone() != null) store.setPhone(dto.getPhone());
        if (dto.getBusinessHours() != null) store.setBusinessHours(dto.getBusinessHours());
        if (dto.getSortOrder() != null) store.setSortOrder(dto.getSortOrder());
        store = storeRepository.save(store);
        return StoreDTO.fromEntity(store);
    }
}
