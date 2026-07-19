package com.dryclean.mall.entity;

import lombok.Data;

import javax.persistence.*;

@Data
@Entity
@Table(name = "sys_contact")
public class SysContact {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 32)
    private String phone;

    @Column(length = 64)
    private String hours;

    @Column(length = 255)
    private String qr;
}

