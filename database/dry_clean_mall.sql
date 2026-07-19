/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80034 (8.0.34)
 Source Host           : localhost:3306
 Source Schema         : dry_clean_mall

 Target Server Type    : MySQL
 Target Server Version : 80034 (8.0.34)
 File Encoding         : 65001

 Date: 19/03/2026 00:15:09
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for cart_item
-- ----------------------------
DROP TABLE IF EXISTS `cart_item`;
CREATE TABLE `cart_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `item_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'PRODUCT/SERVICE',
  `product_id` bigint NULL DEFAULT NULL,
  `service_id` bigint NULL DEFAULT NULL,
  `service_spec_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '干洗服务规格名称（如：短款/长款）',
  `spec_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '干洗服务规格名称，如：短款/长款',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '加入购物车时的单价（含规格）',
  `quantity` int NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_product_id`(`product_id` ASC) USING BTREE,
  INDEX `idx_service_id`(`service_id` ASC) USING BTREE,
  INDEX `idx_cart_service_spec`(`user_id` ASC, `service_id` ASC, `service_spec_name` ASC) USING BTREE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `mall_product` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_service` FOREIGN KEY (`service_id`) REFERENCES `dry_service` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cart_item
-- ----------------------------
INSERT INTO `cart_item` VALUES (5, 3, 'SERVICE', NULL, 2, NULL, NULL, 45.00, 1, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (6, 3, 'PRODUCT', 2, NULL, NULL, NULL, NULL, 2, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (7, 4, 'SERVICE', NULL, 1, NULL, NULL, 90.00, 2, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (8, 5, 'PRODUCT', 3, NULL, NULL, NULL, NULL, 1, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (9, 5, 'SERVICE', NULL, 5, NULL, NULL, 15.00, 3, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (10, 6, 'SERVICE', NULL, 3, NULL, NULL, 68.00, 1, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (11, 7, 'PRODUCT', 1, NULL, NULL, NULL, NULL, 1, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (12, 8, 'SERVICE', NULL, 8, NULL, NULL, 18.00, 2, '2026-03-08 12:51:19');
INSERT INTO `cart_item` VALUES (15, 17, 'SERVICE', NULL, 2, NULL, NULL, 45.00, 1, '2026-03-08 21:46:25');
INSERT INTO `cart_item` VALUES (18, 18, 'PRODUCT', 2, NULL, NULL, NULL, NULL, 1, '2026-03-10 16:03:59');
INSERT INTO `cart_item` VALUES (35, 11, 'SERVICE', NULL, 2, NULL, NULL, NULL, 1, '2026-03-18 13:53:40');
INSERT INTO `cart_item` VALUES (36, 11, 'SERVICE', NULL, 3, NULL, NULL, NULL, 1, '2026-03-18 13:53:47');

-- ----------------------------
-- Table structure for dry_service
-- ----------------------------
DROP TABLE IF EXISTS `dry_service`;
CREATE TABLE `dry_service`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务名称',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '衣物' COMMENT '分类：衣物/鞋类/其他',
  `price` decimal(10, 2) NOT NULL COMMENT '单价',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务说明',
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片URL或路径',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '上架状态：0-下架 1-上架',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `specs` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格信息',
  `cycle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '洗衣周期',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '干洗服务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dry_service
-- ----------------------------
INSERT INTO `dry_service` VALUES (1, '西装干洗', '衣物', 69.00, '西装专业干洗、熨烫整形', 'https://pic1.zhimg.com/50/v2-67e984f5e8c0abf3d73322789f7e825c_720w.jpg?source=1940ef5c', 1, 1, '2026-03-06 15:12:10', '2026-03-18 19:20:47', '上衣|69;上衣+裤子套装|99;三件套(含马甲)|129', '3-5天左右');
INSERT INTO `dry_service` VALUES (2, '羽绒服干洗', '衣物', 69.00, '羽绒服专业护理，蓬松保暖', 'https://tse3.mm.bing.net/th/id/OIP.3HzmnySlSRQZ6RX35yJMpwHaE7?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 2, '2026-03-06 15:12:10', '2026-03-18 19:16:25', '短款|69;中长款|88;长款|108;加长款(过膝)|128', '5-7天左右（旺季略有延长）');
INSERT INTO `dry_service` VALUES (3, '羊绒大衣干洗', '衣物', 68.00, '羊绒/羊毛大衣精细干洗', 'https://www.shuomingshu.cn/wp-content/uploads/images/2023/04/24/918a8e500dd44969be3d03ed3c03f9b3_uoq4zof4ipl.jpg', 1, 3, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短款|98;中长款|128;长款|158;加长款|188', '5-7天左右');
INSERT INTO `dry_service` VALUES (4, '呢子大衣干洗', '衣物', 55.00, '呢子大衣去污、防蛀护理', 'https://down-tw.img.susercontent.com/file/tw-11134207-7rash-m219wgsx4o1w23', 1, 4, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短款|75;中长款|95;长款|118;加长款|138', '4-6天左右');
INSERT INTO `dry_service` VALUES (5, '衬衫洗烫', '衣物', 15.00, '衬衫清洗、熨烫平整', 'https://www.shutterstock.com/image-photo/row-mens-long-sleeved-bluewhite-600nw-2478111043.jpg', 1, 5, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通衬衫|15;免烫衬衫|20;真丝衬衫|35;长袖/短袖同价', '2-3天左右');
INSERT INTO `dry_service` VALUES (6, 'T恤清洗', '衣物', 12.00, '日常T恤清洗护理', 'https://tse3.mm.bing.net/th/id/OIP.0dSMITaYxWRyJZkCV7Cd4gHaE8?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 6, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短袖T恤|12;长袖T恤|15;印花T恤|18;情侣款同价', '2-3天左右');
INSERT INTO `dry_service` VALUES (7, '连衣裙干洗', '衣物', 38.00, '连衣裙干洗、定型', 'https://tse3.mm.bing.net/th/id/OIP.h10RLvPDgm2plOZy0pZ3ZAHaJ4?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 7, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短裙/连衣短裙|38;中长连衣裙|48;长款礼服裙|68;真丝连衣裙|88', '3-5天左右');
INSERT INTO `dry_service` VALUES (8, '牛仔裤清洗', '衣物', 18.00, '牛仔裤去渍、固色', 'https://img95.699pic.com/photo/60068/0129.jpg_wh860.jpg', 1, 8, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通牛仔裤|18;加厚牛仔裤|22;破洞牛仔裤|25;弹力牛仔裤|20', '2-4天左右');
INSERT INTO `dry_service` VALUES (9, '皮衣保养', '衣物', 88.00, '真皮/仿皮皮衣清洁保养', 'https://cbu01.alicdn.com/img/ibank/O1CN01r44Fg32MUeV6Ulipn_!!4074459831-0-cib.jpg', 1, 9, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短款皮衣|88;中长款皮衣|128;长款皮衣|168;机车皮衣|98', '7-10天左右');
INSERT INTO `dry_service` VALUES (10, '毛呢西裤干洗', '衣物', 28.00, '毛呢裤装干洗熨烫', 'https://x0.ifengimg.com/ucms/2023_47/DAE59439C7BBE78C213F49CE8C5C0089E90FEA28_size32_w800_h800.jpg', 1, 10, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通西裤|28;毛呢西裤|38;加厚毛呢裤|48;裤长加长|+10', '3-4天左右');
INSERT INTO `dry_service` VALUES (11, '围巾丝巾护理', '衣物', 20.00, '围巾、丝巾专业护理', 'https://cbu01.alicdn.com/img/ibank/O1CN01rOlkDQ1On5PRvU0UP_!!2211939751749-0-cib.jpg', 1, 11, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '丝巾/小方巾|20;长款围巾|28;羊绒围巾|38;披肩|45', '2-3天左右');
INSERT INTO `dry_service` VALUES (12, '旗袍干洗', '衣物', 48.00, '旗袍、中式服装干洗', 'https://img95.699pic.com/photo/60077/4833.jpg_wh860.jpg', 1, 12, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短款旗袍|48;中长款旗袍|68;长款旗袍|88;真丝旗袍|108', '4-6天左右');
INSERT INTO `dry_service` VALUES (13, '运动服清洗', '衣物', 22.00, '运动服去汗渍、除味', 'https://tse2.mm.bing.net/th/id/OIP.cXyeEKFdDM0QfmCQoLv1RgAAAA?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 13, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '运动T恤|22;运动裤|25;运动套装|42;瑜伽服|28', '2-4天左右');
INSERT INTO `dry_service` VALUES (14, '皮鞋护理', '鞋类', 25.00, '皮鞋清洗、上油、保养', 'https://img95.699pic.com/photo/60064/1513.jpg_wh860.jpg', 1, 14, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通皮鞋|25;真皮皮鞋|35;漆皮鞋|30;磨砂皮|40', '3-5天左右');
INSERT INTO `dry_service` VALUES (15, '运动鞋清洗', '鞋类', 28.00, '运动鞋去污、除臭、护理', 'https://img95.699pic.com/photo/60059/7478.jpg_wh860.jpg', 1, 15, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通运动鞋|28;跑步鞋|32;篮球鞋|38;限量版|48', '5-7天左右');
INSERT INTO `dry_service` VALUES (16, '雪地靴护理', '鞋类', 35.00, '雪地靴清洁、保养', 'https://tse1.explicit.bing.net/th/id/OIP.qlGN9YgM0i5HwkfT4UsB3wHaEq?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 16, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短筒雪地靴|35;中筒雪地靴|45;高筒雪地靴|58;皮毛一体|68', '5-7天左右');
INSERT INTO `dry_service` VALUES (17, '帆布鞋清洗', '鞋类', 18.00, '帆布鞋清洗、晾干', 'https://tse4.mm.bing.net/th/id/OIP.voEcbEqwk-QDsKuwoDByOgHaF7?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 17, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '低帮帆布鞋|18;高帮帆布鞋|22;彩色帆布鞋|25;限量款|30', '3-5天左右');
INSERT INTO `dry_service` VALUES (18, '靴子保养', '鞋类', 42.00, '长靴、短靴清洁保养', 'https://img95.699pic.com/photo/50311/6083.jpg_wh860.jpg', 1, 18, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '短靴|42;中筒靴|58;长筒靴|78;过膝靴|98', '6-8天左右');
INSERT INTO `dry_service` VALUES (19, '凉鞋护理', '鞋类', 20.00, '凉鞋清洗、消毒', 'https://img.alicdn.com/bao/uploaded/i3/2210009485023/O1CN01lZwy2y1myaHoO5K13_!!2210009485023.jpg', 1, 19, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通凉鞋|20;皮质凉鞋|28;高跟鞋|25;凉拖|15', '3-4天左右');
INSERT INTO `dry_service` VALUES (20, '毛毯清洗', '其他', 60.00, '大件毛毯、盖毯清洗', 'https://img95.699pic.com/photo/60085/4588.jpg_wh860.jpg', 1, 20, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '小毛毯(1.5m)|60;中毛毯(1.8m)|80;大毛毯(2.0m)|100;加厚毛毯|+20', '7-10天左右');
INSERT INTO `dry_service` VALUES (21, '床单被罩清洗', '其他', 35.00, '床单、被罩、枕套清洗', 'https://img.alicdn.com/i2/730258521/TB2Pkn1XTvI8KJjSspjXXcgjXXa_!!730258521.jpg', 1, 21, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '床单|35;被罩|45;枕套|10/对;三件套|80;四件套|100', '4-6天左右');
INSERT INTO `dry_service` VALUES (22, '窗帘清洗', '其他', 80.00, '窗帘拆洗、除尘、定型', 'https://tse3.mm.bing.net/th/id/OIP.w37gpBFYnHZP6CAiO6gdMAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 22, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '普通窗帘(每米)|25;加厚窗帘(每米)|35;纱帘(每米)|20;遮光帘(每米)|30', '7-10天左右');
INSERT INTO `dry_service` VALUES (23, '沙发套清洗', '其他', 55.00, '沙发套拆洗、护理', 'https://img.alicdn.com/i2/2134774319/O1CN01wkOlPZ1hm9Q8wmZde_!!2134774319.jpg', 1, 23, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '单人位|55;双人位|85;三人位|115;贵妃榻|65;整套|180', '7-10天左右');
INSERT INTO `dry_service` VALUES (24, '汽车坐垫清洗', '其他', 45.00, '汽车坐垫、靠垫清洗', 'https://img.alicdn.com/i3/3563643602/O1CN011c3j7n1cTlCY0E6YO_!!3563643602.jpg', 1, 24, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '前排两个|45;全套五座|98;真皮保养|+30;加厚坐垫|+15', '5-7天左右');
INSERT INTO `dry_service` VALUES (25, '玩偶公仔清洗', '其他', 25.00, '毛绒玩偶、公仔清洗', 'https://tse3.mm.bing.net/th/id/OIP.KItYCOVe_4_E-pHChrvqCgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 1, 25, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '小玩偶(30cm内)|25;中玩偶(30-60cm)|35;大玩偶(60-100cm)|50;巨型玩偶|80', '4-6天左右');
INSERT INTO `dry_service` VALUES (26, '背包清洗', '其他', 22.00, '双肩包、手提包清洗', 'https://img95.699pic.com/photo/60079/7425.jpg_wh860.jpg', 1, 26, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '双肩包|22;单肩包|25;帆布包|20;真皮包|45;运动背包|28', '4-6天左右');
INSERT INTO `dry_service` VALUES (27, '帽子清洗', '其他', 15.00, '各类帽子清洗定型', 'https://img95.699pic.com/photo/60060/0411.jpg_wh860.jpg', 1, 27, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '棒球帽|15;针织帽|15;遮阳帽|18;礼帽|25;真皮帽|35', '3-5天左右');
INSERT INTO `dry_service` VALUES (28, '手套护理', '其他', 12.00, '皮手套、毛线手套护理', 'https://tse2.mm.bing.net/th/id/OIP.i5RA9oWXO9quKgn3yUGPLQHaHa?w=1024&h=1024&rs=1&pid=ImgDetMain&o=7&rm=3', 1, 28, '2026-03-06 15:12:10', '2026-03-18 13:09:22', '皮手套|20;毛线手套|12;触屏手套|15;滑雪手套|22', '3-5天左右');

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `question_id` bigint NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_question`(`user_id` ASC, `question_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_question_id`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题目收藏' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorite
-- ----------------------------

-- ----------------------------
-- Table structure for mall_product
-- ----------------------------
DROP TABLE IF EXISTS `mall_product`;
CREATE TABLE `mall_product`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '洗衣液',
  `price` decimal(10, 2) NOT NULL,
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片URL或路径',
  `stock` int NOT NULL DEFAULT 0,
  `sales` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `sort_order` int NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品详情描述',
  `brand` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌',
  `manufacturer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生产厂家',
  `production_date` date NULL DEFAULT NULL COMMENT '生产日期',
  `specification` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mall_product
-- ----------------------------
INSERT INTO `mall_product` VALUES (1, '浓缩洗衣液（3kg）', '洗衣液', 39.90, '/api/uploads/product/d8fc8dead81748668a7a6c5492d2f195.png', 196, 132, 1, 1, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '浓缩配方，去渍力强，适用于日常衣物机洗/手洗，低泡易漂，用量省。', '洁净优选', '洁净优选日化有限公司', '2026-02-15', '3kg/桶');
INSERT INTO `mall_product` VALUES (2, '衣物柔顺剂（1.5L）', '护理剂', 29.90, 'https://m.360buyimg.com/mobilecms/s750x750_jfs/t2176/134/1347072105/63543/708842b3/565830ecNd2031f9e.jpg!q80.dpg', 133, 103, 1, 2, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '柔软衣物，减少静电，留香持久，配合洗衣液使用效果更佳。', '柔顺物语', '柔顺物语日化有限公司', '2026-02-10', '1.5L/瓶');
INSERT INTO `mall_product` VALUES (3, '高效去渍喷雾（500ml）', '去渍剂', 24.90, 'https://img.alicdn.com/imgextra/i1/656470574/O1CN01iRwWxW1G6wOcGix69_!!656470574.jpg', 170, 105, 1, 3, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '针对油渍、果渍、血渍等顽固污渍，喷一喷再洗，去渍更轻松。', '净渍帮', '净渍帮清洁用品厂', '2026-01-28', '500ml/瓶');
INSERT INTO `mall_product` VALUES (4, '不锈钢晾衣架（10只装）', '洗衣袋', 19.90, 'https://tse4.mm.bing.net/th/id/OIP.3wkPpmxv1H4q6Dy232Lt2QHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 300, 200, 1, 4, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '不锈钢材质，防锈耐用，挂晾不伤肩，10只装满足全家需求。', '优衣家', '优衣家家居用品厂', '2026-01-20', '10只/包');
INSERT INTO `mall_product` VALUES (5, '防尘衣物收纳袋（3个装）', '洗衣袋', 32.00, 'https://img.alicdn.com/i1/2938454519/O1CN01gMfVKl1jFkPs8Qppm_!!2938454519-0-lubanu-s.jpg', 119, 46, 1, 5, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '防尘防潮，收纳换季衣物、羽绒服、被子，含3个不同规格。', '衣加衣', '衣加衣家纺有限公司', '2026-01-18', '3个/套');
INSERT INTO `mall_product` VALUES (6, '羊毛羊绒专用洗涤剂', '洗衣液', 35.00, 'https://imgservice.suning.cn/uimg1/b2c/image/vOkLBo4e-blmUD0FyTZKfg.jpg', 79, 33, 1, 6, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '专为羊毛、羊绒衫设计，温和不缩水，保持柔软蓬松。', '蓝月亮', '蓝月亮日化有限公司', '2026-02-10', '500ml/瓶');
INSERT INTO `mall_product` VALUES (7, '彩色衣物护色洗衣液', '洗衣液', 33.80, 'https://th.bing.com/th/id/R.8968100bd539d9db9fe09e8481e16696?rik=Fxhl4r%2fJIV2gPw&pid=ImgRaw&r=0', 99, 59, 1, 7, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '护色锁色，防止深色/彩色衣物串色褪色，机洗更安心。', '奥妙', '联合利华日化有限公司', '2026-02-18', '2kg/瓶');
INSERT INTO `mall_product` VALUES (8, '洗衣机槽清洁剂（4袋装）', '去渍剂', 18.80, 'https://m.360buyimg.com/mobilecms/s750x750_jfs/t1/30867/27/20912/196108/63feefaeF096ae35c/bb080b58ab9989b2.jpg!q80.dpg', 249, 111, 1, 8, '2026-03-07 15:18:45', '2026-03-18 13:03:35', '清洁洗衣机内筒污垢与细菌，定期使用延长洗衣机寿命。4袋装。', '威王', '威王清洁用品有限公司', '2026-02-14', '4袋/盒');
INSERT INTO `mall_product` VALUES (9, '真丝专用洗涤剂（500ml）', '洗衣液', 42.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01ZPICGi277YGXe1EmZ_!!2200937750-0-cib.jpg?__r__=1652939075076', 60, 28, 1, 9, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '真丝、桑蚕丝专用，中性温和，手洗不伤面料，保持光泽。', '花王', '花王日化有限公司', '2026-01-25', '500ml/瓶');
INSERT INTO `mall_product` VALUES (10, '内衣专用洗衣液（300ml）', '洗衣液', 26.80, 'https://img12.360buyimg.com/n1/s720x720_jfs/t1/208739/17/37331/145526/648d1fb6F0779d0c0/676dde6048b8f290.jpg', 150, 76, 1, 10, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '除菌抑菌配方，专为内衣设计，手洗温和不伤手。', '威露士', '威露士日化有限公司', '2026-02-20', '300ml/瓶');
INSERT INTO `mall_product` VALUES (11, '留香珠（持久留香型 200g）', '护理剂', 35.00, 'https://tse4.mm.bing.net/th/id/OIP.z7kWAShSsO_eiLxUtwsCMgHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 100, 52, 1, 11, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '持久留香型，洗衣时加入，衣物晾干后清香怡人。', '香满衣', '香满衣日化有限公司', '2026-02-08', '200g/瓶');
INSERT INTO `mall_product` VALUES (12, '防串色洗衣片（36片装）', '去渍剂', 28.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01kpaSHV1QOvp7rzF9a_!!2208142421967-0-cib.jpg?__r__=1655717763706', 180, 90, 1, 12, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '洗衣时放入一片，吸附游离染料，防止深浅色衣物串色。36片装。', '护色宝', '护色宝日化有限公司', '2026-02-07', '36片/盒');
INSERT INTO `mall_product` VALUES (13, '洗衣筐（大号 可折叠）', '洗衣袋', 45.00, 'https://cbu01.alicdn.com/img/ibank/2019/935/313/11041313539_1786316636.jpg', 80, 35, 1, 13, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '大号可折叠，收纳脏衣或晾晒小件，节省空间。', '收纳生活', '收纳生活家居用品厂', '2026-01-22', '大号可折叠');
INSERT INTO `mall_product` VALUES (14, '网兜洗衣袋（3件套 细网）', '洗衣袋', 22.00, 'https://img.11665.com/img_p5/i1/2206821304235/O1CN01VXcJul1h9g5QVgSlI_!!0-item_pic.jpg', 200, 88, 1, 14, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '细网保护内衣、针织等易勾丝衣物，机洗不缠绕。3件套。', '网护', '网护家居用品厂', '2026-02-01', '3件/套');
INSERT INTO `mall_product` VALUES (15, '毛球修剪器（充电式）', '护理剂', 39.90, 'https://tse4.mm.bing.net/th/id/OIP.bLmY_wiMfSdvKaTZXuKpkAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 120, 64, 1, 15, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '充电式，去除毛衣、大衣上的毛球，恢复平整。', '依魅', '依魅电器有限公司', '2025-12-15', '充电式');
INSERT INTO `mall_product` VALUES (16, '便携式挂烫机', '护理剂', 89.00, 'https://th.bing.com/th/id/R.cea305af52be3d97efe30d5ef67f1641?rik=RmD42UWOVI9gMA&pid=ImgRaw&r=0', 50, 22, 1, 16, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '便携设计，出差旅行可带，快速熨平褶皱。', '苏泊尔', '苏泊尔电器有限公司', '2025-11-20', '便携式');
INSERT INTO `mall_product` VALUES (17, '鞋类清洁护理套装', '去渍剂', 48.00, 'https://tse2.mm.bing.net/th/id/OIP.atMwuW2Yr8hbx0qkXeN7RwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 90, 41, 1, 17, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '含清洁剂、护理刷等，鞋面去污、除臭、保养一站式。', '洁美家', '洁美家日用品有限公司', '2026-01-30', '套装（清洁剂+刷子）');
INSERT INTO `mall_product` VALUES (18, '皮革保养油（100ml）', '护理剂', 55.00, 'https://down-tw.img.susercontent.com/file/tw-11134207-7r992-lv2k3ljgyprsba', 70, 30, 1, 18, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '真皮、皮革包包鞋子保养，去污上光，延长使用寿命。', '皮博士', '皮博士皮革护理有限公司', '2026-01-05', '100ml/瓶');
INSERT INTO `mall_product` VALUES (19, '羽绒服专用清洗剂（500ml）', '洗衣液', 38.00, 'https://tse1.mm.bing.net/th/id/OIP.5r5aIZEXWSJXfQhRCeuw6wHaMc?rs=1&pid=ImgDetMain&o=7&rm=3', 100, 55, 1, 19, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '羽绒服专用，洗后蓬松不结块，保持保暖性。', '羽洁', '羽洁日化有限公司', '2026-01-28', '500ml/瓶');
INSERT INTO `mall_product` VALUES (20, '婴儿衣物洗衣液（1L）', '洗衣液', 45.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01nbq1iN1cisdMAvtjU_!!2211410483635-0-cib.310x310.jpg', 85, 48, 1, 20, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '无荧光剂、温和配方，专为婴儿衣物及敏感肌设计。', '榄菊', '榄菊日化有限公司', '2026-02-05', '1L/瓶');
INSERT INTO `mall_product` VALUES (21, '除菌除螨洗衣液（2kg）', '洗衣液', 52.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01PXKTa72E0s4pzDzTh_!!2216822228683-0-cib.310x310.jpg', 110, 62, 1, 21, '2026-03-07 15:44:46', '2026-03-18 13:03:35', '除菌除螨，适合床品、内衣、儿童衣物，2kg大容量。', '滴露', '滴露日化有限公司', '2026-02-12', '2kg/瓶');
INSERT INTO `mall_product` VALUES (22, '中性洗衣皂（3块装）', '洗衣液', 15.80, 'https://img.alicdn.com/bao/uploaded/i4/3229165967/O1CN01rwaFpM1tww9exNN2G_!!3229165967.jpg', 250, 135, 1, 22, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '中性皂基，手洗温和，适合贴身衣物与婴幼儿衣物。3块装。', '雕牌', '纳爱斯日化有限公司', '2026-02-22', '3块/包');
INSERT INTO `mall_product` VALUES (23, '漂白剂（1L 含氯）', '去渍剂', 18.00, 'https://img.alicdn.com/imgextra/i2/6000000003099/O1CN01EZwwRQ1YlOPOvZNWe_!!6000000003099-0-at.jpg', 140, 72, 1, 23, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '白色衣物漂白增白，含氯配方，勿与彩色衣物同用。1L。', '雪豹', '雪豹日化有限公司', '2026-01-15', '1L/瓶');
INSERT INTO `mall_product` VALUES (24, '柔顺纸（烘干机用 120抽）', '护理剂', 32.00, 'https://tse1.mm.bing.net/th/id/OIP.Z-b33fKZhtPLACEigRt14wHaMG?rs=1&pid=ImgDetMain&o=7&rm=3', 90, 44, 1, 24, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '烘干机用，减少静电、柔软衣物，120抽。', '宜家', '宜家家居有限公司', '2026-01-10', '120抽/盒');
INSERT INTO `mall_product` VALUES (25, '布艺沙发清洁剂（500ml）', '去渍剂', 36.00, 'https://tse2.mm.bing.net/th/id/OIP.EYCI0rsVYgczi61fca_8UwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 75, 38, 1, 25, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '布艺沙发、窗帘、地毯去污除味，免洗喷雾型。', '布艺洁', '布艺洁家居清洁有限公司', '2026-01-25', '500ml/瓶');
INSERT INTO `mall_product` VALUES (26, '运动鞋除臭喷雾（150ml）', '去渍剂', 22.00, 'https://img.alicdn.com/i1/3323039130/O1CN01CJWoxy2HJar3ZMRyl_!!3323039130.jpg', 160, 82, 1, 26, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '运动鞋、休闲鞋除臭抑菌，喷一喷即可，150ml。', '舒足乐', '舒足乐日化有限公司', '2026-02-02', '150ml/瓶');
INSERT INTO `mall_product` VALUES (27, '衣领净（200ml）', '去渍剂', 19.90, 'https://img12.360buyimg.com/n1/s450x450_jfs/t1/72352/24/24603/133426/64ae5e2bFd759d94a/6b32c48b1e5fd6e4.jpg', 200, 98, 1, 27, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '衣领、袖口等重污渍预涂，再机洗更干净。', '领洁净', '领洁净日化有限公司', '2026-02-11', '200ml/瓶');
INSERT INTO `mall_product` VALUES (28, '防皱喷雾（旅行装 100ml）', '护理剂', 28.00, 'https://tse4.mm.bing.net/th/id/OIP.Ui_vTlaodEChIyKP_n_pHAHaFm?rs=1&pid=ImgDetMain&o=7&rm=3', 110, 56, 1, 28, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '旅行装，临时除皱，无需熨斗，100ml可带上飞机。', '一品净', '一品净日化有限公司', '2026-01-18', '100ml/瓶');
INSERT INTO `mall_product` VALUES (29, '植绒衣架（20只装）', '洗衣袋', 38.00, 'https://img.alicdn.com/bao/uploaded/i3/66405257/O1CN01ExsSNa1ohkbaTCGtz_!!0-item_pic.jpg', 130, 67, 1, 29, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '植绒表面不滑落、不勒痕，挂西装衬衫更平整。20只装。', '衣架先生', '衣架先生家居用品厂', '2026-02-05', '20只/包');
INSERT INTO `mall_product` VALUES (30, '真空压缩袋（大+中+小 5件套）', '洗衣袋', 58.00, 'https://down-tw.img.susercontent.com/file/tw-11134207-7rasl-m1mfnm0lge1710', 70, 33, 1, 30, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '大+中+小 5件套，压缩羽绒服、被子节省空间。', '空间大师', '空间大师收纳用品有限公司', '2026-01-10', '5件/套');
INSERT INTO `mall_product` VALUES (31, '樟脑丸（防蛀 6盒装）', '护理剂', 24.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01jBPxYw1vIkmkUOrXN_!!2216518066150-0-cib.310x310.jpg', 180, 91, 1, 31, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '防蛀防霉，衣柜、抽屉适用，6盒装。', '樟香园', '樟香园日化有限公司', '2026-02-01', '6盒/包');
INSERT INTO `mall_product` VALUES (32, '蒸汽熨斗（手持）', '护理剂', 79.00, 'https://hips.hearstapps.com/hmg-prod/images/cats-1620885368.jpg?crop=0.485xw:0.971xh;0.00817xw,0.0229xh&resize=640:*', 55, 26, 1, 32, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '手持蒸汽熨斗，快速除皱，适合薄衣物与出差。', '美的', '美的电器有限公司', '2025-10-15', '手持式');
INSERT INTO `mall_product` VALUES (33, '洗衣凝珠（18颗装）', '洗衣液', 34.90, 'https://tse1.mm.bing.net/th/id/OIP.Y5DSXmBbL0pi87b5u4MlxAHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 120, 61, 1, 33, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '洗衣凝珠，一次一颗，方便不脏手，18颗装。', '汰渍', '宝洁日化有限公司', '2026-02-14', '18颗/盒');
INSERT INTO `mall_product` VALUES (34, '白鞋增白剂（100ml）', '去渍剂', 29.00, 'https://img.pchome.com.tw/cs/items/DAAZ49A900BTYHP/000001_1633070821.jpg', 95, 47, 1, 34, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '白鞋、帆布鞋增白去黄，100ml。', '鞋美美', '鞋美美日化有限公司', '2026-01-20', '100ml/瓶');
INSERT INTO `mall_product` VALUES (35, '羽绒服护理剂（300ml）', '护理剂', 42.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01Kt4RPR1rTVjyI3bQV_!!2217630505632-0-cib.310x310.jpg', 65, 31, 1, 35, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '羽绒服洗后护理，恢复蓬松，防静电。300ml。', '羽绒洁', '羽绒洁日化有限公司', '2026-01-22', '300ml/瓶');
INSERT INTO `mall_product` VALUES (36, '除静电喷雾（200ml）', '护理剂', 26.00, 'https://tse1.mm.bing.net/th/id/OIP.Noymc8wopHBML6kL4IQuZQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 150, 78, 1, 36, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '秋冬衣物除静电，喷在衣物或梳子上均可。200ml。', '静之源', '静之源日化有限公司', '2026-02-03', '200ml/瓶');
INSERT INTO `mall_product` VALUES (37, '洗衣刷（双面 去毛球）', '洗衣袋', 19.00, 'https://img.pchome.com.tw/cs/items/DAAC1AA900GCWWG/l000002_1701166733.jpg', 220, 105, 1, 37, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '双面设计，一面刷污渍一面去毛球，洗衣必备。', '双面刷', '双面刷日用品厂', '2026-02-14', '双面');
INSERT INTO `mall_product` VALUES (38, '香氛扩香石（衣柜用）', '护理剂', 35.00, 'https://tse4.mm.bing.net/th/id/OIP.RosvN4_dVansTpwFU7UR1wHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 85, 42, 1, 38, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '衣柜、车内扩香，淡香不刺鼻，助眠安神。', '薰衣草坊', '薰衣草坊香氛有限公司', '2026-02-05', '单个装');
INSERT INTO `mall_product` VALUES (39, '免洗去污笔（3支装）', '去渍剂', 32.00, 'https://img.alicdn.com/i2/2635083319/O1CN01X1YO3V1aO9K19o9wJ_!!2635083319.jpg', 100, 52, 1, 39, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '随身去污笔，油渍、咖啡渍即涂即淡，3支装。', '随身净', '随身净日化有限公司', '2026-01-12', '3支/盒');
INSERT INTO `mall_product` VALUES (40, '护色吸色片（40片）', '去渍剂', 25.00, 'https://tse2.mm.bing.net/th/id/OIP.op9HLj6kjHE9SxWTMDTSEQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 170, 86, 1, 40, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '洗衣时放入，吸附染料防串色，护色固色。40片。', '色防卫士', '色防卫士日化有限公司', '2026-02-16', '40片/盒');
INSERT INTO `mall_product` VALUES (41, '大容量脏衣篓（带盖）', '洗衣袋', 49.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01ng6B6J1bN4J2Xlmc6_!!2220549593452-0-cib.310x310.jpg', 80, 39, 1, 41, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '大容量带盖脏衣篓，收纳换洗衣物，带盖防尘。', '收纳生活', '收纳生活家居用品厂', '2026-01-25', '大号带盖');
INSERT INTO `mall_product` VALUES (42, '羊毛洗护二合一（400ml）', '洗衣液', 46.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01w7phEr1wEv1B7TzVp_!!2217127066277-0-cib.310x310.jpg', 72, 36, 1, 42, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '羊毛羊绒洗护二合一，一瓶搞定清洁与护理。400ml。', '多洗', '多洗日化有限公司', '2026-01-30', '400ml/瓶');
INSERT INTO `mall_product` VALUES (43, '消毒液（衣物专用 1L）', '去渍剂', 38.00, 'https://tse4.mm.bing.net/th/id/OIP.Ze00TR1BhhArmgKd18tfOwHaHa?rs=1&pid=ImgDetMain&o=7&rm=3', 95, 50, 1, 43, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '衣物专用消毒液，除菌除螨，可机洗可手洗。1L。', '净安', '净安消毒制品有限公司', '2026-01-28', '1L/瓶');
INSERT INTO `mall_product` VALUES (44, '熨衣板（可折叠 带罩）', '护理剂', 128.00, 'https://cbu01.alicdn.com/img/ibank/O1CN01D6PMcF1ZpnqHCZtne_!!2215801913244-0-cib.310x310.jpg', 40, 18, 1, 44, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '可折叠熨衣板，带罩防烫，收纳方便。', '飞利浦', '飞利浦电器有限公司', '2025-09-10', '可折叠');
INSERT INTO `mall_product` VALUES (45, '防染色巾（5片装）', '去渍剂', 21.00, 'https://cbu01.alicdn.com/img/ibank/2018/575/349/10177943575_469765270.jpg', 190, 92, 1, 45, '2026-03-07 15:49:09', '2026-03-18 13:03:35', '洗衣时放入，防止深色衣物掉色染到浅色，5片装。', '色防卫士', '色防卫士日化有限公司', '2026-02-03', '5片/包');

-- ----------------------------
-- Table structure for mall_store
-- ----------------------------
DROP TABLE IF EXISTS `mall_store`;
CREATE TABLE `mall_store`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '门店名称',
  `address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '详细地址',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `business_hours` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '营业时间',
  `sort_order` int NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_name`(`name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of mall_store
-- ----------------------------
INSERT INTO `mall_store` VALUES (2, '洗衣优选·南山区旗舰店', '南山区科技园路88', '400-888-0002', '9:00-21:00', 2, 1, '2026-03-07 18:45:11', '2026-03-10 16:16:07');
INSERT INTO `mall_store` VALUES (3, '洗衣优选·福田中心店', '福田区福华一路与益田路交汇处', '400-888-0003', '8:30-20:30', 3, 1, '2026-03-07 18:45:11', '2026-03-07 18:45:11');
INSERT INTO `mall_store` VALUES (5, '洗衣优选·宝安店', '宝安区新安街道创业路66号', '400-888-0005', '8:00-20:00', 5, 1, '2026-03-08 12:51:19', '2026-03-08 12:51:19');
INSERT INTO `mall_store` VALUES (6, '洗衣优选·龙岗店', '龙岗区坂田街道五和大道88号', '400-888-0006', '8:30-20:30', 6, 1, '2026-03-08 12:51:19', '2026-03-08 12:51:19');
INSERT INTO `mall_store` VALUES (7, '洗衣优选·盐田店', '盐田区海山街道沙头角商业街22号', '400-888-0007', '9:00-19:00', 7, 1, '2026-03-08 12:51:19', '2026-03-08 12:51:19');
INSERT INTO `mall_store` VALUES (8, '洗衣优选·龙华店', '龙华区民治街道梅龙路128号', '400-888-0008', '8:00-21:00', 8, 1, '2026-03-08 12:51:19', '2026-03-08 12:51:19');
INSERT INTO `mall_store` VALUES (109, '洗衣优选·光明店', '光明区公明街道振明路88号', '400-888-0010', '8:00-20:00', 10, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (110, '洗衣优选·大鹏店', '大鹏新区葵涌街道金业大道36号', '400-888-0011', '9:00-18:00', 11, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (111, '洗衣优选·西丽店', '南山区西丽街道留仙大道210号', '400-888-0012', '8:00-20:00', 12, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (112, '洗衣优选·蛇口店', '南山区蛇口街道海上世界广场', '400-888-0013', '9:00-21:00', 13, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (113, '洗衣优选·华强北店', '福田区华强北路赛格广场旁', '400-888-0014', '9:00-20:00', 14, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (114, '洗衣优选·车公庙店', '福田区车公庙泰然九路', '400-888-0015', '8:30-20:30', 15, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (115, '洗衣优选·布吉店', '龙岗区布吉街道吉华路168号', '400-888-0016', '8:00-20:00', 16, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (116, '洗衣优选·横岗店', '龙岗区横岗街道红棉路88号', '400-888-0017', '8:30-19:30', 17, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (117, '洗衣优选·观澜店', '龙华区观澜街道大和路266号', '400-888-0018', '8:00-20:00', 18, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (118, '洗衣优选·石岩店', '宝安区石岩街道宝石东路', '400-888-0019', '8:30-20:00', 19, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (119, '洗衣优选·松岗店', '宝安区松岗街道东方大道', '400-888-0020', '8:00-19:30', 20, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (120, '洗衣优选·沙井店', '宝安区沙井街道新沙路', '400-888-0021', '8:30-20:00', 21, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (121, '洗衣优选·福永店', '宝安区福永街道福永大道', '400-888-0022', '8:00-20:00', 22, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (122, '洗衣优选·新安二店', '宝安区新安街道建安一路', '400-888-0023', '9:00-20:00', 23, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (123, '洗衣优选·南山后海店', '南山区后海大道与创业路交汇', '400-888-0024', '9:00-21:00', 24, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (124, '洗衣优选·福田香蜜湖店', '福田区香蜜湖街道红荔路', '400-888-0025', '8:30-20:30', 25, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (125, '洗衣优选·罗湖翠竹店', '罗湖区翠竹街道太宁路', '400-888-0026', '8:00-20:00', 26, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (126, '洗衣优选·龙华大浪店', '龙华区大浪街道华荣路', '400-888-0027', '8:00-19:30', 27, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (127, '洗衣优选·龙岗中心城店', '龙岗区龙城街道龙福路', '400-888-0028', '8:30-20:00', 28, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (128, '洗衣优选·坪地店', '龙岗区坪地街道教育路', '400-888-0029', '8:00-19:00', 29, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (129, '洗衣优选·葵涌店', '大鹏新区葵涌街道葵新路', '400-888-0030', '9:00-18:00', 30, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (130, '洗衣优选·南澳店', '大鹏新区南澳街道人民路', '400-888-0031', '9:00-17:30', 31, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (131, '洗衣优选·光明凤凰店', '光明区凤凰街道塘尾社区', '400-888-0032', '8:00-20:00', 32, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (132, '洗衣优选·马田店', '光明区马田街道薯田埔路', '400-888-0033', '8:30-19:30', 33, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (133, '洗衣优选·玉塘店', '光明区玉塘街道田寮路', '400-888-0034', '8:00-20:00', 34, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (134, '洗衣优选·新湖店', '光明区新湖街道楼村大道', '400-888-0035', '8:30-19:30', 35, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (135, '洗衣优选·坑梓店', '坪山区坑梓街道人民路', '400-888-0036', '8:00-20:00', 36, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (136, '洗衣优选·碧岭店', '坪山区碧岭街道沙坑路', '400-888-0037', '8:30-19:00', 37, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (137, '洗衣优选·石井店', '坪山区石井街道金田路', '400-888-0038', '8:00-19:30', 38, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (138, '洗衣优选·燕罗店', '宝安区燕罗街道广田路', '400-888-0039', '8:30-20:00', 39, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (139, '洗衣优选·新桥店', '宝安区新桥街道新桥大道', '400-888-0040', '8:00-20:00', 40, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (140, '洗衣优选·福海店', '宝安区福海街道桥和路', '400-888-0041', '8:30-19:30', 41, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (142, '洗衣优选·西乡店', '宝安区西乡街道宝源路', '400-888-0043', '8:00-20:00', 43, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (143, '洗衣优选·南山科技园店', '南山区科技园南区深南大道', '400-888-0044', '9:00-21:00', 44, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (144, '洗衣优选·福田中心二店', '福田区福华路与中心二路', '400-888-0045', '8:30-20:30', 45, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (145, '洗衣优选·罗湖万象城店', '罗湖区宝安南路万象城', '400-888-0046', '10:00-22:00', 46, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (146, '洗衣优选·龙华民治二店', '龙华区民治街道民治大道', '400-888-0047', '8:00-20:00', 47, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (147, '洗衣优选·龙岗南联店', '龙岗区龙岗街道南联路', '400-888-0048', '8:30-19:30', 48, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (148, '洗衣优选·平湖店', '龙岗区平湖街道守珍街', '400-888-0049', '8:00-20:00', 49, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (149, '洗衣优选·南湾店', '龙岗区南湾街道布沙路', '400-888-0050', '8:30-20:00', 50, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (150, '洗衣优选·坂田二店', '龙岗区坂田街道贝尔路', '400-888-0051', '8:00-20:00', 51, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (151, '洗衣优选·福田梅林店', '福田区梅林街道梅林路', '400-888-0052', '8:30-20:00', 52, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (152, '洗衣优选·南山前海店', '南山区前海自贸区梦海大道', '400-888-0053', '9:00-20:00', 53, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (153, '洗衣优选·罗湖莲塘店', '罗湖区莲塘街道国威路', '400-888-0054', '8:00-19:30', 54, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (154, '洗衣优选·盐田梅沙店', '盐田区梅沙街道环梅路', '400-888-0055', '9:00-18:00', 55, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (155, '洗衣优选·龙华观湖店', '龙华区观湖街道观澜大道', '400-888-0056', '8:00-20:00', 56, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (156, '洗衣优选·大浪时尚店', '龙华区大浪街道华旺路', '400-888-0057', '8:30-19:30', 57, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (157, '洗衣优选·福城店', '龙华区福城街道悦兴路', '400-888-0058', '8:00-19:30', 58, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (158, '洗衣优选·光明公明店', '光明区公明街道松白路', '400-888-0059', '8:30-20:00', 59, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (159, '洗衣优选·光明玉律店', '光明区玉塘街道玉律路', '400-888-0060', '8:00-19:30', 60, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (160, '洗衣优选·坪山龙田店', '坪山区龙田街道龙田路', '400-888-0061', '8:30-19:30', 61, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (161, '洗衣优选·坑梓沙田店', '坪山区坑梓街道沙田路', '400-888-0062', '8:00-19:00', 62, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (162, '洗衣优选·大鹏大鹏店', '大鹏新区大鹏街道鹏新路', '400-888-0063', '9:00-17:30', 63, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (163, '洗衣优选·南澳水头店', '大鹏新区南澳街道水头沙', '400-888-0064', '9:00-17:00', 64, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (164, '洗衣优选·宝安机场东店', '宝安区福永街道机场东地铁站旁', '400-888-0065', '8:00-21:00', 65, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (165, '洗衣优选·南山大学城店', '南山区西丽街道大学城', '400-888-0066', '9:00-20:00', 66, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (166, '洗衣优选·福田莲花店', '福田区莲花街道莲花路', '400-888-0067', '8:30-20:00', 67, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (167, '洗衣优选·罗湖黄贝店', '罗湖区黄贝街道凤凰路', '400-888-0068', '8:00-20:00', 68, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (168, '洗衣优选·盐田盐田店', '盐田区盐田街道北山道', '400-888-0069', '8:30-18:30', 69, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (169, '洗衣优选·龙岗园山店', '龙岗区园山街道银荷路', '400-888-0070', '8:00-19:30', 70, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (170, '洗衣优选·龙岗吉华店', '龙岗区吉华街道甘李路', '400-888-0071', '8:30-20:00', 71, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (171, '洗衣优选·龙岗宝龙店', '龙岗区宝龙街道宝龙大道', '400-888-0072', '8:00-20:00', 72, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (172, '洗衣优选·龙岗平湖华南城店', '龙岗区平湖街道华南城', '400-888-0073', '9:00-20:00', 73, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (173, '洗衣优选·福田八卦岭店', '福田区园岭街道八卦路', '400-888-0074', '8:00-20:00', 74, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (174, '洗衣优选·南山粤海店', '南山区粤海街道后海大道', '400-888-0075', '9:00-21:00', 75, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (175, '洗衣优选·罗湖笋岗店', '罗湖区笋岗街道宝岗路', '400-888-0076', '8:30-20:00', 76, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (176, '洗衣优选·福田华强南店', '福田区南园街道华强南路', '400-888-0077', '8:00-20:00', 77, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (177, '洗衣优选·宝安翻身店', '宝安区新安街道翻身路', '400-888-0078', '8:30-19:30', 78, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (178, '洗衣优选·龙华清湖店', '龙华区龙华街道清泉路', '400-888-0079', '8:00-20:00', 79, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (179, '洗衣优选·龙岗双龙店', '龙岗区龙岗街道龙岗大道', '400-888-0080', '8:30-20:00', 80, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (180, '洗衣优选·坪山马峦店', '坪山区马峦街道比亚迪路', '400-888-0081', '8:00-19:00', 81, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (181, '洗衣优选·光明新湖二店', '光明区新湖街道圳美社区', '400-888-0082', '8:30-19:30', 82, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (182, '洗衣优选·大鹏较场尾店', '大鹏新区大鹏街道较场尾', '400-888-0083', '9:00-18:00', 83, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (183, '洗衣优选·南山桃源店', '南山区桃源街道龙珠大道', '400-888-0084', '8:00-20:00', 84, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (184, '洗衣优选·福田沙头店', '福田区沙头街道福强路', '400-888-0085', '8:30-20:00', 85, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (185, '洗衣优选·罗湖清水河店', '罗湖区清水河街道泥岗路', '400-888-0086', '8:00-19:30', 86, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (186, '洗衣优选·盐田东海店', '盐田区海山街道东海道', '400-888-0087', '9:00-18:00', 87, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (187, '洗衣优选·龙岗坪地二店', '龙岗区坪地街道湖田路', '400-888-0088', '8:00-19:00', 88, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (188, '洗衣优选·宝安航城店', '宝安区航城街道黄田路', '400-888-0089', '8:30-20:00', 89, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (189, '洗衣优选·龙华大浪二店', '龙华区大浪街道华昌路', '400-888-0090', '8:00-19:30', 90, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (190, '洗衣优选·光明凤凰城店', '光明区凤凰街道光明大道', '400-888-0091', '8:30-20:00', 91, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (191, '洗衣优选·坪山坪山站店', '坪山区坪山街道站前路', '400-888-0092', '8:00-20:00', 92, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (192, '洗衣优选·福田上沙店', '福田区沙头街道上沙村', '400-888-0093', '8:30-19:30', 93, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (193, '洗衣优选·南山蛇口二店', '南山区蛇口街道工业七路', '400-888-0094', '9:00-20:00', 94, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (194, '洗衣优选·罗湖东晓店', '罗湖区东晓街道东晓路', '400-888-0095', '8:00-20:00', 95, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (195, '洗衣优选·龙岗横岗二店', '龙岗区横岗街道茂盛路', '400-888-0096', '8:30-19:30', 96, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (196, '洗衣优选·宝安西乡二店', '宝安区西乡街道固戍路', '400-888-0097', '8:00-20:00', 97, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (197, '洗衣优选·龙华龙华店', '龙华区龙华街道人民路', '400-888-0098', '8:30-20:00', 98, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (198, '洗衣优选·福田景田店', '福田区莲花街道景田路', '400-888-0099', '8:00-20:00', 99, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');
INSERT INTO `mall_store` VALUES (199, '洗衣优选·南山华侨城店', '南山区沙河街道华侨城', '400-888-0100', '9:00-21:00', 100, 1, '2026-03-08 21:17:05', '2026-03-08 21:17:05');

-- ----------------------------
-- Table structure for order_comment
-- ----------------------------
DROP TABLE IF EXISTS `order_comment`;
CREATE TABLE `order_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单编号，来自 order_info.order_no',
  `user_id` bigint NOT NULL,
  `target_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SERVICE' COMMENT '评价对象类型：SERVICE/PRODUCT',
  `target_id` bigint NOT NULL COMMENT '评价对象ID',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `score` tinyint NOT NULL DEFAULT 5 COMMENT '1-5分',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reply` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '回复内容',
  `reply_time` datetime NULL DEFAULT NULL COMMENT '回复时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_comment_target`(`target_type` ASC, `target_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_comment_order` FOREIGN KEY (`order_id`) REFERENCES `order_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 196 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_comment
-- ----------------------------
INSERT INTO `order_comment` VALUES (69, 3, 'DC202501010003', 2, 'SERVICE', 5, '店员态度很好，整体体验不错。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (70, 6, 'DC202501010006', 2, 'SERVICE', 20, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (71, 8, 'DC202501010008', 2, 'SERVICE', 3, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (73, 11, 'DC202501020011', 3, 'SERVICE', 4, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (74, 12, 'DC202501020012', 3, 'SERVICE', 8, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (76, 16, 'DC202501020016', 3, 'SERVICE', 18, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (77, 18, 'DC202501020018', 3, 'SERVICE', 1, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (78, 20, 'DC202501020020', 3, 'SERVICE', 12, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (79, 21, 'DC202501030021', 4, 'SERVICE', 3, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (80, 22, 'DC202501030022', 4, 'SERVICE', 9, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (81, 25, 'DC202501030025', 4, 'SERVICE', 5, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (82, 26, 'DC202501030026', 4, 'SERVICE', 17, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (83, 28, 'DC202501030028', 4, 'SERVICE', 2, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (84, 30, 'DC202501030030', 4, 'SERVICE', 22, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (85, 31, 'DC202501040031', 5, 'SERVICE', 6, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (86, 32, 'DC202501040032', 5, 'SERVICE', 13, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (87, 35, 'DC202501040035', 5, 'SERVICE', 26, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (88, 36, 'DC202501040036', 5, 'SERVICE', 7, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (89, 38, 'DC202501040038', 5, 'SERVICE', 4, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (90, 40, 'DC202501040040', 5, 'SERVICE', 28, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (91, 41, 'DC202501050041', 6, 'SERVICE', 1, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (92, 42, 'DC202501050042', 6, 'SERVICE', 10, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (93, 45, 'DC202501050045', 6, 'SERVICE', 14, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (94, 46, 'DC202501050046', 6, 'SERVICE', 23, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (95, 48, 'DC202501050048', 6, 'SERVICE', 18, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (96, 50, 'DC202501050050', 6, 'SERVICE', 20, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (97, 51, 'DC202501060051', 7, 'SERVICE', 3, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (98, 52, 'DC202501060052', 7, 'SERVICE', 12, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (99, 55, 'DC202501060055', 7, 'SERVICE', 17, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (100, 56, 'DC202501060056', 7, 'SERVICE', 24, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (101, 58, 'DC202501060058', 7, 'SERVICE', 11, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (102, 60, 'DC202501060060', 7, 'SERVICE', 15, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (103, 61, 'DC202501070061', 8, 'SERVICE', 4, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (104, 62, 'DC202501070062', 8, 'SERVICE', 13, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (105, 65, 'DC202501070065', 8, 'SERVICE', 6, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (106, 66, 'DC202501070066', 8, 'SERVICE', 20, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (107, 68, 'DC202501070068', 8, 'SERVICE', 14, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (108, 70, 'DC202501070070', 8, 'SERVICE', 10, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (109, 71, 'DC202501080071', 9, 'SERVICE', 5, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (110, 72, 'DC202501080072', 9, 'SERVICE', 18, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (111, 75, 'DC202501080075', 9, 'SERVICE', 23, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (112, 76, 'DC202501080076', 9, 'SERVICE', 8, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (113, 78, 'DC202501080078', 9, 'SERVICE', 3, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (114, 80, 'DC202501080080', 9, 'SERVICE', 22, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (115, 81, 'DC202501090081', 10, 'SERVICE', 7, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (116, 82, 'DC202501090082', 10, 'SERVICE', 11, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (117, 85, 'DC202501090085', 10, 'SERVICE', 12, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (118, 86, 'DC202501090086', 10, 'SERVICE', 24, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (119, 88, 'DC202501090088', 10, 'SERVICE', 4, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (120, 90, 'DC202501090090', 10, 'SERVICE', 28, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (121, 91, 'DC202501100091', 11, 'SERVICE', 2, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (122, 92, 'DC202501100092', 11, 'SERVICE', 10, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (123, 95, 'DC202501100095', 11, 'SERVICE', 1, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (124, 96, 'DC202501100096', 11, 'SERVICE', 23, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (125, 98, 'DC202501100098', 11, 'SERVICE', 14, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (126, 100, 'DC202501100100', 11, 'SERVICE', 6, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (127, 101, 'DC202501110101', 12, 'SERVICE', 3, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (128, 102, 'DC202501110102', 12, 'SERVICE', 8, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (129, 105, 'DC202501110105', 12, 'SERVICE', 15, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (130, 106, 'DC202501110106', 12, 'SERVICE', 19, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (131, 108, 'DC202501110108', 12, 'SERVICE', 9, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (132, 110, 'DC202501110110', 12, 'SERVICE', 7, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (133, 111, 'DC202501120111', 13, 'SERVICE', 4, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (134, 112, 'DC202501120112', 13, 'SERVICE', 11, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (135, 115, 'DC202501120115', 13, 'SERVICE', 10, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (136, 116, 'DC202501120116', 13, 'SERVICE', 21, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (137, 118, 'DC202501120118', 13, 'SERVICE', 12, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (138, 120, 'DC202501120120', 13, 'SERVICE', 5, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (139, 121, 'DC202501130121', 14, 'SERVICE', 6, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (140, 122, 'DC202501130122', 14, 'SERVICE', 13, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (141, 125, 'DC202501130125', 14, 'SERVICE', 2, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (142, 126, 'DC202501130126', 14, 'SERVICE', 24, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (143, 128, 'DC202501130128', 14, 'SERVICE', 16, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (144, 130, 'DC202501130130', 14, 'SERVICE', 8, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (145, 131, 'DC202501140131', 15, 'SERVICE', 7, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (146, 132, 'DC202501140132', 15, 'SERVICE', 15, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (147, 135, 'DC202501140135', 15, 'SERVICE', 4, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (148, 136, 'DC202501140136', 15, 'SERVICE', 22, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (149, 138, 'DC202501140138', 15, 'SERVICE', 19, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (150, 140, 'DC202501140140', 15, 'SERVICE', 11, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (151, 141, 'DC202501150141', 16, 'SERVICE', 1, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (152, 142, 'DC202501150142', 16, 'SERVICE', 12, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (153, 145, 'DC202501150145', 16, 'SERVICE', 17, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (154, 146, 'DC202501150146', 16, 'SERVICE', 23, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (155, 148, 'DC202501150148', 16, 'SERVICE', 10, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (156, 150, 'DC202501150150', 16, 'SERVICE', 6, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (157, 151, 'DC202501160151', 17, 'SERVICE', 3, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (158, 152, 'DC202501160152', 17, 'SERVICE', 8, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (159, 155, 'DC202501160155', 17, 'SERVICE', 18, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (160, 156, 'DC202501160156', 17, 'SERVICE', 13, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (161, 158, 'DC202501160158', 17, 'SERVICE', 20, '干洗效果满意，会再来。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (162, 160, 'DC202501160160', 17, 'SERVICE', 24, '服务很满意，衣服洗得很干净！', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (163, 161, 'DC202501170161', 18, 'SERVICE', 4, '取送及时，下次还会再来。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (164, 162, 'DC202501170162', 18, 'SERVICE', 11, '专业靠谱，羽绒服洗完很蓬松。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (165, 165, 'DC202501170165', 18, 'SERVICE', 5, '第一次来，体验很好。', 5, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (166, 166, 'DC202501170166', 18, 'SERVICE', 21, '价格合适，质量不错。', 4, '2026-03-09 16:02:44', NULL, NULL);
INSERT INTO `order_comment` VALUES (194, 170, 'DC202501170170', 18, 'SERVICE', 10, '洗的很好，很干净', 5, '2026-03-10 14:07:59', NULL, NULL);
INSERT INTO `order_comment` VALUES (195, 313, 'DC1773227265831002B', 10, 'SERVICE', 2, '洗的很干净', 5, '2026-03-19 00:04:09', '谢谢您的使用', '2026-03-19 00:06:34');

-- ----------------------------
-- Table structure for order_info
-- ----------------------------
DROP TABLE IF EXISTS `order_info`;
CREATE TABLE `order_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID（顾客）',
  `service_id` bigint NULL DEFAULT NULL COMMENT '服务ID（order_type=SERVICE）',
  `product_id` bigint NULL DEFAULT NULL COMMENT '商品ID（order_type=PRODUCT）',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '数量',
  `total_price` decimal(10, 2) NOT NULL COMMENT '总价',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING-待接单，WASHING-清洗中，COMPLETED-已完成',
  `pay_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNPAID' COMMENT '支付状态：UNPAID-待支付，PAID-已支付',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `pickup_time` datetime NULL DEFAULT NULL COMMENT '取衣/收衣时间',
  `washing_start_time` datetime NULL DEFAULT NULL COMMENT '清洁开始时间',
  `washing_end_time` datetime NULL DEFAULT NULL COMMENT '清洁结束时间',
  `ready_time` datetime NULL DEFAULT NULL COMMENT '清洁完成/待送回时间',
  `delivery_time` datetime NULL DEFAULT NULL COMMENT '送回/配送时间',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `address_id` bigint NULL DEFAULT NULL COMMENT '收货地址ID',
  `delivery_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'DOOR_TO_DOOR' COMMENT 'DOOR_TO_DOOR=上门取送 IN_STORE=到店',
  `store_id` bigint NULL DEFAULT NULL COMMENT '到店自取时的门店ID',
  `order_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SERVICE',
  `pickup_date` date NULL DEFAULT NULL COMMENT '预计取衣日期',
  `urgent` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否加急 0=否 1=是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_service_id`(`service_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_order_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_order_service` FOREIGN KEY (`service_id`) REFERENCES `dry_service` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 321 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_info
-- ----------------------------
INSERT INTO `order_info` VALUES (1, 'DC202501010001', 2, 1, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-01 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (2, 'DC202501010002', 2, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-01 12:00:00', NULL, NULL, NULL, NULL, NULL, '请轻洗', '2025-01-01 10:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (3, 'DC202501010003', 2, 5, NULL, 2, 30.00, 'COMPLETED', 'PAID', '2025-01-01 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (4, 'DC202501010004', 2, 14, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-02 09:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (5, 'DC202501010005', 2, 7, NULL, 1, 38.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 10:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (6, 'DC202501010006', 2, 20, NULL, 1, 60.00, 'COMPLETED', 'PAID', '2025-01-03 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (7, 'DC202501010007', 2, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '皮衣请小心', '2025-01-04 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (8, 'DC202501010008', 2, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-05 11:00:00', NULL, NULL, NULL, NULL, NULL, '羊绒大衣', '2025-01-05 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (9, 'DC202501010009', 2, 22, NULL, 1, 80.00, 'WASHING', 'PAID', '2025-01-06 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (10, 'DC202501010010', 2, 15, NULL, 2, 56.00, 'COMPLETED', 'PAID', '2025-01-07 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (11, 'DC202501020011', 3, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-01 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 10:15:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (12, 'DC202501020012', 3, 8, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-01 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 10:45:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (13, 'DC202501020013', 3, 14, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-02 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (14, 'DC202501020014', 3, 21, NULL, 1, 35.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (15, 'DC202501020015', 3, 6, NULL, 3, 36.00, 'COMPLETED', 'PAID', '2025-01-04 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (16, 'DC202501020016', 3, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-05 16:00:00', NULL, NULL, NULL, NULL, NULL, '靴子', '2025-01-05 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (17, 'DC202501020017', 3, 10, NULL, 1, 28.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (18, 'DC202501020018', 3, 1, NULL, 2, 70.00, 'COMPLETED', 'PAID', '2025-01-07 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (19, 'DC202501020019', 3, 23, NULL, 1, 55.00, 'WASHING', 'PAID', '2025-01-08 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (20, 'DC202501020020', 3, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-09 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (21, 'DC202501030021', 4, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-01 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (22, 'DC202501030022', 4, 9, NULL, 1, 88.00, 'COMPLETED', 'PAID', '2025-01-02 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (23, 'DC202501030023', 4, 16, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 09:00:00', NULL, NULL, NULL, NULL, NULL, '雪地靴', '2025-01-03 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (24, 'DC202501030024', 4, 20, NULL, 1, 60.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (25, 'DC202501030025', 4, 5, NULL, 3, 45.00, 'COMPLETED', 'PAID', '2025-01-05 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (26, 'DC202501030026', 4, 17, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-06 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (27, 'DC202501030027', 4, 24, NULL, 1, 45.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 14:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (28, 'DC202501030028', 4, 2, NULL, 2, 90.00, 'COMPLETED', 'PAID', '2025-01-08 11:00:00', NULL, NULL, NULL, NULL, NULL, '请轻洗', '2025-01-08 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (29, 'DC202501030029', 4, 11, NULL, 1, 20.00, 'WASHING', 'PAID', '2025-01-09 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (30, 'DC202501030030', 4, 22, NULL, 1, 80.00, 'COMPLETED', 'PAID', '2025-01-10 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (31, 'DC202501040031', 5, 6, NULL, 2, 24.00, 'COMPLETED', 'PAID', '2025-01-01 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (32, 'DC202501040032', 5, 13, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-02 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (33, 'DC202501040033', 5, 19, NULL, 1, 20.00, 'WASHING', 'PAID', '2025-01-03 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (34, 'DC202501040034', 5, 25, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '玩偶', '2025-01-04 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (35, 'DC202501040035', 5, 26, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-05 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (36, 'DC202501040036', 5, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-06 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (37, 'DC202501040037', 5, 15, NULL, 2, 56.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 15:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (38, 'DC202501040038', 5, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-08 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (39, 'DC202501040039', 5, 27, NULL, 2, 30.00, 'WASHING', 'PAID', '2025-01-09 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (40, 'DC202501040040', 5, 28, NULL, 1, 12.00, 'COMPLETED', 'PAID', '2025-01-10 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (41, 'DC202501050041', 6, 1, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-01 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (42, 'DC202501050042', 6, 10, NULL, 2, 56.00, 'COMPLETED', 'PAID', '2025-01-02 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (43, 'DC202501050043', 6, 21, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (44, 'DC202501050044', 6, 8, NULL, 1, 18.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (45, 'DC202501050045', 6, 14, NULL, 2, 50.00, 'COMPLETED', 'PAID', '2025-01-05 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (46, 'DC202501050046', 6, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-06 17:00:00', NULL, NULL, NULL, NULL, NULL, '沙发套', '2025-01-06 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (47, 'DC202501050047', 6, 2, NULL, 1, 45.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 16:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (48, 'DC202501050048', 6, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-08 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (49, 'DC202501050049', 6, 5, NULL, 4, 60.00, 'WASHING', 'PAID', '2025-01-09 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (50, 'DC202501050050', 6, 20, NULL, 1, 60.00, 'COMPLETED', 'PAID', '2025-01-10 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (51, 'DC202501060051', 7, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-01 17:00:00', NULL, NULL, NULL, NULL, NULL, '羊绒', '2025-01-01 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (52, 'DC202501060052', 7, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-02 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (53, 'DC202501060053', 7, 16, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (54, 'DC202501060054', 7, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (55, 'DC202501060055', 7, 17, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-05 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (56, 'DC202501060056', 7, 24, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-06 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (57, 'DC202501060057', 7, 7, NULL, 2, 76.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 17:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (58, 'DC202501060058', 7, 11, NULL, 2, 40.00, 'COMPLETED', 'PAID', '2025-01-08 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (59, 'DC202501060059', 7, 22, NULL, 1, 80.00, 'WASHING', 'PAID', '2025-01-09 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (60, 'DC202501060060', 7, 15, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-10 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (61, 'DC202501070061', 8, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-01 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (62, 'DC202501070062', 8, 13, NULL, 2, 44.00, 'COMPLETED', 'PAID', '2025-01-02 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (63, 'DC202501070063', 8, 19, NULL, 1, 20.00, 'WASHING', 'PAID', '2025-01-03 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (64, 'DC202501070064', 8, 26, NULL, 1, 22.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (65, 'DC202501070065', 8, 6, NULL, 2, 24.00, 'COMPLETED', 'PAID', '2025-01-05 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (66, 'DC202501070066', 8, 20, NULL, 1, 60.00, 'COMPLETED', 'PAID', '2025-01-06 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (67, 'DC202501070067', 8, 1, NULL, 2, 70.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 18:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (68, 'DC202501070068', 8, 14, NULL, 1, 25.00, 'COMPLETED', 'PAID', '2025-01-08 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (69, 'DC202501070069', 8, 21, NULL, 2, 70.00, 'WASHING', 'PAID', '2025-01-09 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (70, 'DC202501070070', 8, 10, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-10 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (71, 'DC202501080071', 9, 5, NULL, 3, 45.00, 'COMPLETED', 'PAID', '2025-01-01 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (72, 'DC202501080072', 9, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-02 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (73, 'DC202501080073', 9, 25, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-03 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (74, 'DC202501080074', 9, 2, NULL, 2, 90.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '请轻洗', '2025-01-04 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (75, 'DC202501080075', 9, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-05 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (76, 'DC202501080076', 9, 8, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-06 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (77, 'DC202501080077', 9, 27, NULL, 1, 15.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 19:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (78, 'DC202501080078', 9, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-08 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (79, 'DC202501080079', 9, 15, NULL, 2, 56.00, 'WASHING', 'PAID', '2025-01-09 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (80, 'DC202501080080', 9, 22, NULL, 1, 80.00, 'COMPLETED', 'PAID', '2025-01-10 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (81, 'DC202501090081', 10, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-01 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (82, 'DC202501090082', 10, 11, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-02 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (83, 'DC202501090083', 10, 16, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (84, 'DC202501090084', 10, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (85, 'DC202501090085', 10, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-05 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (86, 'DC202501090086', 10, 24, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-06 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (87, 'DC202501090087', 10, 20, NULL, 1, 60.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 20:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (88, 'DC202501090088', 10, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-08 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (89, 'DC202501090089', 10, 17, NULL, 2, 36.00, 'WASHING', 'PAID', '2025-01-09 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (90, 'DC202501090090', 10, 28, NULL, 2, 24.00, 'COMPLETED', 'PAID', '2025-01-10 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (91, 'DC202501100091', 11, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-01 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-01 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-04', 0);
INSERT INTO `order_info` VALUES (92, 'DC202501100092', 11, 10, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-02 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (93, 'DC202501100093', 11, 21, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (94, 'DC202501100094', 11, 13, NULL, 1, 22.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 20:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (95, 'DC202501100095', 11, 1, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-05 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (96, 'DC202501100096', 11, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-06 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (97, 'DC202501100097', 11, 5, NULL, 2, 30.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 21:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (98, 'DC202501100098', 11, 14, NULL, 2, 50.00, 'COMPLETED', 'PAID', '2025-01-08 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (99, 'DC202501100099', 11, 18, NULL, 1, 42.00, 'WASHING', 'PAID', '2025-01-09 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (100, 'DC202501100100', 11, 6, NULL, 3, 36.00, 'COMPLETED', 'PAID', '2025-01-10 23:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (101, 'DC202501110101', 12, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-02 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (102, 'DC202501110102', 12, 8, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-02 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 09:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (103, 'DC202501110103', 12, 14, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-02 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (104, 'DC202501110104', 12, 22, NULL, 1, 80.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (105, 'DC202501110105', 12, 15, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-03 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (106, 'DC202501110106', 12, 19, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-04 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (107, 'DC202501110107', 12, 26, NULL, 1, 22.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 14:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (108, 'DC202501110108', 12, 9, NULL, 1, 88.00, 'COMPLETED', 'PAID', '2025-01-06 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (109, 'DC202501110109', 12, 20, NULL, 1, 60.00, 'WASHING', 'PAID', '2025-01-07 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (110, 'DC202501110110', 12, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-08 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (111, 'DC202501120111', 13, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-02 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 10:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (112, 'DC202501120112', 13, 11, NULL, 2, 40.00, 'COMPLETED', 'PAID', '2025-01-02 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (113, 'DC202501120113', 13, 17, NULL, 1, 18.00, 'WASHING', 'PAID', '2025-01-03 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (114, 'DC202501120114', 13, 25, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (115, 'DC202501120115', 13, 10, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-05 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (116, 'DC202501120116', 13, 21, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-06 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (117, 'DC202501120117', 13, 1, NULL, 2, 70.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 16:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (118, 'DC202501120118', 13, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-08 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (119, 'DC202501120119', 13, 23, NULL, 1, 55.00, 'WASHING', 'PAID', '2025-01-09 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (120, 'DC202501120120', 13, 5, NULL, 2, 30.00, 'COMPLETED', 'PAID', '2025-01-09 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (121, 'DC202501130121', 14, 6, NULL, 1, 12.00, 'COMPLETED', 'PAID', '2025-01-02 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 12:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (122, 'DC202501130122', 14, 13, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-02 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (123, 'DC202501130123', 14, 18, NULL, 1, 42.00, 'WASHING', 'PAID', '2025-01-03 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (124, 'DC202501130124', 14, 27, NULL, 1, 15.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (125, 'DC202501130125', 14, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-05 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (126, 'DC202501130126', 14, 24, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-06 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (127, 'DC202501130127', 14, 3, NULL, 1, 68.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 17:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (128, 'DC202501130128', 14, 16, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-08 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (129, 'DC202501130129', 14, 28, NULL, 2, 24.00, 'WASHING', 'PAID', '2025-01-09 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (130, 'DC202501130130', 14, 8, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-10 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (131, 'DC202501140131', 15, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-02 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 14:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (132, 'DC202501140132', 15, 15, NULL, 2, 56.00, 'COMPLETED', 'PAID', '2025-01-02 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (133, 'DC202501140133', 15, 20, NULL, 1, 60.00, 'WASHING', 'PAID', '2025-01-03 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (134, 'DC202501140134', 15, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (135, 'DC202501140135', 15, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-05 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (136, 'DC202501140136', 15, 22, NULL, 1, 80.00, 'COMPLETED', 'PAID', '2025-01-06 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (137, 'DC202501140137', 15, 14, NULL, 1, 25.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 18:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (138, 'DC202501140138', 15, 19, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-08 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (139, 'DC202501140139', 15, 26, NULL, 1, 22.00, 'WASHING', 'PAID', '2025-01-09 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (140, 'DC202501140140', 15, 11, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-10 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (141, 'DC202501150141', 16, 1, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-02 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 16:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (142, 'DC202501150142', 16, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-02 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-02 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-05', 0);
INSERT INTO `order_info` VALUES (143, 'DC202501150143', 16, 21, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (144, 'DC202501150144', 16, 5, NULL, 3, 45.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (145, 'DC202501150145', 16, 17, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-05 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (146, 'DC202501150146', 16, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-06 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (147, 'DC202501150147', 16, 2, NULL, 2, 90.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, '请轻洗', '2025-01-07 19:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (148, 'DC202501150148', 16, 10, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-08 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (149, 'DC202501150149', 16, 25, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-09 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (150, 'DC202501150150', 16, 6, NULL, 2, 24.00, 'COMPLETED', 'PAID', '2025-01-10 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 20:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-13', 0);
INSERT INTO `order_info` VALUES (151, 'DC202501160151', 17, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-03 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (152, 'DC202501160152', 17, 8, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-03 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 09:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (153, 'DC202501160153', 17, 14, NULL, 2, 50.00, 'WASHING', 'PAID', '2025-01-03 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (154, 'DC202501160154', 17, 22, NULL, 1, 80.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (155, 'DC202501160155', 17, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-04 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (156, 'DC202501160156', 17, 13, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-05 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (157, 'DC202501160157', 17, 9, NULL, 1, 88.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (158, 'DC202501160158', 17, 20, NULL, 1, 60.00, 'COMPLETED', 'PAID', '2025-01-06 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (159, 'DC202501160159', 17, 7, NULL, 1, 38.00, 'WASHING', 'PAID', '2025-01-07 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (160, 'DC202501160160', 17, 24, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-08 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (161, 'DC202501170161', 18, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-03 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (162, 'DC202501170162', 18, 11, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-03 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 11:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (163, 'DC202501170163', 18, 16, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-03 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (164, 'DC202501170164', 18, 27, NULL, 2, 30.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (165, 'DC202501170165', 18, 5, NULL, 1, 15.00, 'COMPLETED', 'PAID', '2025-01-04 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (166, 'DC202501170166', 18, 21, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-05 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (167, 'DC202501170167', 18, 1, NULL, 1, 35.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 16:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (168, 'DC202501170168', 18, 15, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-06 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (169, 'DC202501170169', 18, 28, NULL, 1, 12.00, 'WASHING', 'PAID', '2025-01-07 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (170, 'DC202501170170', 18, 10, NULL, 2, 56.00, 'COMPLETED', 'PAID', '2025-01-08 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (171, 'DC202501180171', 19, 6, NULL, 1, 12.00, 'COMPLETED', 'PAID', '2025-01-03 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (172, 'DC202501180172', 19, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-03 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 13:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (173, 'DC202501180173', 19, 19, NULL, 1, 20.00, 'WASHING', 'PAID', '2025-01-03 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (174, 'DC202501180174', 19, 26, NULL, 1, 22.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (175, 'DC202501180175', 19, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-04 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (176, 'DC202501180176', 19, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-05 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (177, 'DC202501180177', 19, 3, NULL, 1, 68.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 18:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (178, 'DC202501180178', 19, 17, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-06 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (179, 'DC202501180179', 19, 20, NULL, 1, 60.00, 'WASHING', 'PAID', '2025-01-07 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (180, 'DC202501180180', 19, 8, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-08 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (181, 'DC202501190181', 20, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-03 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (182, 'DC202501190182', 20, 13, NULL, 2, 44.00, 'COMPLETED', 'PAID', '2025-01-03 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 15:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (183, 'DC202501190183', 20, 18, NULL, 1, 42.00, 'WASHING', 'PAID', '2025-01-03 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (184, 'DC202501190184', 20, 25, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (185, 'DC202501190185', 20, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-04 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (186, 'DC202501190186', 20, 22, NULL, 1, 80.00, 'COMPLETED', 'PAID', '2025-01-05 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (187, 'DC202501190187', 20, 14, NULL, 1, 25.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 20:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (188, 'DC202501190188', 20, 21, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-06 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 20:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (189, 'DC202501190189', 20, 9, NULL, 1, 88.00, 'WASHING', 'PAID', '2025-01-07 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (190, 'DC202501190190', 20, 11, NULL, 1, 20.00, 'COMPLETED', 'PAID', '2025-01-08 23:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 21:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (191, 'DC202501200191', 21, 1, NULL, 2, 70.00, 'COMPLETED', 'PAID', '2025-01-03 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (192, 'DC202501200192', 21, 10, NULL, 1, 28.00, 'COMPLETED', 'PAID', '2025-01-03 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 17:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (193, 'DC202501200193', 21, 24, NULL, 1, 45.00, 'WASHING', 'PAID', '2025-01-03 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-03 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-06', 0);
INSERT INTO `order_info` VALUES (194, 'DC202501200194', 21, 5, NULL, 2, 30.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (195, 'DC202501200195', 21, 16, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-04 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 20:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (196, 'DC202501200196', 21, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2025-01-05 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (197, 'DC202501200197', 21, 23, NULL, 1, 55.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 22:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (198, 'DC202501200198', 21, 6, NULL, 2, 24.00, 'COMPLETED', 'PAID', '2025-01-06 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 22:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (199, 'DC202501200199', 21, 17, NULL, 1, 18.00, 'WASHING', 'PAID', '2025-01-07 23:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 21:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (200, 'DC202501200200', 21, 28, NULL, 1, 12.00, 'COMPLETED', 'PAID', '2025-01-08 01:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 23:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (201, 'DC202501210201', 22, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-04 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 09:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (202, 'DC202501210202', 22, 8, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2025-01-04 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 09:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (203, 'DC202501210203', 22, 15, NULL, 2, 56.00, 'WASHING', 'PAID', '2025-01-04 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 10:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (204, 'DC202501210204', 22, 20, NULL, 1, 60.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (205, 'DC202501210205', 22, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-05 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (206, 'DC202501210206', 22, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-06 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (207, 'DC202501210207', 22, 9, NULL, 1, 88.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 16:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (208, 'DC202501210208', 22, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-07 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (209, 'DC202501210209', 22, 22, NULL, 1, 80.00, 'WASHING', 'PAID', '2025-01-08 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (210, 'DC202501210210', 22, 13, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-09 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (211, 'DC202501220211', 23, 5, NULL, 1, 15.00, 'COMPLETED', 'PAID', '2025-01-04 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 11:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (212, 'DC202501220212', 23, 11, NULL, 2, 40.00, 'COMPLETED', 'PAID', '2025-01-04 13:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 11:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (213, 'DC202501220213', 23, 19, NULL, 1, 20.00, 'WASHING', 'PAID', '2025-01-04 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 12:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (214, 'DC202501220214', 23, 26, NULL, 1, 22.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (215, 'DC202501220215', 23, 2, NULL, 2, 90.00, 'COMPLETED', 'PAID', '2025-01-05 16:00:00', NULL, NULL, NULL, NULL, NULL, '请轻洗', '2025-01-05 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (216, 'DC202501220216', 23, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-06 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (217, 'DC202501220217', 23, 1, NULL, 1, 35.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 18:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (218, 'DC202501220218', 23, 14, NULL, 2, 50.00, 'COMPLETED', 'PAID', '2025-01-07 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (219, 'DC202501220219', 23, 21, NULL, 1, 35.00, 'WASHING', 'PAID', '2025-01-08 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (220, 'DC202501220220', 23, 6, NULL, 3, 36.00, 'COMPLETED', 'PAID', '2025-01-09 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (221, 'DC202501230221', 24, 7, NULL, 1, 38.00, 'COMPLETED', 'PAID', '2025-01-04 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 13:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (222, 'DC202501230222', 24, 16, NULL, 1, 35.00, 'COMPLETED', 'PAID', '2025-01-04 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 13:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (223, 'DC202501230223', 24, 20, NULL, 1, 60.00, 'WASHING', 'PAID', '2025-01-04 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 14:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (224, 'DC202501230224', 24, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (225, 'DC202501230225', 24, 3, NULL, 1, 68.00, 'COMPLETED', 'PAID', '2025-01-05 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (226, 'DC202501230226', 24, 23, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-06 19:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (227, 'DC202501230227', 24, 10, NULL, 1, 28.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 20:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (228, 'DC202501230228', 24, 17, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-07 22:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 20:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (229, 'DC202501230229', 24, 25, NULL, 1, 25.00, 'WASHING', 'PAID', '2025-01-08 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (230, 'DC202501230230', 24, 4, NULL, 1, 55.00, 'COMPLETED', 'PAID', '2025-01-09 23:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 21:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (231, 'DC202501240231', 25, 12, NULL, 1, 48.00, 'COMPLETED', 'PAID', '2025-01-04 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 15:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (232, 'DC202501240232', 25, 13, NULL, 1, 22.00, 'COMPLETED', 'PAID', '2025-01-04 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 15:30:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (233, 'DC202501240233', 25, 22, NULL, 1, 80.00, 'WASHING', 'PAID', '2025-01-04 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-04 16:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-07', 0);
INSERT INTO `order_info` VALUES (234, 'DC202501240234', 25, 24, NULL, 1, 45.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 17:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (235, 'DC202501240235', 25, 8, NULL, 2, 36.00, 'COMPLETED', 'PAID', '2025-01-05 20:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-05 18:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-08', 0);
INSERT INTO `order_info` VALUES (236, 'DC202501240236', 25, 18, NULL, 1, 42.00, 'COMPLETED', 'PAID', '2025-01-06 21:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 19:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-09', 0);
INSERT INTO `order_info` VALUES (237, 'DC202501240237', 25, 1, NULL, 1, 35.00, 'AWAIT_PICKUP', 'PAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 22:00:00', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (238, 'DC202501240238', 25, 27, NULL, 1, 15.00, 'COMPLETED', 'PAID', '2025-01-07 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-07 23:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-10', 0);
INSERT INTO `order_info` VALUES (239, 'DC202501240239', 25, 28, NULL, 2, 24.00, 'WASHING', 'PAID', '2025-01-08 23:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 21:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-11', 0);
INSERT INTO `order_info` VALUES (240, 'DC202501240240', 25, 5, NULL, 2, 30.00, 'COMPLETED', 'PAID', '2025-01-09 01:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-09 23:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2025-01-12', 0);
INSERT INTO `order_info` VALUES (241, 'DC17728745952332B35', 10, 2, NULL, 1, 45.00, 'AWAIT_PICKUP', 'PAID', '2026-03-07 17:10:32', NULL, NULL, NULL, NULL, NULL, '', '2026-03-07 17:09:55', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-10', 0);
INSERT INTO `order_info` VALUES (242, 'DC1772875600810AB34', 10, 2, NULL, 2, 90.00, 'AWAIT_PICKUP', 'PAID', '2026-03-07 18:46:23', NULL, NULL, NULL, NULL, NULL, '', '2026-03-07 17:26:41', '2026-03-18 13:39:13', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-10', 0);
INSERT INTO `order_info` VALUES (243, 'DC1772880393518B524', 10, 2, NULL, 1, 45.00, 'AWAIT_PICKUP', 'PAID', '2026-03-09 17:30:02', NULL, NULL, NULL, NULL, NULL, '', '2026-03-07 18:46:34', '2026-03-18 13:39:13', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-10', 0);
INSERT INTO `order_info` VALUES (244, 'DC202502010101', 3, 2, NULL, 2, 90.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-01 09:10:00', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-04', 0);
INSERT INTO `order_info` VALUES (245, 'DC202502010102', 4, 1, NULL, 1, 35.00, 'ACCEPTED', 'PAID', '2026-02-01 10:20:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-01 09:30:00', '2026-03-18 13:21:04', 4, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-04', 0);
INSERT INTO `order_info` VALUES (246, 'DC202502010103', 5, 3, NULL, 1, 68.00, 'WASHING', 'PAID', '2026-02-01 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-01 10:00:00', '2026-03-18 13:21:04', 5, 'IN_STORE', 1, 'SERVICE', '2026-02-04', 0);
INSERT INTO `order_info` VALUES (247, 'DC202502020104', 6, 4, NULL, 2, 110.00, 'COMPLETED', 'PAID', '2026-02-02 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-02 11:00:00', '2026-03-18 13:21:04', 6, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-05', 0);
INSERT INTO `order_info` VALUES (248, 'DC202502020105', 7, 5, NULL, 3, 45.00, 'COMPLETED', 'PAID', '2026-02-02 15:30:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-02 12:00:00', '2026-03-18 13:21:04', 7, 'IN_STORE', 2, 'SERVICE', '2026-02-05', 0);
INSERT INTO `order_info` VALUES (249, 'DC202502030106', 8, 6, NULL, 2, 24.00, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '用户取消', '2026-02-03 08:00:00', '2026-03-18 13:21:04', NULL, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-06', 0);
INSERT INTO `order_info` VALUES (250, 'DC202502030107', 9, 7, NULL, 1, 38.00, 'AWAIT_DROP', 'PAID', '2026-02-03 09:15:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-03 09:00:00', '2026-03-18 13:39:13', 9, 'IN_STORE', 1, 'SERVICE', '2026-02-06', 0);
INSERT INTO `order_info` VALUES (251, 'DC202502040108', 10, 8, NULL, 1, 18.00, 'ACCEPTED', 'PAID', '2026-02-04 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-04 09:45:00', '2026-03-18 13:21:04', 10, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-07', 0);
INSERT INTO `order_info` VALUES (252, 'DC202502040109', 3, 9, NULL, 1, 88.00, 'WASHING', 'PAID', '2026-02-04 11:20:00', NULL, NULL, NULL, NULL, NULL, '皮衣请轻洗', '2026-02-04 10:30:00', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-02-07', 0);
INSERT INTO `order_info` VALUES (253, 'DC202502050110', 4, 10, NULL, 2, 56.00, 'COMPLETED', 'PAID', '2026-02-05 16:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-05 11:00:00', '2026-03-18 13:21:04', 4, 'IN_STORE', 3, 'SERVICE', '2026-02-08', 0);
INSERT INTO `order_info` VALUES (254, 'DC202503010111', 5, 1, NULL, 2, 70.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 08:20:00', '2026-03-18 13:21:04', 5, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-04', 0);
INSERT INTO `order_info` VALUES (255, 'DC202503010112', 6, 2, NULL, 1, 45.00, 'ACCEPTED', 'PAID', '2026-03-01 09:30:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 09:00:00', '2026-03-18 13:21:04', 6, 'IN_STORE', 2, 'SERVICE', '2026-03-04', 0);
INSERT INTO `order_info` VALUES (256, 'DC202503020113', 7, 3, NULL, 2, 136.00, 'WASHING', 'PAID', '2026-03-02 10:15:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-02 10:00:00', '2026-03-18 13:21:04', 7, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-05', 0);
INSERT INTO `order_info` VALUES (257, 'DC202503020114', 8, 5, NULL, 4, 60.00, 'COMPLETED', 'PAID', '2026-03-02 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-02 11:30:00', '2026-03-18 13:21:04', 8, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-05', 0);
INSERT INTO `order_info` VALUES (258, 'DC202503030115', 9, 8, NULL, 1, 18.00, 'COMPLETED', 'PAID', '2026-03-03 12:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-03 09:00:00', '2026-03-18 13:21:04', 9, 'IN_STORE', 1, 'SERVICE', '2026-03-06', 0);
INSERT INTO `order_info` VALUES (259, 'DC202503040116', 10, 1, NULL, 1, 35.00, 'AWAIT_PICKUP', 'PAID', '2026-03-04 10:05:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-04 09:50:00', '2026-03-18 13:39:13', 10, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-07', 0);
INSERT INTO `order_info` VALUES (260, 'DC202503050117', 3, 4, NULL, 1, 55.00, 'ACCEPTED', 'PAID', '2026-03-05 11:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-05 10:30:00', '2026-03-18 13:21:04', 2, 'IN_STORE', 3, 'SERVICE', '2026-03-08', 0);
INSERT INTO `order_info` VALUES (261, 'DC202503060118', 4, 6, NULL, 3, 36.00, 'WASHING', 'PAID', '2026-03-06 14:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-06 11:00:00', '2026-03-18 13:21:04', 4, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-09', 0);
INSERT INTO `order_info` VALUES (262, 'DC202503060119', 5, 9, NULL, 1, 88.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-06 13:00:00', '2026-03-18 13:21:04', 5, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-09', 0);
INSERT INTO `order_info` VALUES (263, 'DC202503060120', 6, 2, NULL, 2, 90.00, 'COMPLETED', 'PAID', '2026-03-06 18:00:00', NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-06 14:00:00', '2026-03-18 13:21:04', 6, 'IN_STORE', 2, 'SERVICE', '2026-03-09', 0);
INSERT INTO `order_info` VALUES (264, 'DC17729741659717D0C', 17, 3, NULL, 1, 68.00, 'AWAIT_PICKUP', 'PAID', '2026-03-08 20:49:38', NULL, NULL, NULL, NULL, NULL, '', '2026-03-08 20:49:26', '2026-03-18 13:39:13', 13, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-11', 0);
INSERT INTO `order_info` VALUES (265, 'DC1772976463692FE7B', 17, 3, NULL, 1, 68.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-08 21:27:44', '2026-03-18 13:21:04', 13, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-11', 0);
INSERT INTO `order_info` VALUES (266, 'DC17730485419353290', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:02', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (267, 'DC17730485419962805', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:02', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (268, 'DC1773048544321DE70', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:04', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (269, 'DC1773048544339FA11', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:04', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (270, 'DC1773048567478AE05', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:27', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (271, 'DC17730485674948F4C', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:27', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (272, 'DC17730485745727771', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:35', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (273, 'DC177304857459405FC', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 17:29:35', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (274, 'DC177305217647376B3', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 18:29:36', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (275, 'DC17730521765014938', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 18:29:37', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (276, 'DC1773052186315CF0A', 10, 14, NULL, 1, 25.00, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 18:29:46', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (277, 'DC1773052186337EF5C', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 18:29:46', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (278, 'DC1773070061957F9C8', 10, 14, NULL, 1, 25.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 23:27:42', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (279, 'DC1773070062044EE3A', 10, 2, NULL, 3, 135.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 23:27:42', '2026-03-18 13:21:04', 2, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (280, 'DC17730700620708F36', 10, NULL, 2, 3, 89.70, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 23:27:42', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', NULL, 'PRODUCT', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (281, 'DC17730700621010D1E', 10, NULL, 3, 1, 24.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 13:28:10', NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 23:27:42', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', NULL, 'PRODUCT', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (282, 'DC1773070593859E636', 28, NULL, 1, 2, 79.80, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-09 23:36:34', '2026-03-19 00:01:52', 14, 'DOOR_TO_DOOR', NULL, 'PRODUCT', '2026-03-12', 0);
INSERT INTO `order_info` VALUES (283, 'DC17731242539212EA5', 18, NULL, 2, 1, 29.90, 'COMPLETED', 'PAID', '2026-03-10 15:45:33', NULL, NULL, NULL, NULL, NULL, '', '2026-03-10 14:30:54', '2026-03-19 00:01:52', 15, 'DOOR_TO_DOOR', NULL, 'PRODUCT', '2026-03-13', 0);
INSERT INTO `order_info` VALUES (284, 'DC1773206573246200C', 10, NULL, 2, 1, 29.90, 'COMPLETED', 'PAID', '2026-03-11 13:23:20', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 13:22:53', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (285, 'DC1773206573398EE7D', 10, NULL, 1, 1, 39.90, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 13:22:53', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (286, 'DC1773209330423C221', 10, NULL, 2, 1, 29.90, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 14:08:50', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (287, 'DC17732093670007E0D', 10, NULL, 2, 1, 29.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 14:09:30', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 14:09:27', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (288, 'DC177320948484660B2', 10, NULL, 2, 1, 29.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 14:11:28', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 14:11:25', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (289, 'DC17732104980222B0C', 10, NULL, 2, 1, 29.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 14:28:21', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 14:28:18', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (290, 'DC17732263167513709', 10, NULL, 5, 1, 32.00, 'COMPLETED', 'PAID', '2026-03-11 18:52:24', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:51:57', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (291, 'DC17732263167976361', 10, NULL, 6, 1, 35.00, 'COMPLETED', 'PAID', '2026-03-11 18:52:17', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:51:57', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (292, 'DC1773226316814A869', 10, NULL, 7, 1, 33.80, 'COMPLETED', 'PAID', '2026-03-11 18:52:29', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:51:57', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (293, 'DC17732263168335D52', 10, NULL, 8, 1, 18.80, 'COMPLETED', 'PAID', '2026-03-11 18:52:00', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:51:57', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (294, 'DC177322673554115CA', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:58:56', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (295, 'DC1773226735576756E', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:58:56', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (296, 'DC1773226744156EC32', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:59:04', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (297, 'DC1773226744180B365', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 18:59:04', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (298, 'DC1773226812575D3B5', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:00:13', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (299, 'DC17732268126002E80', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:00:13', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (300, 'DC17732268176845469', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:00:18', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (301, 'DC1773226817703DC57', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:00:18', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (302, 'DC17732269142908423', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:01:54', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (303, 'DC177322691432230E0', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:01:54', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (304, 'DC1773226922794F84E', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:02:03', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (305, 'DC1773226922813273E', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:02:03', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (306, 'DC17732271062748C4A', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:05:06', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (307, 'DC177322710637625C3', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:05:06', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (308, 'DC1773227135695E455', 10, NULL, 3, 1, 24.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:05:36', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (309, 'DC1773227200848DBBC', 10, NULL, 3, 1, 24.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 19:06:43', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:06:41', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (310, 'DC17732272009333BA7', 10, NULL, 2, 1, 29.90, 'AWAIT_SHIP', 'PAID', '2026-03-11 19:06:43', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:06:41', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (311, 'DC17732272241252DC5', 10, NULL, 1, 1, 39.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:07:04', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (312, 'DC177322722414418D2', 10, NULL, 2, 1, 29.90, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:07:04', '2026-03-19 00:01:52', 2, 'DOOR_TO_DOOR', 2, 'PRODUCT', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (313, 'DC1773227265831002B', 10, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2026-03-11 19:09:36', NULL, NULL, NULL, NULL, NULL, '', '2026-03-11 19:07:46', '2026-03-19 00:03:26', 2, 'DOOR_TO_DOOR', 2, 'SERVICE', '2026-03-14', 0);
INSERT INTO `order_info` VALUES (314, 'DC17738093982604635', 11, 2, NULL, 1, 45.00, 'COMPLETED', 'PAID', '2026-03-18 12:50:02', NULL, NULL, NULL, NULL, NULL, '', '2026-03-18 12:49:58', '2026-03-18 13:50:22', 16, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-21', 0);
INSERT INTO `order_info` VALUES (315, 'DC17738111842173677', 11, 3, NULL, 1, 68.00, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-18 13:19:44', '2026-03-18 13:47:23', 16, 'DOOR_TO_DOOR', NULL, 'SERVICE', '2026-03-21', 0);
INSERT INTO `order_info` VALUES (316, 'DC17738128502839652', 11, 2, NULL, 1, 45.00, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-18 13:47:30', '2026-03-18 13:47:59', 16, 'DOOR_TO_DOOR', NULL, 'SERVICE', NULL, 0);
INSERT INTO `order_info` VALUES (317, 'DC17738128910911CE9', 11, 2, NULL, 2, 90.00, 'CANCELLED', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '', '2026-03-18 13:48:11', '2026-03-18 13:48:17', 16, 'DOOR_TO_DOOR', NULL, 'SERVICE', NULL, 0);
INSERT INTO `order_info` VALUES (318, 'OD20260318192815443', 1, 1, NULL, 2, 136.00, 'PENDING', 'UNPAID', NULL, NULL, NULL, NULL, NULL, NULL, '示例订单：短款*2', '2026-03-18 19:28:15', '2026-03-18 19:28:15', 1, 'DOOR_TO_DOOR', 1, 'SERVICE', '2026-03-23', 0);
INSERT INTO `order_info` VALUES (319, 'OD20260318192815904', 1, 1, NULL, 1, 108.00, 'AWAIT_PICKUP', 'PAID', '2026-03-18 19:28:15', NULL, NULL, NULL, NULL, NULL, '示例订单：长款*1（已支付）', '2026-03-18 19:28:15', '2026-03-18 19:28:15', 1, 'IN_STORE', 1, 'SERVICE', '2026-03-21', 1);
INSERT INTO `order_info` VALUES (320, 'DC1773850380831E5F1', 10, 2, NULL, 1, 69.00, 'READY_PICKUP', 'PAID', '2026-03-19 00:13:05', NULL, NULL, NULL, NULL, NULL, '[规格:短款] ', '2026-03-19 00:13:01', '2026-03-19 00:13:35', NULL, 'IN_STORE', 2, 'SERVICE', '2026-03-24', 1);

-- ----------------------------
-- Table structure for paper
-- ----------------------------
DROP TABLE IF EXISTS `paper`;
CREATE TABLE `paper`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '年份，如 2025',
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地区，如 国考/北京/江苏',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分类：行测/申论',
  `name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '套卷名称',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注或来源文件名',
  `question_count` int NULL DEFAULT NULL COMMENT '题目数量',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_paper_create_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_paper_year_category`(`year` ASC, `category` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '套卷/试卷表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of paper
-- ----------------------------

-- ----------------------------
-- Table structure for payment_record
-- ----------------------------
DROP TABLE IF EXISTS `payment_record`;
CREATE TABLE `payment_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `order_ids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_id` bigint NOT NULL,
  `amount` decimal(10, 2) NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `pay_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'SIMULATE',
  `created_at` datetime NULL DEFAULT NULL,
  `paid_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 275 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment_record
-- ----------------------------
INSERT INTO `payment_record` VALUES (1, 242, NULL, 10, 90.00, 'PAID', 'SIMULATE', '2026-03-07 18:46:19', '2026-03-07 18:46:23');
INSERT INTO `payment_record` VALUES (2, 243, NULL, 10, 45.00, 'PAID', 'ALIPAY', '2026-03-07 18:46:37', '2026-03-09 17:30:02');
INSERT INTO `payment_record` VALUES (3, 1, NULL, 2, 35.00, 'PAID', 'ALIPAY', '2025-01-01 10:00:00', '2025-01-01 11:00:00');
INSERT INTO `payment_record` VALUES (4, 2, NULL, 2, 45.00, 'PAID', 'ALIPAY', '2025-01-01 10:30:00', '2025-01-01 12:00:00');
INSERT INTO `payment_record` VALUES (5, 3, NULL, 2, 30.00, 'PAID', 'ALIPAY', '2025-01-01 11:00:00', '2025-01-01 14:00:00');
INSERT INTO `payment_record` VALUES (6, 4, NULL, 2, 25.00, 'PAID', 'ALIPAY', '2025-01-02 08:00:00', '2025-01-02 09:00:00');
INSERT INTO `payment_record` VALUES (7, 6, NULL, 2, 60.00, 'PAID', 'ALIPAY', '2025-01-03 09:00:00', '2025-01-03 16:00:00');
INSERT INTO `payment_record` VALUES (8, 8, NULL, 2, 68.00, 'PAID', 'ALIPAY', '2025-01-05 10:00:00', '2025-01-05 11:00:00');
INSERT INTO `payment_record` VALUES (9, 9, NULL, 2, 80.00, 'PAID', 'ALIPAY', '2025-01-06 09:00:00', '2025-01-06 10:00:00');
INSERT INTO `payment_record` VALUES (10, 10, NULL, 2, 56.00, 'PAID', 'ALIPAY', '2025-01-07 11:00:00', '2025-01-07 15:00:00');
INSERT INTO `payment_record` VALUES (11, 11, NULL, 3, 55.00, 'PAID', 'ALIPAY', '2025-01-01 10:15:00', '2025-01-01 12:00:00');
INSERT INTO `payment_record` VALUES (12, 12, NULL, 3, 36.00, 'PAID', 'ALIPAY', '2025-01-01 10:45:00', '2025-01-01 13:00:00');
INSERT INTO `payment_record` VALUES (13, 13, NULL, 3, 25.00, 'PAID', 'ALIPAY', '2025-01-02 09:00:00', '2025-01-02 10:00:00');
INSERT INTO `payment_record` VALUES (14, 15, NULL, 3, 36.00, 'PAID', 'ALIPAY', '2025-01-04 10:00:00', '2025-01-04 14:00:00');
INSERT INTO `payment_record` VALUES (15, 16, NULL, 3, 42.00, 'PAID', 'ALIPAY', '2025-01-05 11:00:00', '2025-01-05 16:00:00');
INSERT INTO `payment_record` VALUES (16, 18, NULL, 3, 70.00, 'PAID', 'ALIPAY', '2025-01-07 09:00:00', '2025-01-07 11:00:00');
INSERT INTO `payment_record` VALUES (17, 19, NULL, 3, 55.00, 'PAID', 'ALIPAY', '2025-01-08 08:00:00', '2025-01-08 10:00:00');
INSERT INTO `payment_record` VALUES (18, 20, NULL, 3, 48.00, 'PAID', 'ALIPAY', '2025-01-09 10:00:00', '2025-01-09 15:00:00');
INSERT INTO `payment_record` VALUES (19, 21, NULL, 4, 68.00, 'PAID', 'ALIPAY', '2025-01-01 11:00:00', '2025-01-01 14:00:00');
INSERT INTO `payment_record` VALUES (20, 22, NULL, 4, 88.00, 'PAID', 'ALIPAY', '2025-01-02 10:00:00', '2025-01-02 16:00:00');
INSERT INTO `payment_record` VALUES (21, 23, NULL, 4, 35.00, 'PAID', 'ALIPAY', '2025-01-03 08:00:00', '2025-01-03 09:00:00');
INSERT INTO `payment_record` VALUES (22, 25, NULL, 4, 45.00, 'PAID', 'ALIPAY', '2025-01-05 09:00:00', '2025-01-05 12:00:00');
INSERT INTO `payment_record` VALUES (23, 26, NULL, 4, 36.00, 'PAID', 'ALIPAY', '2025-01-06 10:00:00', '2025-01-06 15:00:00');
INSERT INTO `payment_record` VALUES (24, 28, NULL, 4, 90.00, 'PAID', 'ALIPAY', '2025-01-08 09:00:00', '2025-01-08 11:00:00');
INSERT INTO `payment_record` VALUES (25, 29, NULL, 4, 20.00, 'PAID', 'ALIPAY', '2025-01-09 08:00:00', '2025-01-09 10:00:00');
INSERT INTO `payment_record` VALUES (26, 30, NULL, 4, 80.00, 'PAID', 'ALIPAY', '2025-01-10 11:00:00', '2025-01-10 17:00:00');
INSERT INTO `payment_record` VALUES (27, 31, NULL, 5, 24.00, 'PAID', 'ALIPAY', '2025-01-01 12:00:00', '2025-01-01 15:00:00');
INSERT INTO `payment_record` VALUES (28, 32, NULL, 5, 22.00, 'PAID', 'ALIPAY', '2025-01-02 10:00:00', '2025-01-02 11:00:00');
INSERT INTO `payment_record` VALUES (29, 33, NULL, 5, 20.00, 'PAID', 'ALIPAY', '2025-01-03 09:00:00', '2025-01-03 11:00:00');
INSERT INTO `payment_record` VALUES (30, 35, NULL, 5, 22.00, 'PAID', 'ALIPAY', '2025-01-05 10:00:00', '2025-01-05 13:00:00');
INSERT INTO `payment_record` VALUES (31, 36, NULL, 5, 38.00, 'PAID', 'ALIPAY', '2025-01-06 11:00:00', '2025-01-06 16:00:00');
INSERT INTO `payment_record` VALUES (32, 38, NULL, 5, 55.00, 'PAID', 'ALIPAY', '2025-01-08 09:00:00', '2025-01-08 12:00:00');
INSERT INTO `payment_record` VALUES (33, 39, NULL, 5, 30.00, 'PAID', 'ALIPAY', '2025-01-09 08:00:00', '2025-01-09 11:00:00');
INSERT INTO `payment_record` VALUES (34, 40, NULL, 5, 12.00, 'PAID', 'ALIPAY', '2025-01-10 10:00:00', '2025-01-10 14:00:00');
INSERT INTO `payment_record` VALUES (35, 41, NULL, 6, 35.00, 'PAID', 'ALIPAY', '2025-01-01 13:00:00', '2025-01-01 16:00:00');
INSERT INTO `payment_record` VALUES (36, 42, NULL, 6, 56.00, 'PAID', 'ALIPAY', '2025-01-02 11:00:00', '2025-01-02 14:00:00');
INSERT INTO `payment_record` VALUES (37, 43, NULL, 6, 35.00, 'PAID', 'ALIPAY', '2025-01-03 10:00:00', '2025-01-03 12:00:00');
INSERT INTO `payment_record` VALUES (38, 45, NULL, 6, 50.00, 'PAID', 'ALIPAY', '2025-01-05 12:00:00', '2025-01-05 15:00:00');
INSERT INTO `payment_record` VALUES (39, 46, NULL, 6, 55.00, 'PAID', 'ALIPAY', '2025-01-06 13:00:00', '2025-01-06 17:00:00');
INSERT INTO `payment_record` VALUES (40, 48, NULL, 6, 42.00, 'PAID', 'ALIPAY', '2025-01-08 10:00:00', '2025-01-08 14:00:00');
INSERT INTO `payment_record` VALUES (41, 49, NULL, 6, 60.00, 'PAID', 'ALIPAY', '2025-01-09 09:00:00', '2025-01-09 12:00:00');
INSERT INTO `payment_record` VALUES (42, 50, NULL, 6, 60.00, 'PAID', 'ALIPAY', '2025-01-10 14:00:00', '2025-01-10 18:00:00');
INSERT INTO `payment_record` VALUES (43, 51, NULL, 7, 68.00, 'PAID', 'ALIPAY', '2025-01-01 14:00:00', '2025-01-01 17:00:00');
INSERT INTO `payment_record` VALUES (44, 52, NULL, 7, 48.00, 'PAID', 'ALIPAY', '2025-01-02 12:00:00', '2025-01-02 15:00:00');
INSERT INTO `payment_record` VALUES (45, 53, NULL, 7, 35.00, 'PAID', 'ALIPAY', '2025-01-03 11:00:00', '2025-01-03 13:00:00');
INSERT INTO `payment_record` VALUES (46, 55, NULL, 7, 18.00, 'PAID', 'ALIPAY', '2025-01-05 13:00:00', '2025-01-05 16:00:00');
INSERT INTO `payment_record` VALUES (47, 56, NULL, 7, 45.00, 'PAID', 'ALIPAY', '2025-01-06 14:00:00', '2025-01-06 18:00:00');
INSERT INTO `payment_record` VALUES (48, 58, NULL, 7, 40.00, 'PAID', 'ALIPAY', '2025-01-08 11:00:00', '2025-01-08 15:00:00');
INSERT INTO `payment_record` VALUES (49, 59, NULL, 7, 80.00, 'PAID', 'ALIPAY', '2025-01-09 10:00:00', '2025-01-09 13:00:00');
INSERT INTO `payment_record` VALUES (50, 60, NULL, 7, 28.00, 'PAID', 'ALIPAY', '2025-01-10 15:00:00', '2025-01-10 19:00:00');
INSERT INTO `payment_record` VALUES (51, 61, NULL, 8, 55.00, 'PAID', 'ALIPAY', '2025-01-01 15:00:00', '2025-01-01 18:00:00');
INSERT INTO `payment_record` VALUES (52, 62, NULL, 8, 44.00, 'PAID', 'ALIPAY', '2025-01-02 13:00:00', '2025-01-02 16:00:00');
INSERT INTO `payment_record` VALUES (53, 63, NULL, 8, 20.00, 'PAID', 'ALIPAY', '2025-01-03 12:00:00', '2025-01-03 14:00:00');
INSERT INTO `payment_record` VALUES (54, 65, NULL, 8, 24.00, 'PAID', 'ALIPAY', '2025-01-05 14:00:00', '2025-01-05 17:00:00');
INSERT INTO `payment_record` VALUES (55, 66, NULL, 8, 60.00, 'PAID', 'ALIPAY', '2025-01-06 15:00:00', '2025-01-06 19:00:00');
INSERT INTO `payment_record` VALUES (56, 68, NULL, 8, 25.00, 'PAID', 'ALIPAY', '2025-01-08 12:00:00', '2025-01-08 16:00:00');
INSERT INTO `payment_record` VALUES (57, 69, NULL, 8, 70.00, 'PAID', 'ALIPAY', '2025-01-09 11:00:00', '2025-01-09 14:00:00');
INSERT INTO `payment_record` VALUES (58, 70, NULL, 8, 28.00, 'PAID', 'ALIPAY', '2025-01-10 16:00:00', '2025-01-10 20:00:00');
INSERT INTO `payment_record` VALUES (59, 71, NULL, 9, 45.00, 'PAID', 'ALIPAY', '2025-01-01 16:00:00', '2025-01-01 19:00:00');
INSERT INTO `payment_record` VALUES (60, 72, NULL, 9, 42.00, 'PAID', 'ALIPAY', '2025-01-02 14:00:00', '2025-01-02 17:00:00');
INSERT INTO `payment_record` VALUES (61, 73, NULL, 9, 25.00, 'PAID', 'ALIPAY', '2025-01-03 13:00:00', '2025-01-03 15:00:00');
INSERT INTO `payment_record` VALUES (62, 75, NULL, 9, 55.00, 'PAID', 'ALIPAY', '2025-01-05 15:00:00', '2025-01-05 18:00:00');
INSERT INTO `payment_record` VALUES (63, 76, NULL, 9, 18.00, 'PAID', 'ALIPAY', '2025-01-06 16:00:00', '2025-01-06 20:00:00');
INSERT INTO `payment_record` VALUES (64, 78, NULL, 9, 68.00, 'PAID', 'ALIPAY', '2025-01-08 13:00:00', '2025-01-08 17:00:00');
INSERT INTO `payment_record` VALUES (65, 79, NULL, 9, 56.00, 'PAID', 'ALIPAY', '2025-01-09 12:00:00', '2025-01-09 15:00:00');
INSERT INTO `payment_record` VALUES (66, 80, NULL, 9, 80.00, 'PAID', 'ALIPAY', '2025-01-10 17:00:00', '2025-01-10 21:00:00');
INSERT INTO `payment_record` VALUES (67, 81, NULL, 10, 38.00, 'PAID', 'ALIPAY', '2025-01-01 17:00:00', '2025-01-01 20:00:00');
INSERT INTO `payment_record` VALUES (68, 82, NULL, 10, 20.00, 'PAID', 'ALIPAY', '2025-01-02 15:00:00', '2025-01-02 18:00:00');
INSERT INTO `payment_record` VALUES (69, 83, NULL, 10, 35.00, 'PAID', 'ALIPAY', '2025-01-03 14:00:00', '2025-01-03 16:00:00');
INSERT INTO `payment_record` VALUES (70, 85, NULL, 10, 48.00, 'PAID', 'ALIPAY', '2025-01-05 16:00:00', '2025-01-05 19:00:00');
INSERT INTO `payment_record` VALUES (71, 86, NULL, 10, 45.00, 'PAID', 'ALIPAY', '2025-01-06 17:00:00', '2025-01-06 21:00:00');
INSERT INTO `payment_record` VALUES (72, 88, NULL, 10, 55.00, 'PAID', 'ALIPAY', '2025-01-08 14:00:00', '2025-01-08 18:00:00');
INSERT INTO `payment_record` VALUES (73, 89, NULL, 10, 36.00, 'PAID', 'ALIPAY', '2025-01-09 13:00:00', '2025-01-09 16:00:00');
INSERT INTO `payment_record` VALUES (74, 90, NULL, 10, 24.00, 'PAID', 'ALIPAY', '2025-01-10 18:00:00', '2025-01-10 22:00:00');
INSERT INTO `payment_record` VALUES (75, 91, NULL, 11, 45.00, 'PAID', 'ALIPAY', '2025-01-01 18:00:00', '2025-01-01 21:00:00');
INSERT INTO `payment_record` VALUES (76, 92, NULL, 11, 28.00, 'PAID', 'ALIPAY', '2025-01-02 16:00:00', '2025-01-02 19:00:00');
INSERT INTO `payment_record` VALUES (77, 93, NULL, 11, 35.00, 'PAID', 'ALIPAY', '2025-01-03 15:00:00', '2025-01-03 17:00:00');
INSERT INTO `payment_record` VALUES (78, 95, NULL, 11, 35.00, 'PAID', 'ALIPAY', '2025-01-05 17:00:00', '2025-01-05 20:00:00');
INSERT INTO `payment_record` VALUES (79, 96, NULL, 11, 55.00, 'PAID', 'ALIPAY', '2025-01-06 18:00:00', '2025-01-06 22:00:00');
INSERT INTO `payment_record` VALUES (80, 98, NULL, 11, 50.00, 'PAID', 'ALIPAY', '2025-01-08 15:00:00', '2025-01-08 19:00:00');
INSERT INTO `payment_record` VALUES (81, 99, NULL, 11, 42.00, 'PAID', 'ALIPAY', '2025-01-09 14:00:00', '2025-01-09 17:00:00');
INSERT INTO `payment_record` VALUES (82, 100, NULL, 11, 36.00, 'PAID', 'ALIPAY', '2025-01-10 19:00:00', '2025-01-10 23:00:00');
INSERT INTO `payment_record` VALUES (83, 101, NULL, 12, 68.00, 'PAID', 'ALIPAY', '2025-01-02 09:00:00', '2025-01-02 10:00:00');
INSERT INTO `payment_record` VALUES (84, 102, NULL, 12, 36.00, 'PAID', 'ALIPAY', '2025-01-02 09:30:00', '2025-01-02 11:00:00');
INSERT INTO `payment_record` VALUES (85, 103, NULL, 12, 25.00, 'PAID', 'ALIPAY', '2025-01-02 10:00:00', '2025-01-02 12:00:00');
INSERT INTO `payment_record` VALUES (86, 105, NULL, 12, 28.00, 'PAID', 'ALIPAY', '2025-01-03 12:00:00', '2025-01-03 14:00:00');
INSERT INTO `payment_record` VALUES (87, 106, NULL, 12, 20.00, 'PAID', 'ALIPAY', '2025-01-04 13:00:00', '2025-01-04 15:00:00');
INSERT INTO `payment_record` VALUES (88, 108, NULL, 12, 88.00, 'PAID', 'ALIPAY', '2025-01-06 14:00:00', '2025-01-06 16:00:00');
INSERT INTO `payment_record` VALUES (89, 109, NULL, 12, 60.00, 'PAID', 'ALIPAY', '2025-01-07 13:00:00', '2025-01-07 15:00:00');
INSERT INTO `payment_record` VALUES (90, 110, NULL, 12, 38.00, 'PAID', 'ALIPAY', '2025-01-08 15:00:00', '2025-01-08 17:00:00');
INSERT INTO `payment_record` VALUES (91, 111, NULL, 13, 55.00, 'PAID', 'ALIPAY', '2025-01-02 10:30:00', '2025-01-02 12:00:00');
INSERT INTO `payment_record` VALUES (92, 112, NULL, 13, 40.00, 'PAID', 'ALIPAY', '2025-01-02 11:00:00', '2025-01-02 13:00:00');
INSERT INTO `payment_record` VALUES (93, 113, NULL, 13, 18.00, 'PAID', 'ALIPAY', '2025-01-03 10:00:00', '2025-01-03 12:00:00');
INSERT INTO `payment_record` VALUES (94, 115, NULL, 13, 28.00, 'PAID', 'ALIPAY', '2025-01-05 13:00:00', '2025-01-05 15:00:00');
INSERT INTO `payment_record` VALUES (95, 116, NULL, 13, 35.00, 'PAID', 'ALIPAY', '2025-01-06 15:00:00', '2025-01-06 17:00:00');
INSERT INTO `payment_record` VALUES (96, 118, NULL, 13, 48.00, 'PAID', 'ALIPAY', '2025-01-08 16:00:00', '2025-01-08 18:00:00');
INSERT INTO `payment_record` VALUES (97, 119, NULL, 13, 55.00, 'PAID', 'ALIPAY', '2025-01-09 12:00:00', '2025-01-09 14:00:00');
INSERT INTO `payment_record` VALUES (98, 120, NULL, 13, 30.00, 'PAID', 'ALIPAY', '2025-01-09 16:00:00', '2025-01-09 19:00:00');
INSERT INTO `payment_record` VALUES (99, 121, NULL, 14, 12.00, 'PAID', 'ALIPAY', '2025-01-02 12:30:00', '2025-01-02 14:00:00');
INSERT INTO `payment_record` VALUES (100, 122, NULL, 14, 22.00, 'PAID', 'ALIPAY', '2025-01-02 13:00:00', '2025-01-02 15:00:00');
INSERT INTO `payment_record` VALUES (101, 123, NULL, 14, 42.00, 'PAID', 'ALIPAY', '2025-01-03 11:00:00', '2025-01-03 13:00:00');
INSERT INTO `payment_record` VALUES (102, 125, NULL, 14, 45.00, 'PAID', 'ALIPAY', '2025-01-05 14:00:00', '2025-01-05 16:00:00');
INSERT INTO `payment_record` VALUES (103, 126, NULL, 14, 45.00, 'PAID', 'ALIPAY', '2025-01-06 16:00:00', '2025-01-06 18:00:00');
INSERT INTO `payment_record` VALUES (104, 128, NULL, 14, 35.00, 'PAID', 'ALIPAY', '2025-01-08 17:00:00', '2025-01-08 19:00:00');
INSERT INTO `payment_record` VALUES (105, 129, NULL, 14, 24.00, 'PAID', 'ALIPAY', '2025-01-09 13:00:00', '2025-01-09 15:00:00');
INSERT INTO `payment_record` VALUES (106, 130, NULL, 14, 18.00, 'PAID', 'ALIPAY', '2025-01-10 18:00:00', '2025-01-10 20:00:00');
INSERT INTO `payment_record` VALUES (107, 131, NULL, 15, 38.00, 'PAID', 'ALIPAY', '2025-01-02 14:30:00', '2025-01-02 16:00:00');
INSERT INTO `payment_record` VALUES (108, 132, NULL, 15, 56.00, 'PAID', 'ALIPAY', '2025-01-02 15:00:00', '2025-01-02 17:00:00');
INSERT INTO `payment_record` VALUES (109, 133, NULL, 15, 60.00, 'PAID', 'ALIPAY', '2025-01-03 12:00:00', '2025-01-03 14:00:00');
INSERT INTO `payment_record` VALUES (110, 135, NULL, 15, 55.00, 'PAID', 'ALIPAY', '2025-01-05 15:00:00', '2025-01-05 17:00:00');
INSERT INTO `payment_record` VALUES (111, 136, NULL, 15, 80.00, 'PAID', 'ALIPAY', '2025-01-06 17:00:00', '2025-01-06 19:00:00');
INSERT INTO `payment_record` VALUES (112, 138, NULL, 15, 20.00, 'PAID', 'ALIPAY', '2025-01-08 18:00:00', '2025-01-08 20:00:00');
INSERT INTO `payment_record` VALUES (113, 139, NULL, 15, 22.00, 'PAID', 'ALIPAY', '2025-01-09 14:00:00', '2025-01-09 16:00:00');
INSERT INTO `payment_record` VALUES (114, 140, NULL, 15, 20.00, 'PAID', 'ALIPAY', '2025-01-10 19:00:00', '2025-01-10 21:00:00');
INSERT INTO `payment_record` VALUES (115, 141, NULL, 16, 35.00, 'PAID', 'ALIPAY', '2025-01-02 16:30:00', '2025-01-02 18:00:00');
INSERT INTO `payment_record` VALUES (116, 142, NULL, 16, 48.00, 'PAID', 'ALIPAY', '2025-01-02 17:00:00', '2025-01-02 19:00:00');
INSERT INTO `payment_record` VALUES (117, 143, NULL, 16, 35.00, 'PAID', 'ALIPAY', '2025-01-03 13:00:00', '2025-01-03 15:00:00');
INSERT INTO `payment_record` VALUES (118, 145, NULL, 16, 18.00, 'PAID', 'ALIPAY', '2025-01-05 16:00:00', '2025-01-05 18:00:00');
INSERT INTO `payment_record` VALUES (119, 146, NULL, 16, 55.00, 'PAID', 'ALIPAY', '2025-01-06 18:00:00', '2025-01-06 20:00:00');
INSERT INTO `payment_record` VALUES (120, 148, NULL, 16, 28.00, 'PAID', 'ALIPAY', '2025-01-08 19:00:00', '2025-01-08 21:00:00');
INSERT INTO `payment_record` VALUES (121, 149, NULL, 16, 25.00, 'PAID', 'ALIPAY', '2025-01-09 15:00:00', '2025-01-09 17:00:00');
INSERT INTO `payment_record` VALUES (122, 150, NULL, 16, 24.00, 'PAID', 'ALIPAY', '2025-01-10 20:00:00', '2025-01-10 22:00:00');
INSERT INTO `payment_record` VALUES (123, 151, NULL, 17, 68.00, 'PAID', 'ALIPAY', '2025-01-03 09:00:00', '2025-01-03 10:00:00');
INSERT INTO `payment_record` VALUES (124, 152, NULL, 17, 18.00, 'PAID', 'ALIPAY', '2025-01-03 09:30:00', '2025-01-03 11:00:00');
INSERT INTO `payment_record` VALUES (125, 153, NULL, 17, 50.00, 'PAID', 'ALIPAY', '2025-01-03 10:00:00', '2025-01-03 12:00:00');
INSERT INTO `payment_record` VALUES (126, 155, NULL, 17, 42.00, 'PAID', 'ALIPAY', '2025-01-04 12:00:00', '2025-01-04 14:00:00');
INSERT INTO `payment_record` VALUES (127, 156, NULL, 17, 22.00, 'PAID', 'ALIPAY', '2025-01-05 11:00:00', '2025-01-05 13:00:00');
INSERT INTO `payment_record` VALUES (128, 158, NULL, 17, 60.00, 'PAID', 'ALIPAY', '2025-01-06 14:00:00', '2025-01-06 16:00:00');
INSERT INTO `payment_record` VALUES (129, 159, NULL, 17, 38.00, 'PAID', 'ALIPAY', '2025-01-07 13:00:00', '2025-01-07 15:00:00');
INSERT INTO `payment_record` VALUES (130, 160, NULL, 17, 45.00, 'PAID', 'ALIPAY', '2025-01-08 15:00:00', '2025-01-08 17:00:00');
INSERT INTO `payment_record` VALUES (131, 161, NULL, 18, 55.00, 'PAID', 'ALIPAY', '2025-01-03 11:00:00', '2025-01-03 12:00:00');
INSERT INTO `payment_record` VALUES (132, 162, NULL, 18, 20.00, 'PAID', 'ALIPAY', '2025-01-03 11:30:00', '2025-01-03 13:00:00');
INSERT INTO `payment_record` VALUES (133, 163, NULL, 18, 35.00, 'PAID', 'ALIPAY', '2025-01-03 12:00:00', '2025-01-03 14:00:00');
INSERT INTO `payment_record` VALUES (134, 165, NULL, 18, 15.00, 'PAID', 'ALIPAY', '2025-01-04 14:00:00', '2025-01-04 16:00:00');
INSERT INTO `payment_record` VALUES (135, 166, NULL, 18, 35.00, 'PAID', 'ALIPAY', '2025-01-05 13:00:00', '2025-01-05 15:00:00');
INSERT INTO `payment_record` VALUES (136, 168, NULL, 18, 28.00, 'PAID', 'ALIPAY', '2025-01-06 16:00:00', '2025-01-06 18:00:00');
INSERT INTO `payment_record` VALUES (137, 169, NULL, 18, 12.00, 'PAID', 'ALIPAY', '2025-01-07 15:00:00', '2025-01-07 17:00:00');
INSERT INTO `payment_record` VALUES (138, 170, NULL, 18, 56.00, 'PAID', 'ALIPAY', '2025-01-08 17:00:00', '2025-01-08 19:00:00');
INSERT INTO `payment_record` VALUES (139, 171, NULL, 19, 12.00, 'PAID', 'ALIPAY', '2025-01-03 13:00:00', '2025-01-03 14:00:00');
INSERT INTO `payment_record` VALUES (140, 172, NULL, 19, 48.00, 'PAID', 'ALIPAY', '2025-01-03 13:30:00', '2025-01-03 15:00:00');
INSERT INTO `payment_record` VALUES (141, 173, NULL, 19, 20.00, 'PAID', 'ALIPAY', '2025-01-03 14:00:00', '2025-01-03 16:00:00');
INSERT INTO `payment_record` VALUES (142, 175, NULL, 19, 45.00, 'PAID', 'ALIPAY', '2025-01-04 16:00:00', '2025-01-04 18:00:00');
INSERT INTO `payment_record` VALUES (143, 176, NULL, 19, 55.00, 'PAID', 'ALIPAY', '2025-01-05 15:00:00', '2025-01-05 17:00:00');
INSERT INTO `payment_record` VALUES (144, 178, NULL, 19, 18.00, 'PAID', 'ALIPAY', '2025-01-06 18:00:00', '2025-01-06 20:00:00');
INSERT INTO `payment_record` VALUES (145, 179, NULL, 19, 60.00, 'PAID', 'ALIPAY', '2025-01-07 17:00:00', '2025-01-07 19:00:00');
INSERT INTO `payment_record` VALUES (146, 180, NULL, 19, 36.00, 'PAID', 'ALIPAY', '2025-01-08 19:00:00', '2025-01-08 21:00:00');
INSERT INTO `payment_record` VALUES (147, 181, NULL, 20, 38.00, 'PAID', 'ALIPAY', '2025-01-03 15:00:00', '2025-01-03 16:00:00');
INSERT INTO `payment_record` VALUES (148, 182, NULL, 20, 44.00, 'PAID', 'ALIPAY', '2025-01-03 15:30:00', '2025-01-03 17:00:00');
INSERT INTO `payment_record` VALUES (149, 183, NULL, 20, 42.00, 'PAID', 'ALIPAY', '2025-01-03 16:00:00', '2025-01-03 18:00:00');
INSERT INTO `payment_record` VALUES (150, 185, NULL, 20, 55.00, 'PAID', 'ALIPAY', '2025-01-04 18:00:00', '2025-01-04 20:00:00');
INSERT INTO `payment_record` VALUES (151, 186, NULL, 20, 80.00, 'PAID', 'ALIPAY', '2025-01-05 17:00:00', '2025-01-05 19:00:00');
INSERT INTO `payment_record` VALUES (152, 188, NULL, 20, 35.00, 'PAID', 'ALIPAY', '2025-01-06 20:00:00', '2025-01-06 22:00:00');
INSERT INTO `payment_record` VALUES (153, 189, NULL, 20, 88.00, 'PAID', 'ALIPAY', '2025-01-07 19:00:00', '2025-01-07 21:00:00');
INSERT INTO `payment_record` VALUES (154, 190, NULL, 20, 20.00, 'PAID', 'ALIPAY', '2025-01-08 21:00:00', '2025-01-08 23:00:00');
INSERT INTO `payment_record` VALUES (155, 191, NULL, 21, 70.00, 'PAID', 'ALIPAY', '2025-01-03 17:00:00', '2025-01-03 18:00:00');
INSERT INTO `payment_record` VALUES (156, 192, NULL, 21, 28.00, 'PAID', 'ALIPAY', '2025-01-03 17:30:00', '2025-01-03 19:00:00');
INSERT INTO `payment_record` VALUES (157, 193, NULL, 21, 45.00, 'PAID', 'ALIPAY', '2025-01-03 18:00:00', '2025-01-03 20:00:00');
INSERT INTO `payment_record` VALUES (158, 195, NULL, 21, 35.00, 'PAID', 'ALIPAY', '2025-01-04 20:00:00', '2025-01-04 22:00:00');
INSERT INTO `payment_record` VALUES (159, 196, NULL, 21, 45.00, 'PAID', 'ALIPAY', '2025-01-05 19:00:00', '2025-01-05 21:00:00');
INSERT INTO `payment_record` VALUES (160, 198, NULL, 21, 24.00, 'PAID', 'ALIPAY', '2025-01-06 22:00:00', '2025-01-06 00:00:00');
INSERT INTO `payment_record` VALUES (161, 199, NULL, 21, 18.00, 'PAID', 'ALIPAY', '2025-01-07 21:00:00', '2025-01-07 23:00:00');
INSERT INTO `payment_record` VALUES (162, 200, NULL, 21, 12.00, 'PAID', 'ALIPAY', '2025-01-08 23:00:00', '2025-01-08 01:00:00');
INSERT INTO `payment_record` VALUES (163, 201, NULL, 22, 68.00, 'PAID', 'ALIPAY', '2025-01-04 09:00:00', '2025-01-04 10:00:00');
INSERT INTO `payment_record` VALUES (164, 202, NULL, 22, 18.00, 'PAID', 'ALIPAY', '2025-01-04 09:30:00', '2025-01-04 11:00:00');
INSERT INTO `payment_record` VALUES (165, 203, NULL, 22, 56.00, 'PAID', 'ALIPAY', '2025-01-04 10:00:00', '2025-01-04 12:00:00');
INSERT INTO `payment_record` VALUES (166, 205, NULL, 22, 38.00, 'PAID', 'ALIPAY', '2025-01-05 12:00:00', '2025-01-05 14:00:00');
INSERT INTO `payment_record` VALUES (167, 206, NULL, 22, 48.00, 'PAID', 'ALIPAY', '2025-01-06 13:00:00', '2025-01-06 15:00:00');
INSERT INTO `payment_record` VALUES (168, 208, NULL, 22, 55.00, 'PAID', 'ALIPAY', '2025-01-07 16:00:00', '2025-01-07 18:00:00');
INSERT INTO `payment_record` VALUES (169, 209, NULL, 22, 80.00, 'PAID', 'ALIPAY', '2025-01-08 15:00:00', '2025-01-08 17:00:00');
INSERT INTO `payment_record` VALUES (170, 210, NULL, 22, 22.00, 'PAID', 'ALIPAY', '2025-01-09 17:00:00', '2025-01-09 19:00:00');
INSERT INTO `payment_record` VALUES (171, 211, NULL, 23, 15.00, 'PAID', 'ALIPAY', '2025-01-04 11:00:00', '2025-01-04 12:00:00');
INSERT INTO `payment_record` VALUES (172, 212, NULL, 23, 40.00, 'PAID', 'ALIPAY', '2025-01-04 11:30:00', '2025-01-04 13:00:00');
INSERT INTO `payment_record` VALUES (173, 213, NULL, 23, 20.00, 'PAID', 'ALIPAY', '2025-01-04 12:00:00', '2025-01-04 14:00:00');
INSERT INTO `payment_record` VALUES (174, 215, NULL, 23, 90.00, 'PAID', 'ALIPAY', '2025-01-05 14:00:00', '2025-01-05 16:00:00');
INSERT INTO `payment_record` VALUES (175, 216, NULL, 23, 42.00, 'PAID', 'ALIPAY', '2025-01-06 15:00:00', '2025-01-06 17:00:00');
INSERT INTO `payment_record` VALUES (176, 218, NULL, 23, 50.00, 'PAID', 'ALIPAY', '2025-01-07 18:00:00', '2025-01-07 20:00:00');
INSERT INTO `payment_record` VALUES (177, 219, NULL, 23, 35.00, 'PAID', 'ALIPAY', '2025-01-08 17:00:00', '2025-01-08 19:00:00');
INSERT INTO `payment_record` VALUES (178, 220, NULL, 23, 36.00, 'PAID', 'ALIPAY', '2025-01-09 19:00:00', '2025-01-09 21:00:00');
INSERT INTO `payment_record` VALUES (179, 221, NULL, 24, 38.00, 'PAID', 'ALIPAY', '2025-01-04 13:00:00', '2025-01-04 14:00:00');
INSERT INTO `payment_record` VALUES (180, 222, NULL, 24, 35.00, 'PAID', 'ALIPAY', '2025-01-04 13:30:00', '2025-01-04 15:00:00');
INSERT INTO `payment_record` VALUES (181, 223, NULL, 24, 60.00, 'PAID', 'ALIPAY', '2025-01-04 14:00:00', '2025-01-04 16:00:00');
INSERT INTO `payment_record` VALUES (182, 225, NULL, 24, 68.00, 'PAID', 'ALIPAY', '2025-01-05 16:00:00', '2025-01-05 18:00:00');
INSERT INTO `payment_record` VALUES (183, 226, NULL, 24, 55.00, 'PAID', 'ALIPAY', '2025-01-06 17:00:00', '2025-01-06 19:00:00');
INSERT INTO `payment_record` VALUES (184, 228, NULL, 24, 36.00, 'PAID', 'ALIPAY', '2025-01-07 20:00:00', '2025-01-07 22:00:00');
INSERT INTO `payment_record` VALUES (185, 229, NULL, 24, 25.00, 'PAID', 'ALIPAY', '2025-01-08 19:00:00', '2025-01-08 21:00:00');
INSERT INTO `payment_record` VALUES (186, 230, NULL, 24, 55.00, 'PAID', 'ALIPAY', '2025-01-09 21:00:00', '2025-01-09 23:00:00');
INSERT INTO `payment_record` VALUES (187, 231, NULL, 25, 48.00, 'PAID', 'ALIPAY', '2025-01-04 15:00:00', '2025-01-04 16:00:00');
INSERT INTO `payment_record` VALUES (188, 232, NULL, 25, 22.00, 'PAID', 'ALIPAY', '2025-01-04 15:30:00', '2025-01-04 17:00:00');
INSERT INTO `payment_record` VALUES (189, 233, NULL, 25, 80.00, 'PAID', 'ALIPAY', '2025-01-04 16:00:00', '2025-01-04 18:00:00');
INSERT INTO `payment_record` VALUES (190, 235, NULL, 25, 36.00, 'PAID', 'ALIPAY', '2025-01-05 18:00:00', '2025-01-05 20:00:00');
INSERT INTO `payment_record` VALUES (191, 236, NULL, 25, 42.00, 'PAID', 'ALIPAY', '2025-01-06 19:00:00', '2025-01-06 21:00:00');
INSERT INTO `payment_record` VALUES (192, 238, NULL, 25, 15.00, 'PAID', 'ALIPAY', '2025-01-07 23:00:00', '2025-01-07 00:00:00');
INSERT INTO `payment_record` VALUES (193, 239, NULL, 25, 24.00, 'PAID', 'ALIPAY', '2025-01-08 21:00:00', '2025-01-08 23:00:00');
INSERT INTO `payment_record` VALUES (194, 240, NULL, 25, 30.00, 'PAID', 'ALIPAY', '2025-01-09 23:00:00', '2025-01-09 01:00:00');
INSERT INTO `payment_record` VALUES (195, 241, NULL, 10, 45.00, 'PAID', 'ALIPAY', '2026-03-07 17:09:55', '2026-03-07 17:10:32');
INSERT INTO `payment_record` VALUES (196, 245, NULL, 4, 35.00, 'PAID', 'ALIPAY', '2026-02-01 09:30:00', '2026-02-01 10:20:00');
INSERT INTO `payment_record` VALUES (197, 246, NULL, 5, 68.00, 'PAID', 'ALIPAY', '2026-02-01 10:00:00', '2026-02-01 11:00:00');
INSERT INTO `payment_record` VALUES (198, 247, NULL, 6, 110.00, 'PAID', 'ALIPAY', '2026-02-02 11:00:00', '2026-02-02 14:00:00');
INSERT INTO `payment_record` VALUES (199, 248, NULL, 7, 45.00, 'PAID', 'ALIPAY', '2026-02-02 12:00:00', '2026-02-02 15:30:00');
INSERT INTO `payment_record` VALUES (200, 250, NULL, 9, 38.00, 'PAID', 'ALIPAY', '2026-02-03 09:00:00', '2026-02-03 09:15:00');
INSERT INTO `payment_record` VALUES (201, 251, NULL, 10, 18.00, 'PAID', 'ALIPAY', '2026-02-04 09:45:00', '2026-02-04 10:00:00');
INSERT INTO `payment_record` VALUES (202, 252, NULL, 3, 88.00, 'PAID', 'ALIPAY', '2026-02-04 10:30:00', '2026-02-04 11:20:00');
INSERT INTO `payment_record` VALUES (203, 253, NULL, 4, 56.00, 'PAID', 'ALIPAY', '2026-02-05 11:00:00', '2026-02-05 16:00:00');
INSERT INTO `payment_record` VALUES (204, 255, NULL, 6, 45.00, 'PAID', 'ALIPAY', '2026-03-01 09:00:00', '2026-03-01 09:30:00');
INSERT INTO `payment_record` VALUES (205, 256, NULL, 7, 136.00, 'PAID', 'ALIPAY', '2026-03-02 10:00:00', '2026-03-02 10:15:00');
INSERT INTO `payment_record` VALUES (206, 257, NULL, 8, 60.00, 'PAID', 'ALIPAY', '2026-03-02 11:30:00', '2026-03-02 17:00:00');
INSERT INTO `payment_record` VALUES (207, 258, NULL, 9, 18.00, 'PAID', 'ALIPAY', '2026-03-03 09:00:00', '2026-03-03 12:00:00');
INSERT INTO `payment_record` VALUES (208, 259, NULL, 10, 35.00, 'PAID', 'ALIPAY', '2026-03-04 09:50:00', '2026-03-04 10:05:00');
INSERT INTO `payment_record` VALUES (209, 260, NULL, 3, 55.00, 'PAID', 'ALIPAY', '2026-03-05 10:30:00', '2026-03-05 11:00:00');
INSERT INTO `payment_record` VALUES (210, 261, NULL, 4, 36.00, 'PAID', 'ALIPAY', '2026-03-06 11:00:00', '2026-03-06 14:00:00');
INSERT INTO `payment_record` VALUES (211, 263, NULL, 6, 90.00, 'PAID', 'ALIPAY', '2026-03-06 14:00:00', '2026-03-06 18:00:00');
INSERT INTO `payment_record` VALUES (258, 264, NULL, 17, 68.00, 'PAID', 'SIMULATE', '2026-03-08 20:49:33', '2026-03-08 20:49:38');
INSERT INTO `payment_record` VALUES (259, 283, NULL, 18, 29.90, 'PAID', 'ALIPAY', '2026-03-10 15:45:31', '2026-03-10 15:45:33');
INSERT INTO `payment_record` VALUES (260, 284, NULL, 10, 29.90, 'PAID', 'ALIPAY', '2026-03-11 13:23:19', '2026-03-11 13:23:20');
INSERT INTO `payment_record` VALUES (261, 281, NULL, 10, 24.90, 'PAID', 'ALIPAY', '2026-03-11 13:28:09', '2026-03-11 13:28:10');
INSERT INTO `payment_record` VALUES (262, 287, NULL, 10, 29.90, 'PAID', 'ALIPAY', '2026-03-11 14:09:29', '2026-03-11 14:09:30');
INSERT INTO `payment_record` VALUES (263, 288, NULL, 10, 29.90, 'PAID', 'ALIPAY', '2026-03-11 14:11:27', '2026-03-11 14:11:28');
INSERT INTO `payment_record` VALUES (264, 289, NULL, 10, 29.90, 'PAID', 'ALIPAY', '2026-03-11 14:28:20', '2026-03-11 14:28:21');
INSERT INTO `payment_record` VALUES (265, 293, NULL, 10, 18.80, 'PAID', 'ALIPAY', '2026-03-11 18:51:59', '2026-03-11 18:52:00');
INSERT INTO `payment_record` VALUES (266, 291, NULL, 10, 35.00, 'PAID', 'ALIPAY', '2026-03-11 18:52:16', '2026-03-11 18:52:17');
INSERT INTO `payment_record` VALUES (267, 290, NULL, 10, 32.00, 'PAID', 'ALIPAY', '2026-03-11 18:52:23', '2026-03-11 18:52:24');
INSERT INTO `payment_record` VALUES (268, 292, NULL, 10, 33.80, 'PAID', 'ALIPAY', '2026-03-11 18:52:28', '2026-03-11 18:52:29');
INSERT INTO `payment_record` VALUES (269, 309, '309,310', 10, 54.80, 'PAID', 'ALIPAY', '2026-03-11 19:06:41', '2026-03-11 19:06:43');
INSERT INTO `payment_record` VALUES (270, 311, '311,312', 10, 69.80, 'PENDING', 'SIMULATE', '2026-03-11 19:07:04', NULL);
INSERT INTO `payment_record` VALUES (271, 313, NULL, 10, 45.00, 'PAID', 'ALIPAY', '2026-03-11 19:09:35', '2026-03-11 19:09:36');
INSERT INTO `payment_record` VALUES (272, 314, NULL, 11, 45.00, 'PAID', 'ALIPAY', '2026-03-18 12:50:01', '2026-03-18 12:50:02');
INSERT INTO `payment_record` VALUES (273, 317, NULL, 11, 90.00, 'PENDING', 'SIMULATE', '2026-03-18 13:48:14', NULL);
INSERT INTO `payment_record` VALUES (274, 320, NULL, 10, 69.00, 'PAID', 'ALIPAY', '2026-03-19 00:13:04', '2026-03-19 00:13:05');

-- ----------------------------
-- Table structure for sys_banner
-- ----------------------------
DROP TABLE IF EXISTS `sys_banner`;
CREATE TABLE `sys_banner`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sort_order` int NULL DEFAULT NULL,
  `enabled` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_banner
-- ----------------------------
INSERT INTO `sys_banner` VALUES (31, '/banners/dry-clean-blue.svg', '专业干洗 洁净如新', '专业设备 · 精细护理 · 上门取送', '/home/user/service', 0, 1);
INSERT INTO `sys_banner` VALUES (32, '/banners/laundry-green.svg', '绿色洗护 呵护健康', '天然配方 · 温和洁净 · 呵护全家', '/home/user/product', 1, 1);
INSERT INTO `sys_banner` VALUES (33, '/banners/pickup-orange.svg', '一键下单 上门取送', '足不出户 · 轻松享受 · 省时省力', '/home/user/service', 2, 1);

-- ----------------------------
-- Table structure for sys_contact
-- ----------------------------
DROP TABLE IF EXISTS `sys_contact`;
CREATE TABLE `sys_contact`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `hours` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `qr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_contact
-- ----------------------------
INSERT INTO `sys_contact` VALUES (1, '', '', 'https://ts1.tc.mm.bing.net/th/id/R-C.bf2f6f6cafeecc1c1af1d4fd8282320b?rik=JwaSspacJbY1cQ&riu=http%3a%2f%2fpic.baike.soso.com%2fp%2f20130307%2f20130307140436-1179792397.jpg&ehk=u0komVl7XE5CG71BSLTZMFprbi5d2AmNdKAmp8WSAjc%3d&risl=&pid=ImgRaw&r=0');

-- ----------------------------
-- Table structure for sys_home_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_home_config`;
CREATE TABLE `sys_home_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `hot_service_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '首页热门干洗服务ID列表，JSON数组如 [1,2,3,4]',
  `recommend_product_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '首页推荐商品ID列表，JSON数组如 [1,2,3,4]',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '首页模块配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_home_config
-- ----------------------------
INSERT INTO `sys_home_config` VALUES (1, '[23,25,26,27]', '[8,7,6,5]');

-- ----------------------------
-- Table structure for sys_notification
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification`;
CREATE TABLE `sys_notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内容',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'ORDER' COMMENT '类型：ORDER-订单，SYSTEM-系统',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID（如订单ID）',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0-未读 1-已读',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 163 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notification
-- ----------------------------
INSERT INTO `sys_notification` VALUES (1, 2, '支付成功', '订单 DC202501010001 已支付成功，请等待商家接单。', 'ORDER', 1, 1, '2025-01-01 11:00:00');
INSERT INTO `sys_notification` VALUES (2, 2, '商家已接单', '订单 DC202501010001 已接单，正在清洗中。', 'ORDER', 1, 1, '2025-01-01 11:30:00');
INSERT INTO `sys_notification` VALUES (3, 2, '订单已完成', '订单 DC202501010001 已完成，感谢您的使用。', 'ORDER', 1, 1, '2025-01-01 14:00:00');
INSERT INTO `sys_notification` VALUES (4, 2, '支付成功', '订单 DC202501010002 已支付成功，请等待商家接单。', 'ORDER', 2, 1, '2025-01-01 12:00:00');
INSERT INTO `sys_notification` VALUES (5, 2, '订单已完成', '订单 DC202501010006 已完成，感谢您的使用。', 'ORDER', 6, 0, '2025-01-03 16:00:00');
INSERT INTO `sys_notification` VALUES (6, 2, '商家已接单', '订单 DC202501010004 已接单，正在清洗中。', 'ORDER', 4, 0, '2025-01-02 09:00:00');
INSERT INTO `sys_notification` VALUES (7, 3, '支付成功', '订单 DC202501020011 已支付成功，请等待商家接单。', 'ORDER', 11, 1, '2025-01-01 12:00:00');
INSERT INTO `sys_notification` VALUES (8, 3, '订单已完成', '订单 DC202501020011 已完成，感谢您的使用。', 'ORDER', 11, 1, '2025-01-01 14:00:00');
INSERT INTO `sys_notification` VALUES (9, 3, '商家已接单', '订单 DC202501020013 已接单，正在清洗中。', 'ORDER', 13, 0, '2025-01-02 10:00:00');
INSERT INTO `sys_notification` VALUES (10, 4, '支付成功', '订单 DC202501030021 已支付成功，请等待商家接单。', 'ORDER', 21, 1, '2025-01-01 14:00:00');
INSERT INTO `sys_notification` VALUES (11, 4, '订单已完成', '订单 DC202501030021 已完成，感谢您的使用。', 'ORDER', 21, 1, '2025-01-01 16:00:00');
INSERT INTO `sys_notification` VALUES (12, 5, '支付成功', '订单 DC202501040031 已支付成功，请等待商家接单。', 'ORDER', 31, 1, '2025-01-01 15:00:00');
INSERT INTO `sys_notification` VALUES (13, 6, '订单已完成', '订单 DC202501050041 已完成，感谢您的使用。', 'ORDER', 41, 1, '2025-01-01 16:00:00');
INSERT INTO `sys_notification` VALUES (14, 7, '商家已接单', '订单 DC202501060053 已接单，正在清洗中。', 'ORDER', 53, 0, '2025-01-03 13:00:00');
INSERT INTO `sys_notification` VALUES (15, 8, '订单已完成', '订单 DC202501070061 已完成，感谢您的使用。', 'ORDER', 61, 1, '2025-01-01 18:00:00');
INSERT INTO `sys_notification` VALUES (16, 9, '支付成功', '订单 DC202501080071 已支付成功，请等待商家接单。', 'ORDER', 71, 1, '2025-01-01 19:00:00');
INSERT INTO `sys_notification` VALUES (17, 10, '订单已完成', '订单 DC202501090081 已完成，感谢您的使用。', 'ORDER', 81, 1, '2025-01-01 20:00:00');
INSERT INTO `sys_notification` VALUES (18, 11, '商家已接单', '订单 DC202501100093 已接单，正在清洗中。', 'ORDER', 93, 1, '2025-01-03 17:00:00');
INSERT INTO `sys_notification` VALUES (19, 12, '支付成功', '订单 DC202501110101 已支付成功，请等待商家接单。', 'ORDER', 101, 1, '2025-01-02 10:00:00');
INSERT INTO `sys_notification` VALUES (20, 13, '订单已完成', '订单 DC202501120111 已完成，感谢您的使用。', 'ORDER', 111, 1, '2025-01-02 12:00:00');
INSERT INTO `sys_notification` VALUES (21, 14, '商家已接单', '订单 DC202501130123 已接单，正在清洗中。', 'ORDER', 123, 0, '2025-01-03 13:00:00');
INSERT INTO `sys_notification` VALUES (22, 15, '支付成功', '订单 DC202501140131 已支付成功，请等待商家接单。', 'ORDER', 131, 1, '2025-01-02 16:00:00');
INSERT INTO `sys_notification` VALUES (23, 16, '订单已完成', '订单 DC202501150141 已完成，感谢您的使用。', 'ORDER', 141, 1, '2025-01-02 18:00:00');
INSERT INTO `sys_notification` VALUES (24, 17, '订单已完成', '订单 DC202501160151 已完成，感谢您的使用。', 'ORDER', 151, 1, '2025-01-03 10:00:00');
INSERT INTO `sys_notification` VALUES (25, 18, '支付成功', '订单 DC202501170161 已支付成功，请等待商家接单。', 'ORDER', 161, 1, '2025-01-03 12:00:00');
INSERT INTO `sys_notification` VALUES (26, 19, '商家已接单', '订单 DC202501180173 已接单，正在清洗中。', 'ORDER', 173, 0, '2025-01-03 16:00:00');
INSERT INTO `sys_notification` VALUES (27, 20, '订单已完成', '订单 DC202501190181 已完成，感谢您的使用。', 'ORDER', 181, 1, '2025-01-03 16:00:00');
INSERT INTO `sys_notification` VALUES (28, 21, '支付成功', '订单 DC202501200191 已支付成功，请等待商家接单。', 'ORDER', 191, 1, '2025-01-03 18:00:00');
INSERT INTO `sys_notification` VALUES (29, 22, '订单已完成', '订单 DC202501210201 已完成，感谢您的使用。', 'ORDER', 201, 1, '2025-01-04 10:00:00');
INSERT INTO `sys_notification` VALUES (30, 23, '商家已接单', '订单 DC202501220213 已接单，正在清洗中。', 'ORDER', 213, 0, '2025-01-04 14:00:00');
INSERT INTO `sys_notification` VALUES (31, 24, '支付成功', '订单 DC202501230221 已支付成功，请等待商家接单。', 'ORDER', 221, 1, '2025-01-04 14:00:00');
INSERT INTO `sys_notification` VALUES (32, 25, '订单已完成', '订单 DC202501240231 已完成，感谢您的使用。', 'ORDER', 231, 1, '2025-01-04 16:00:00');
INSERT INTO `sys_notification` VALUES (33, 1, '新订单', '订单 DC202501010005 待处理，请及时接单。', 'ORDER', 5, 1, '2025-01-02 10:05:00');
INSERT INTO `sys_notification` VALUES (34, 1, '新订单', '订单 DC202501010007 待处理，请及时接单。', 'ORDER', 7, 1, '2025-01-04 14:05:00');
INSERT INTO `sys_notification` VALUES (35, 1, '新订单', '订单 DC202501020014 待处理，请及时接单。', 'ORDER', 14, 1, '2025-01-03 11:05:00');
INSERT INTO `sys_notification` VALUES (36, 1, '新订单', '订单 DC202501030024 待处理，请及时接单。', 'ORDER', 24, 1, '2025-01-04 13:05:00');
INSERT INTO `sys_notification` VALUES (37, 1, '新订单', '订单 DC202501040034 待处理，请及时接单。', 'ORDER', 34, 1, '2025-01-04 14:05:00');
INSERT INTO `sys_notification` VALUES (38, 1, '新订单', '订单 DC202501050044 待处理，请及时接单。', 'ORDER', 44, 1, '2025-01-04 15:05:00');
INSERT INTO `sys_notification` VALUES (39, 1, '新订单', '订单 DC202501060054 待处理，请及时接单。', 'ORDER', 54, 1, '2025-01-04 16:05:00');
INSERT INTO `sys_notification` VALUES (40, 1, '新订单', '订单 DC202501070064 待处理，请及时接单。', 'ORDER', 64, 1, '2025-01-04 17:05:00');
INSERT INTO `sys_notification` VALUES (41, 1, '新订单', '订单 DC202501080074 待处理，请及时接单。', 'ORDER', 74, 1, '2025-01-04 18:05:00');
INSERT INTO `sys_notification` VALUES (42, 1, '新订单', '订单 DC202501090084 待处理，请及时接单。', 'ORDER', 84, 1, '2025-01-04 19:05:00');
INSERT INTO `sys_notification` VALUES (43, 1, '新订单', '订单 DC202501100094 待处理，请及时接单。', 'ORDER', 94, 1, '2025-01-04 13:05:00');
INSERT INTO `sys_notification` VALUES (44, 1, '新订单', '订单 DC202501110104 待处理，请及时接单。', 'ORDER', 104, 1, '2025-01-03 11:05:00');
INSERT INTO `sys_notification` VALUES (45, 1, '新订单', '订单 DC202501120114 待处理，请及时接单。', 'ORDER', 114, 1, '2025-01-04 14:05:00');
INSERT INTO `sys_notification` VALUES (46, 1, '新订单', '订单 DC202501130124 待处理，请及时接单。', 'ORDER', 124, 1, '2025-01-04 15:05:00');
INSERT INTO `sys_notification` VALUES (47, 1, '新订单', '订单 DC202501140134 待处理，请及时接单。', 'ORDER', 134, 1, '2025-01-04 16:05:00');
INSERT INTO `sys_notification` VALUES (48, 1, '新订单', '订单 DC202501150144 待处理，请及时接单。', 'ORDER', 144, 1, '2025-01-04 17:05:00');
INSERT INTO `sys_notification` VALUES (49, 1, '新订单', '订单 DC202501160154 待处理，请及时接单。', 'ORDER', 154, 1, '2025-01-04 11:05:00');
INSERT INTO `sys_notification` VALUES (50, 1, '新订单', '订单 DC202501170164 待处理，请及时接单。', 'ORDER', 164, 1, '2025-01-04 13:05:00');
INSERT INTO `sys_notification` VALUES (51, 1, '新订单', '订单 DC202501180174 待处理，请及时接单。', 'ORDER', 174, 1, '2025-01-04 15:05:00');
INSERT INTO `sys_notification` VALUES (52, 1, '新订单', '订单 DC202501190184 待处理，请及时接单。', 'ORDER', 184, 1, '2025-01-04 17:05:00');
INSERT INTO `sys_notification` VALUES (53, 1, '新订单', '订单 DC202501200194 待处理，请及时接单。', 'ORDER', 194, 1, '2025-01-04 19:00:00');
INSERT INTO `sys_notification` VALUES (54, 1, '新订单', '订单 DC202501210204 待处理，请及时接单。', 'ORDER', 204, 1, '2025-01-05 11:05:00');
INSERT INTO `sys_notification` VALUES (55, 1, '新订单', '订单 DC202501220214 待处理，请及时接单。', 'ORDER', 214, 1, '2025-01-05 13:05:00');
INSERT INTO `sys_notification` VALUES (56, 1, '新订单', '订单 DC202501230224 待处理，请及时接单。', 'ORDER', 224, 1, '2025-01-05 15:05:00');
INSERT INTO `sys_notification` VALUES (57, 1, '新订单', '订单 DC202501240234 待处理，请及时接单。', 'ORDER', 234, 1, '2025-01-05 17:05:00');
INSERT INTO `sys_notification` VALUES (58, 1, '新订单', '订单 DC17728745952332B35 待处理，请及时接单。', 'ORDER', 241, 1, '2026-03-07 17:09:55');
INSERT INTO `sys_notification` VALUES (59, 10, '支付成功', '订单 DC17728745952332B35 已支付成功。', 'ORDER', 241, 1, '2026-03-07 17:10:32');
INSERT INTO `sys_notification` VALUES (60, 1, '新订单', '订单 DC1772875600810AB34 待处理，请及时接单。', 'ORDER', 242, 1, '2026-03-07 17:26:41');
INSERT INTO `sys_notification` VALUES (61, 10, '支付成功', '订单 DC1772875600810AB34 已支付成功。', 'ORDER', 242, 1, '2026-03-07 18:46:23');
INSERT INTO `sys_notification` VALUES (62, 1, '新订单', '订单 DC1772880393518B524 待处理，请及时接单。', 'ORDER', 243, 1, '2026-03-07 18:46:34');
INSERT INTO `sys_notification` VALUES (63, 2, '新订单', '订单 DC202502010102 待处理，请及时接单。', 'ORDER', 12, 0, '2026-02-01 09:35:00');
INSERT INTO `sys_notification` VALUES (64, 2, '支付成功', '订单 DC202502010102 已支付成功。', 'ORDER', 12, 1, '2026-02-01 10:20:00');
INSERT INTO `sys_notification` VALUES (65, 2, '新订单', '订单 DC202502010103 待处理，请及时接单。', 'ORDER', 13, 0, '2026-02-01 10:05:00');
INSERT INTO `sys_notification` VALUES (66, 2, '新订单', '订单 DC202502030107 待处理，请及时接单。', 'ORDER', 17, 1, '2026-02-03 09:05:00');
INSERT INTO `sys_notification` VALUES (67, 2, '新订单', '订单 DC202503010112 待处理，请及时接单。', 'ORDER', 22, 0, '2026-03-01 09:05:00');
INSERT INTO `sys_notification` VALUES (68, 3, '订单已接单', '您的订单 DC202502010102 已接单，师傅将尽快上门取衣。', 'ORDER', 12, 1, '2026-02-01 10:25:00');
INSERT INTO `sys_notification` VALUES (69, 4, '订单已完成', '您的订单 DC202502020104 已完成。', 'ORDER', 14, 1, '2026-02-02 14:10:00');
INSERT INTO `sys_notification` VALUES (70, 5, '支付成功', '您的订单 DC202502010103 已支付成功。', 'ORDER', 13, 1, '2026-02-01 11:00:00');
INSERT INTO `sys_notification` VALUES (71, 6, '新订单', '订单 DC202502030106 待处理。', 'ORDER', 16, 1, '2026-02-03 08:05:00');
INSERT INTO `sys_notification` VALUES (72, 7, '订单已接单', '您的订单 DC202503020113 已接单。', 'ORDER', 23, 0, '2026-03-02 10:20:00');
INSERT INTO `sys_notification` VALUES (73, 8, '订单已完成', '您的订单 DC202502040108 已完成。', 'ORDER', 18, 1, '2026-02-04 15:00:00');
INSERT INTO `sys_notification` VALUES (74, 9, '支付成功', '您的订单 DC202503050117 已支付成功。', 'ORDER', 27, 1, '2026-03-05 11:00:00');
INSERT INTO `sys_notification` VALUES (75, 10, '新订单', '订单 DC202503040116 待处理。', 'ORDER', 26, 1, '2026-03-04 09:55:00');
INSERT INTO `sys_notification` VALUES (76, 2, '新订单', '订单 DC202503060120 待处理。', 'ORDER', 30, 0, '2026-03-06 14:05:00');
INSERT INTO `sys_notification` VALUES (77, 3, '订单已接单', '您的订单 DC202502040109 已接单。', 'ORDER', 19, 1, '2026-02-04 10:45:00');
INSERT INTO `sys_notification` VALUES (78, 1, '新订单', '订单 DC17729741659717D0C 待处理，请及时接单。', 'ORDER', 264, 1, '2026-03-08 20:49:26');
INSERT INTO `sys_notification` VALUES (79, 17, '支付成功', '订单 DC17729741659717D0C 已支付成功。', 'ORDER', 264, 0, '2026-03-08 20:49:38');
INSERT INTO `sys_notification` VALUES (80, 1, '新订单', '订单 DC1772976463692FE7B 待处理，请及时接单。', 'ORDER', 265, 1, '2026-03-08 21:27:44');
INSERT INTO `sys_notification` VALUES (81, 10, '支付成功', '订单 DC1772880393518B524 已支付成功。', 'ORDER', 243, 1, '2026-03-09 17:30:02');
INSERT INTO `sys_notification` VALUES (82, 26, '新订单', '订单 DC1773070061957F9C8 待处理，请及时接单。', 'ORDER', 278, 0, '2026-03-09 23:27:42');
INSERT INTO `sys_notification` VALUES (83, 26, '新订单', '订单 DC1773070062044EE3A 待处理，请及时接单。', 'ORDER', 279, 0, '2026-03-09 23:27:42');
INSERT INTO `sys_notification` VALUES (84, 26, '新订单', '订单 DC17730700620708F36 待处理，请及时接单。', 'ORDER', 280, 0, '2026-03-09 23:27:42');
INSERT INTO `sys_notification` VALUES (85, 26, '新订单', '订单 DC17730700621010D1E 待处理，请及时接单。', 'ORDER', 281, 0, '2026-03-09 23:27:42');
INSERT INTO `sys_notification` VALUES (86, 26, '新订单', '订单 DC1773070593859E636 待处理，请及时接单。', 'ORDER', 282, 0, '2026-03-09 23:36:34');
INSERT INTO `sys_notification` VALUES (87, 26, '新订单', '订单 DC17731242539212EA5 待处理，请及时接单。', 'ORDER', 283, 0, '2026-03-10 14:30:54');
INSERT INTO `sys_notification` VALUES (88, 18, '支付成功', '订单 DC17731242539212EA5 已支付成功。', 'ORDER', 283, 0, '2026-03-10 15:45:33');
INSERT INTO `sys_notification` VALUES (89, 26, '新订单', '订单 DC1773206573246200C 待处理，请及时接单。', 'ORDER', 284, 0, '2026-03-11 13:22:53');
INSERT INTO `sys_notification` VALUES (90, 26, '新订单', '订单 DC1773206573398EE7D 待处理，请及时接单。', 'ORDER', 285, 0, '2026-03-11 13:22:53');
INSERT INTO `sys_notification` VALUES (91, 10, '支付成功', '订单 DC1773206573246200C 已支付成功。', 'ORDER', 284, 1, '2026-03-11 13:23:20');
INSERT INTO `sys_notification` VALUES (92, 10, '支付成功', '订单 DC17730700621010D1E 已支付成功。', 'ORDER', 281, 1, '2026-03-11 13:28:10');
INSERT INTO `sys_notification` VALUES (93, 26, '新订单', '订单 DC1773209330423C221 待处理，请及时接单。', 'ORDER', 286, 0, '2026-03-11 14:08:50');
INSERT INTO `sys_notification` VALUES (94, 26, '新订单', '订单 DC17732093670007E0D 待处理，请及时接单。', 'ORDER', 287, 0, '2026-03-11 14:09:27');
INSERT INTO `sys_notification` VALUES (95, 10, '支付成功', '订单 DC17732093670007E0D 已支付成功。', 'ORDER', 287, 1, '2026-03-11 14:09:30');
INSERT INTO `sys_notification` VALUES (96, 26, '新订单', '订单 DC177320948484660B2 待处理，请及时接单。', 'ORDER', 288, 0, '2026-03-11 14:11:25');
INSERT INTO `sys_notification` VALUES (97, 10, '支付成功', '订单 DC177320948484660B2 已支付成功。', 'ORDER', 288, 1, '2026-03-11 14:11:28');
INSERT INTO `sys_notification` VALUES (98, 26, '新订单', '订单 DC17732104980222B0C 待处理，请及时接单。', 'ORDER', 289, 0, '2026-03-11 14:28:18');
INSERT INTO `sys_notification` VALUES (99, 10, '支付成功', '订单 DC17732104980222B0C 已支付成功。', 'ORDER', 289, 1, '2026-03-11 14:28:21');
INSERT INTO `sys_notification` VALUES (100, 1, '新订单', '订单 DC17732263167513709 待处理，请及时接单。', 'ORDER', 290, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (101, 26, '新订单', '订单 DC17732263167513709 待处理，请及时接单。', 'ORDER', 290, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (102, 1, '新订单', '订单 DC17732263167976361 待处理，请及时接单。', 'ORDER', 291, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (103, 26, '新订单', '订单 DC17732263167976361 待处理，请及时接单。', 'ORDER', 291, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (104, 1, '新订单', '订单 DC1773226316814A869 待处理，请及时接单。', 'ORDER', 292, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (105, 26, '新订单', '订单 DC1773226316814A869 待处理，请及时接单。', 'ORDER', 292, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (106, 1, '新订单', '订单 DC17732263168335D52 待处理，请及时接单。', 'ORDER', 293, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (107, 26, '新订单', '订单 DC17732263168335D52 待处理，请及时接单。', 'ORDER', 293, 0, '2026-03-11 18:51:57');
INSERT INTO `sys_notification` VALUES (108, 10, '支付成功', '订单 DC17732263168335D52 已支付成功。', 'ORDER', 293, 1, '2026-03-11 18:52:00');
INSERT INTO `sys_notification` VALUES (109, 10, '确认收货成功', '订单 DC17732263168335D52 已确认收货，感谢您的使用。', 'ORDER', 293, 1, '2026-03-11 18:52:05');
INSERT INTO `sys_notification` VALUES (110, 10, '支付成功', '订单 DC17732263167976361 已支付成功。', 'ORDER', 291, 1, '2026-03-11 18:52:17');
INSERT INTO `sys_notification` VALUES (111, 10, '确认收货成功', '订单 DC17732263167976361 已确认收货，感谢您的使用。', 'ORDER', 291, 1, '2026-03-11 18:52:21');
INSERT INTO `sys_notification` VALUES (112, 10, '支付成功', '订单 DC17732263167513709 已支付成功。', 'ORDER', 290, 1, '2026-03-11 18:52:24');
INSERT INTO `sys_notification` VALUES (113, 10, '确认收货成功', '订单 DC17732263167513709 已确认收货，感谢您的使用。', 'ORDER', 290, 1, '2026-03-11 18:52:26');
INSERT INTO `sys_notification` VALUES (114, 10, '支付成功', '订单 DC1773226316814A869 已支付成功。', 'ORDER', 292, 1, '2026-03-11 18:52:29');
INSERT INTO `sys_notification` VALUES (115, 1, '新订单', '订单 DC177322673554115CA 待处理，请及时接单。', 'ORDER', 294, 0, '2026-03-11 18:58:56');
INSERT INTO `sys_notification` VALUES (116, 26, '新订单', '订单 DC177322673554115CA 待处理，请及时接单。', 'ORDER', 294, 0, '2026-03-11 18:58:56');
INSERT INTO `sys_notification` VALUES (117, 1, '新订单', '订单 DC1773226735576756E 待处理，请及时接单。', 'ORDER', 295, 0, '2026-03-11 18:58:56');
INSERT INTO `sys_notification` VALUES (118, 26, '新订单', '订单 DC1773226735576756E 待处理，请及时接单。', 'ORDER', 295, 0, '2026-03-11 18:58:56');
INSERT INTO `sys_notification` VALUES (119, 1, '新订单', '订单 DC1773226744156EC32 待处理，请及时接单。', 'ORDER', 296, 0, '2026-03-11 18:59:04');
INSERT INTO `sys_notification` VALUES (120, 26, '新订单', '订单 DC1773226744156EC32 待处理，请及时接单。', 'ORDER', 296, 0, '2026-03-11 18:59:04');
INSERT INTO `sys_notification` VALUES (121, 1, '新订单', '订单 DC1773226744180B365 待处理，请及时接单。', 'ORDER', 297, 0, '2026-03-11 18:59:04');
INSERT INTO `sys_notification` VALUES (122, 26, '新订单', '订单 DC1773226744180B365 待处理，请及时接单。', 'ORDER', 297, 0, '2026-03-11 18:59:04');
INSERT INTO `sys_notification` VALUES (123, 1, '新订单', '订单 DC1773226812575D3B5 待处理，请及时接单。', 'ORDER', 298, 0, '2026-03-11 19:00:13');
INSERT INTO `sys_notification` VALUES (124, 26, '新订单', '订单 DC1773226812575D3B5 待处理，请及时接单。', 'ORDER', 298, 0, '2026-03-11 19:00:13');
INSERT INTO `sys_notification` VALUES (125, 1, '新订单', '订单 DC17732268126002E80 待处理，请及时接单。', 'ORDER', 299, 0, '2026-03-11 19:00:13');
INSERT INTO `sys_notification` VALUES (126, 26, '新订单', '订单 DC17732268126002E80 待处理，请及时接单。', 'ORDER', 299, 0, '2026-03-11 19:00:13');
INSERT INTO `sys_notification` VALUES (127, 1, '新订单', '订单 DC17732268176845469 待处理，请及时接单。', 'ORDER', 300, 0, '2026-03-11 19:00:18');
INSERT INTO `sys_notification` VALUES (128, 26, '新订单', '订单 DC17732268176845469 待处理，请及时接单。', 'ORDER', 300, 0, '2026-03-11 19:00:18');
INSERT INTO `sys_notification` VALUES (129, 1, '新订单', '订单 DC1773226817703DC57 待处理，请及时接单。', 'ORDER', 301, 0, '2026-03-11 19:00:18');
INSERT INTO `sys_notification` VALUES (130, 26, '新订单', '订单 DC1773226817703DC57 待处理，请及时接单。', 'ORDER', 301, 0, '2026-03-11 19:00:18');
INSERT INTO `sys_notification` VALUES (131, 1, '新订单', '订单 DC17732269142908423 待处理，请及时接单。', 'ORDER', 302, 0, '2026-03-11 19:01:54');
INSERT INTO `sys_notification` VALUES (132, 26, '新订单', '订单 DC17732269142908423 待处理，请及时接单。', 'ORDER', 302, 0, '2026-03-11 19:01:54');
INSERT INTO `sys_notification` VALUES (133, 1, '新订单', '订单 DC177322691432230E0 待处理，请及时接单。', 'ORDER', 303, 0, '2026-03-11 19:01:54');
INSERT INTO `sys_notification` VALUES (134, 26, '新订单', '订单 DC177322691432230E0 待处理，请及时接单。', 'ORDER', 303, 0, '2026-03-11 19:01:54');
INSERT INTO `sys_notification` VALUES (135, 1, '新订单', '订单 DC1773226922794F84E 待处理，请及时接单。', 'ORDER', 304, 0, '2026-03-11 19:02:03');
INSERT INTO `sys_notification` VALUES (136, 26, '新订单', '订单 DC1773226922794F84E 待处理，请及时接单。', 'ORDER', 304, 0, '2026-03-11 19:02:03');
INSERT INTO `sys_notification` VALUES (137, 1, '新订单', '订单 DC1773226922813273E 待处理，请及时接单。', 'ORDER', 305, 0, '2026-03-11 19:02:03');
INSERT INTO `sys_notification` VALUES (138, 26, '新订单', '订单 DC1773226922813273E 待处理，请及时接单。', 'ORDER', 305, 0, '2026-03-11 19:02:03');
INSERT INTO `sys_notification` VALUES (139, 1, '新订单', '订单 DC17732271062748C4A 待处理，请及时接单。', 'ORDER', 306, 0, '2026-03-11 19:05:06');
INSERT INTO `sys_notification` VALUES (140, 26, '新订单', '订单 DC17732271062748C4A 待处理，请及时接单。', 'ORDER', 306, 0, '2026-03-11 19:05:06');
INSERT INTO `sys_notification` VALUES (141, 1, '新订单', '订单 DC177322710637625C3 待处理，请及时接单。', 'ORDER', 307, 0, '2026-03-11 19:05:06');
INSERT INTO `sys_notification` VALUES (142, 26, '新订单', '订单 DC177322710637625C3 待处理，请及时接单。', 'ORDER', 307, 0, '2026-03-11 19:05:06');
INSERT INTO `sys_notification` VALUES (143, 1, '新订单', '订单 DC1773227135695E455 待处理，请及时接单。', 'ORDER', 308, 0, '2026-03-11 19:05:36');
INSERT INTO `sys_notification` VALUES (144, 26, '新订单', '订单 DC1773227135695E455 待处理，请及时接单。', 'ORDER', 308, 0, '2026-03-11 19:05:36');
INSERT INTO `sys_notification` VALUES (145, 1, '新订单', '订单 DC1773227200848DBBC 待处理，请及时接单。', 'ORDER', 309, 0, '2026-03-11 19:06:41');
INSERT INTO `sys_notification` VALUES (146, 26, '新订单', '订单 DC1773227200848DBBC 待处理，请及时接单。', 'ORDER', 309, 0, '2026-03-11 19:06:41');
INSERT INTO `sys_notification` VALUES (147, 1, '新订单', '订单 DC17732272009333BA7 待处理，请及时接单。', 'ORDER', 310, 0, '2026-03-11 19:06:41');
INSERT INTO `sys_notification` VALUES (148, 26, '新订单', '订单 DC17732272009333BA7 待处理，请及时接单。', 'ORDER', 310, 0, '2026-03-11 19:06:41');
INSERT INTO `sys_notification` VALUES (149, 10, '支付成功', '订单 DC1773227200848DBBC 已支付成功。', 'ORDER', 309, 1, '2026-03-11 19:06:43');
INSERT INTO `sys_notification` VALUES (150, 1, '新订单', '订单 DC17732272241252DC5 待处理，请及时接单。', 'ORDER', 311, 0, '2026-03-11 19:07:04');
INSERT INTO `sys_notification` VALUES (151, 26, '新订单', '订单 DC17732272241252DC5 待处理，请及时接单。', 'ORDER', 311, 0, '2026-03-11 19:07:04');
INSERT INTO `sys_notification` VALUES (152, 1, '新订单', '订单 DC177322722414418D2 待处理，请及时接单。', 'ORDER', 312, 0, '2026-03-11 19:07:04');
INSERT INTO `sys_notification` VALUES (153, 26, '新订单', '订单 DC177322722414418D2 待处理，请及时接单。', 'ORDER', 312, 0, '2026-03-11 19:07:04');
INSERT INTO `sys_notification` VALUES (154, 10, '确认收货成功', '订单 DC1773226316814A869 已确认收货，感谢您的使用。', 'ORDER', 292, 1, '2026-03-11 19:07:22');
INSERT INTO `sys_notification` VALUES (155, 1, '新订单', '订单 DC1773227265831002B 待处理，请及时接单。', 'ORDER', 313, 0, '2026-03-11 19:07:46');
INSERT INTO `sys_notification` VALUES (156, 26, '新订单', '订单 DC1773227265831002B 待处理，请及时接单。', 'ORDER', 313, 0, '2026-03-11 19:07:46');
INSERT INTO `sys_notification` VALUES (157, 10, '支付成功', '订单 DC1773227265831002B 已支付成功。', 'ORDER', 313, 1, '2026-03-11 19:09:36');
INSERT INTO `sys_notification` VALUES (158, 11, '支付成功', '订单 DC17738093982604635 已支付成功。', 'ORDER', 314, 0, '2026-03-18 12:50:02');
INSERT INTO `sys_notification` VALUES (159, 11, '订单取消', '订单 DC17738111842173677 已取消。', 'ORDER', 315, 0, '2026-03-18 13:47:23');
INSERT INTO `sys_notification` VALUES (160, 11, '订单取消', '订单 DC17738128502839652 已取消。', 'ORDER', 316, 0, '2026-03-18 13:47:59');
INSERT INTO `sys_notification` VALUES (161, 11, '订单取消', '订单 DC17738128910911CE9 已取消。', 'ORDER', 317, 0, '2026-03-18 13:48:17');
INSERT INTO `sys_notification` VALUES (162, 10, '支付成功', '订单 DC1773850380831E5F1 已支付成功。', 'ORDER', 320, 1, '2026-03-19 00:13:05');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（加密存储）',
  `real_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER' COMMENT '角色：USER-顾客，MERCHANT-商家，ADMIN-管理员',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-正常',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像图片URL',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'supperadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '超级管理员', '13800000001', 'SUPPERADMIN', 1, '2026-03-06 15:12:10', '2026-03-09 17:14:04', NULL);
INSERT INTO `sys_user` VALUES (2, 'zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张三', '13800000002', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (3, 'lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李四', '13900000003', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (4, 'wangwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王五', '13700000004', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (5, 'zhaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵六', '13600000005', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (6, 'sunqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '孙七', '13500000006', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (7, 'zhouyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '周毅', '13400000007', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (8, 'wujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '吴九', '13300000008', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (9, 'zhengshi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '郑实', '13200000009', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (10, 'chenxiaoy', '$2a$10$esJ3jBu1V4RThqvNC3R.ne0E.smR0RXXZHBVBxbb7qYikNbA/IUXm', '陈小艺', '13100000010', 'USER', 1, '2026-03-06 15:12:10', '2026-03-11 14:38:26', '/api/uploads/product/13a0690edb3443179732a2dbcd67e073.png');
INSERT INTO `sys_user` VALUES (11, 'linwei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '林伟', '13000000011', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (12, 'huangmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黄敏', '12900000012', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (13, 'xuyan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '许艳', '12800000013', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (14, 'helei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '何磊', '12700000014', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (15, 'gaofang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '高芳', '12600000015', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (16, 'linhong', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '林红', '12500000016', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (17, 'luoyang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '罗阳', '12400000017', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (18, 'liangxin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '梁欣', '12300000018', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (19, 'songjie', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '宋杰', '12200000019', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (20, 'tanglin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '唐琳', '12100000020', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (21, 'hanfei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '韩飞', '12000000021', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (22, 'fengyu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '冯雨', '11900000022', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (23, 'dengqiang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '邓强', '11800000023', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (24, 'caomei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '曹梅', '11700000024', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (25, 'pengxue', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '彭雪', '11600000025', 'USER', 1, '2026-03-06 15:12:10', '2026-03-06 15:12:10', NULL);
INSERT INTO `sys_user` VALUES (26, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '平台管理员', '13800000000', 'ADMIN', 1, '2026-03-06 15:26:39', '2026-03-07 16:51:30', NULL);
INSERT INTO `sys_user` VALUES (28, 'sanyi', '$2a$10$iXIRK1RUagrslgrlArIuKe9kg6hfeoFGbO2aWYtM8ebP5nDZbxa4.', NULL, '16959866257', 'USER', 1, '2026-03-09 23:29:10', '2026-03-09 23:34:58', NULL);

-- ----------------------------
-- Table structure for user_address
-- ----------------------------
DROP TABLE IF EXISTS `user_address`;
CREATE TABLE `user_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `contact_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `province` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `detail_address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT NULL,
  `updated_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_address
-- ----------------------------
INSERT INTO `user_address` VALUES (1, 3, '张先生', '13800135678', '广东省', '深圳市', '南山区', '阳光花园12栋304', 1, '2026-03-07 18:45:32', '2026-03-07 18:45:32');
INSERT INTO `user_address` VALUES (2, 10, '伊一', '16798612591', '青海省', '海北藏族自治州', '海晏县', '学府路', 1, '2026-03-07 18:46:04', '2026-03-11 19:51:50');
INSERT INTO `user_address` VALUES (3, 2, '商家管理员', '13800000001', '广东省', '深圳市', '南山区', '阳光花园商业街A区', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (4, 3, '张三', '13800000002', '广东省', '深圳市', '福田区', '福华一路88号', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (5, 3, '张三', '13900000003', '广东省', '深圳市', '南山区', '科技园南区A栋5楼', 0, NULL, NULL);
INSERT INTO `user_address` VALUES (6, 4, '李四', '13700000004', '广东省', '深圳市', '罗湖区', '东门步行街翠华花园3栋', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (7, 5, '王五', '13600000005', '广东省', '深圳市', '宝安区', '新安街道创业路100号', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (8, 6, '赵六', '13500000006', '广东省', '深圳市', '龙岗区', '坂田五和大道168号', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (9, 7, '孙七', '13400000007', '广东省', '深圳市', '南山区', '后海大道海德二道交汇处', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (10, 8, '周毅', '13300000008', '广东省', '深圳市', '福田区', '中心区益田路与福华路交汇', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (11, 9, '吴九', '13200000009', '广东省', '深圳市', '龙华区', '民治梅龙路梅林关口', 1, NULL, NULL);
INSERT INTO `user_address` VALUES (12, 10, '郑实', '13100000010', '广东省', '深圳市', '盐田区', '沙头角海山街道', 0, NULL, '2026-03-11 16:28:55');
INSERT INTO `user_address` VALUES (13, 17, '五子棋', '16965925681', '河北省', '保定市', '竞秀区', '1', 1, '2026-03-08 20:49:22', '2026-03-08 20:49:22');
INSERT INTO `user_address` VALUES (14, 28, '三一', '16986543268', '河北省', '石家庄', '新华区', '杜北街道', 0, '2026-03-09 23:36:32', '2026-03-09 23:36:32');
INSERT INTO `user_address` VALUES (15, 18, '1', '168', NULL, NULL, NULL, '北京市', 0, '2026-03-10 14:28:17', '2026-03-10 14:28:17');
INSERT INTO `user_address` VALUES (16, 11, '吴', '16986532681', '河北省', '保定市', '莲池区', '杜北', 0, '2026-03-18 12:47:55', '2026-03-18 12:47:55');

-- ----------------------------
-- Table structure for ai_knowledge
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge`;
CREATE TABLE `ai_knowledge`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `question` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标准问题',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标准答案',
  `category` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '干洗咨询' COMMENT '知识分类',
  `keywords` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '匹配关键词',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0-停用 1-启用',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `hit_count` int NOT NULL DEFAULT 0 COMMENT '命中次数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_ai_knowledge_status`(`status` ASC) USING BTREE,
  INDEX `idx_ai_knowledge_category`(`category` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI客服知识库' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_knowledge
-- ----------------------------
INSERT INTO `ai_knowledge` VALUES (1, '羽绒服干洗需要多久？', '羽绒服一般需要5-7天左右。旺季、厚款、长款或有顽固污渍时可能顺延1-2天；下单时可以在备注里说明取衣时间要求。', '洗护周期', '羽绒服,多久,周期,取衣,加急', 1, 1, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (2, '西装干洗怎么收费？', '西装上衣69元起，上衣+裤子套装99元起，三件套含马甲129元起。最终价格会根据规格和实际材质确认。', '价格规格', '西装,套装,价格,收费,马甲', 1, 2, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (3, '羊绒大衣可以干洗吗？', '羊绒、羊毛大衣建议专业干洗。我们会先检查洗标和污渍，再进行预处理、低温清洗、整形熨烫，减少缩水和变形风险。', '洗护方式', '羊绒大衣,羊毛大衣,干洗,缩水,变形', 1, 3, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (4, '皮衣护理需要几天？', '皮衣清洁保养通常需要7-10天。皮质补色、上油、局部修复等项目需要师傅评估后确认时间。', '洗护周期', '皮衣,护理,补色,上油,多久', 1, 4, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (5, '可以上门取衣吗？', '支持上门取衣。你可以在下单时选择地址并填写联系电话，门店会按预约时段联系取件；部分偏远区域可能需要人工确认服务范围。', '取送服务', '上门,取衣,取件,地址,预约时段', 1, 5, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (6, '洗完可以送回家吗？', '支持洗后送回。订单完成后可选择到店自取或配送到家，配送时间以门店实际安排和用户地址为准。', '取送服务', '送回,配送,到家,自取,订单完成', 1, 6, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (7, '衣服有油渍能洗掉吗？', '油渍会先做局部预处理，再进入清洗流程。新鲜油渍成功率更高，陈年油渍、染色类污渍无法保证完全去除。', '污渍处理', '油渍,污渍,去渍,陈年污渍,预处理', 1, 7, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (8, '衣服染色了怎么办？', '染色问题建议先拍照并送店评估。串色、褪色、深浅色互染需要专业判断，部分面料只能淡化，不能保证恢复原样。', '污渍处理', '染色,串色,褪色,恢复,评估', 1, 8, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (9, '真丝衣物可以洗吗？', '真丝衣物可以护理，但需要看洗标和染色牢度。建议选择真丝专项清洗，避免高温、强搓和长时间浸泡。', '洗护方式', '真丝,丝绸,洗标,褪色,精洗', 1, 9, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (10, '鞋子清洗需要多久？', '运动鞋、帆布鞋一般3-7天；皮鞋护理约3-5天；雪地靴和长靴通常5-8天。特殊材质或补色会延长。', '洗护周期', '鞋子,运动鞋,皮鞋,雪地靴,长靴,多久', 1, 10, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (11, '窗帘清洗怎么收费？', '普通窗帘按米计价，约25元/米起；加厚、遮光、纱帘价格不同。下单前建议备注尺寸和层数，门店会核价。', '价格规格', '窗帘,按米,价格,遮光帘,纱帘', 1, 11, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (12, '床单被罩多久能洗好？', '床单、被罩、四件套一般4-6天左右，遇到大件集中清洗或梅雨天气可能顺延。', '洗护周期', '床单,被罩,四件套,大件,周期', 1, 12, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (13, '可以加急洗衣吗？', '部分普通衣物支持加急，需要门店确认排单和面料情况。羽绒服、皮衣、奢侈品护理通常不建议强行加急。', '订单服务', '加急,当天取,排单,普通衣物,门店确认', 1, 13, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (14, '订单怎么取消？', '未取件或未开始清洗的订单可以申请取消；已开始清洗的订单需要联系门店确认，可能无法全额退款。', '订单服务', '取消订单,退款,未取件,已清洗', 1, 14, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (15, '衣服洗坏了怎么处理？', '请第一时间保留衣物、订单和照片，在订单售后或门店联系工作人员。平台会根据收衣检查记录、洗标和实际情况协助处理。', '售后服务', '洗坏,赔付,售后,投诉,订单', 1, 15, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (16, '衣物丢失怎么办？', '若怀疑衣物丢失，请提供订单号、衣物照片和取送记录。门店会核查交接记录、清点单和监控信息后给出处理方案。', '售后服务', '丢失,找不到,订单号,清点,赔付', 1, 16, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (17, '哪些衣物不适合普通水洗？', '羊绒羊毛、真丝、皮革、含涂层面料、结构复杂礼服、易褪色深色衣物不建议普通水洗，应按洗标选择专业干洗或精洗。', '洗护方式', '不适合水洗,羊毛,真丝,皮革,礼服,洗标', 1, 17, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (18, '洗衣前需要自己处理口袋吗？', '建议下单前取出口袋内现金、票据、耳机、钥匙等物品。门店也会做基础检查，但贵重和隐私物品请提前自查。', '下单提醒', '口袋,贵重物品,票据,钥匙,下单提醒', 1, 18, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (19, '有会员折扣吗？', '服务页展示“会员再享9折”的项目，可在下单结算时查看实际优惠。不同活动、商品和服务可能适用规则不同。', '优惠活动', '会员,折扣,优惠,9折,活动', 1, 19, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (20, '怎么查看我的订单？', '登录后进入“我的订单”即可查看订单状态、付款信息、取送进度和售后入口。', '订单服务', '我的订单,订单状态,付款,进度,登录', 1, 20, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (21, '干洗和水洗有什么区别？', '干洗主要使用专业溶剂处理油性污渍，适合羊毛、羊绒、西装等易变形面料；水洗更适合棉麻、运动服、床品等耐水洗衣物。', '洗护方式', '干洗,水洗,区别,溶剂,面料', 1, 21, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (22, '毛毯清洗怎么收费？', '毛毯按尺寸和厚度收费，小毛毯60元起，中毛毯80元起，大毛毯100元起，加厚款会加收护理费。', '价格规格', '毛毯,尺寸,厚度,大件,价格', 1, 22, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (23, '玩偶公仔可以清洗吗？', '毛绒玩偶、公仔可以清洗，小号25元起。带电子元件、发声装置或特殊填充物的玩偶需先说明，门店会评估是否可洗。', '洗护方式', '玩偶,公仔,毛绒,电子元件,填充物', 1, 23, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (24, '洗护用品商城卖什么？', '商城提供洗衣液、柔顺剂、衣物除菌液、去渍笔、防串色片、鞋类护理剂等洗护用品，可和干洗服务一起下单。', '商城商品', '洗护用品,洗衣液,柔顺剂,去渍笔,防串色片', 1, 24, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (25, '去渍笔适合什么场景？', '去渍笔适合临时处理咖啡、酱汁、口红等小面积新鲜污渍。贵重衣物、真丝羊绒和大面积污渍建议交给门店处理。', '商城商品', '去渍笔,咖啡,酱汁,口红,新鲜污渍', 1, 25, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (26, '如何选择附近门店？', '进入“附近门店”可以查看门店位置、联系方式和服务范围。建议优先选择距离近、营业中且支持取送的门店。', '门店服务', '附近门店,地址,电话,营业,服务范围', 1, 26, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (27, '收衣时会检查衣物吗？', '会检查。门店会核对衣物数量、明显污渍、破损、纽扣拉链和洗标信息；特殊情况建议拍照备注，避免后续争议。', '下单提醒', '收衣检查,污渍,破损,纽扣,洗标', 1, 27, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (28, '深色衣服会掉色吗？', '深色衣物存在褪色风险，尤其是牛仔、真丝、棉麻和新衣。门店会做基础判断，但无法完全避免面料本身染色牢度问题。', '风险提示', '深色,掉色,褪色,牛仔,染色牢度', 1, 28, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (29, '可以开发票吗？', '如需发票，请在订单备注或联系门店说明开票抬头、税号和金额。具体开票类型以门店支持范围为准。', '订单服务', '发票,开票,抬头,税号,金额', 1, 29, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (30, '支付后还能修改地址吗？', '若订单未取件，可以在联系门店后修改取送地址；已安排配送或已完成取件的订单，需要由门店确认是否可调整。', '订单服务', '修改地址,支付后,取送地址,配送,门店确认', 1, 30, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (31, 'AI客服回答不准确怎么办？', '如果 AI 客服答案和订单实际情况不一致，请以订单详情、门店通知和人工客服确认为准。你也可以换一种问法继续咨询。', 'AI客服', 'AI客服,不准确,人工客服,订单详情,门店通知', 1, 31, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');
INSERT INTO `ai_knowledge` VALUES (32, '知识库没有的问题谁来回答？', '知识库没有命中的问题会自动转由 OpenAI 回答。若后端未配置 OPENAI_API_KEY，系统会给出兜底提示，避免影响页面使用。', 'AI客服', '知识库,OpenAI,OPENAI_API_KEY,兜底,回答', 1, 32, 0, '2026-03-19 00:20:00', '2026-03-19 00:20:00');

-- ----------------------------
-- Table structure for ai_chat_message
-- ----------------------------
DROP TABLE IF EXISTS `ai_chat_message`;
CREATE TABLE `ai_chat_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID，游客为空',
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户问题',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'AI回答',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'KNOWLEDGE/OPENAI/ZHIPU/FALLBACK',
  `matched_knowledge_id` bigint NULL DEFAULT NULL COMMENT '命中的知识库ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_ai_chat_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_ai_chat_knowledge`(`matched_knowledge_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI客服问答日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_chat_message
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
