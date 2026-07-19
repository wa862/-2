DELETE FROM `sys_banner`;

INSERT INTO `sys_banner` (`id`, `image`, `title`, `subtitle`, `link`, `sort_order`, `enabled`) VALUES
(31, '/banners/dry-clean-blue.svg', '专业干洗 洁净如新', '专业设备 · 精细护理 · 上门取送', '/home/user/service', 0, 1),
(32, '/banners/laundry-green.svg', '绿色洗护 呵护健康', '天然配方 · 温和洁净 · 呵护全家', '/home/user/product', 1, 1),
(33, '/banners/pickup-orange.svg', '一键下单 上门取送', '足不出户 · 轻松享受 · 省时省力', '/home/user/service', 2, 1);
