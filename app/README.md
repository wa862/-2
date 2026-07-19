# 洗衣优选 · 小程序端

该目录是洗衣优选微信小程序端，基于 UniApp + Vue 3 + TypeScript 开发，共用 `backend` 后端接口。

## 功能页面

| 功能 | 页面 |
| --- | --- |
| 首页 | `pages/index/index` |
| 干洗服务 | `pages/service/list` |
| 预约下单 | `pages/service/order-create` |
| 商品商城 | `pages/product/list` |
| 购物车 | `pages/cart/cart` |
| 确认订单 | `pages/checkout/checkout` |
| 附近门店 | `pages/store/nearby` |
| AI 客服 | `pages/ai/assistant` |
| 我的订单 | `pages/order/list` |
| 个人中心 | `pages/profile/profile` |

## 主要特性

- 首页轮播、服务入口、热门干洗服务、推荐商品。
- 商城分类、商品搜索、加入购物车。
- 干洗服务预约、规格选择、取送方式、取衣日期、加急、门店选择。
- 购物车按干洗服务和商品分组展示。
- 确认订单页支持附近门店定位选择，选择后实时回填。
- AI 客服页面支持洗护知识问答，浮动 AI 客服入口可拖拽。

## 安装运行

```bash
cd app
npm install
npm run dev:mp-weixin
```

微信开发者工具打开：

```text
app/dist/dev/mp-weixin
```

H5 调试：

```bash
npm run dev:h5
```

## 构建

```bash
npm run build:mp-weixin
```

发布目录：

```text
app/dist/build/mp-weixin
```

## 后端地址

配置文件：

```text
app/src/config/index.ts
```

本地模拟器可使用：

```ts
http://127.0.0.1:8080/api
```

真机调试请改成电脑局域网 IP：

```ts
http://192.168.1.100:8080/api
```

微信开发者工具中需要勾选“不校验合法域名”。上线前需要在微信公众平台配置 request 合法域名。
