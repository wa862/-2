package com.dryclean.mall.service;

import com.dryclean.mall.dto.AddressCreateRequest;
import com.dryclean.mall.dto.UserAddressDTO;
import com.dryclean.mall.entity.UserAddress;
import com.dryclean.mall.repository.UserAddressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserAddressService {

    private final UserAddressRepository addressRepository;

    public List<UserAddressDTO> listByUser(Long userId) {
        return addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                .stream()
                .map(UserAddressDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserAddressDTO create(Long userId, AddressCreateRequest req) {
        UserAddress a = new UserAddress();
        a.setUserId(userId);
        a.setContactName(req.getContactName());
        a.setPhone(req.getPhone());
        a.setProvince(req.getProvince());
        a.setCity(req.getCity());
        a.setDistrict(req.getDistrict());
        a.setDetailAddress(req.getDetailAddress());
        a.setIsDefault(Boolean.TRUE.equals(req.getIsDefault()));
        if (a.getIsDefault()) {
            addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                    .forEach(addr -> { addr.setIsDefault(false); addressRepository.save(addr); });
        }
        return UserAddressDTO.fromEntity(addressRepository.save(a));
    }

    @Transactional
    public UserAddressDTO update(Long userId, Long id, AddressCreateRequest req) {
        UserAddress a = addressRepository.findById(id).orElseThrow(() -> new RuntimeException("地址不存在"));
        if (!a.getUserId().equals(userId)) throw new RuntimeException("无权修改");
        a.setContactName(req.getContactName());
        a.setPhone(req.getPhone());
        a.setProvince(req.getProvince());
        a.setCity(req.getCity());
        a.setDistrict(req.getDistrict());
        a.setDetailAddress(req.getDetailAddress());
        if (Boolean.TRUE.equals(req.getIsDefault())) {
            addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                    .forEach(addr -> { addr.setIsDefault(false); addressRepository.save(addr); });
            a.setIsDefault(true);
        }
        return UserAddressDTO.fromEntity(addressRepository.save(a));
    }

    @Transactional
    public void setDefault(Long userId, Long id) {
        UserAddress a = addressRepository.findById(id).orElseThrow(() -> new RuntimeException("地址不存在"));
        if (!a.getUserId().equals(userId)) throw new RuntimeException("无权操作");
        addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(userId)
                .forEach(addr -> { addr.setIsDefault(false); addressRepository.save(addr); });
        a.setIsDefault(true);
        addressRepository.save(a);
    }

    @Transactional
    public void delete(Long userId, Long id) {
        UserAddress a = addressRepository.findById(id).orElse(null);
        if (a == null) return;
        if (!a.getUserId().equals(userId)) throw new RuntimeException("无权删除");
        addressRepository.delete(a);
    }
}
