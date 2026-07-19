# 洗衣优选 · 干洗商城系统

洗衣优选是一套面向干洗服务场景的多端商城系统，包含顾客网页版、微信小程序端、管理后台和 Spring Boot 后端。系统支持干洗服务预约、商品商城、购物车、订单支付、附近门店选择、AI 智能客服、首页配置、轮播图配置等功能。

## 项目结构

```text
.
├── backend/          # Spring Boot 后端 API
├── frontend/         # 顾客客户端网页版
├── app/              # UniApp 微信小程序端
├── admin/            # 管理后台
├── database/         # MySQL 初始化和补丁 SQL
└── README.md
```

## 技术栈

| 模块 | 技术 |
| --- | --- |
| 后端 | Spring Boot 2.7、Spring Security、JWT、Spring Data JPA |
| 数据库 | MySQL 8.x、Redis 配置预留 |
| 顾客网页版 | Vue 3、Vite、TypeScript、Element Plus、Pinia |
| 管理后台 | Vue 3、Vite、TypeScript、Element Plus、ECharts |
| 小程序端 | UniApp、Vue 3、TypeScript、Pinia |
| AI 客服 | 本地知识库优先，未命中时可调用 OpenAI / 智谱 API |

## 核心功能

- 顾客端：首页轮播、干洗服务、商品商城、购物车、确认订单、我的订单、附近门店、AI 客服。
- 小程序端：首页、分类商城、干洗服务、购物车、确认订单、订单列表、个人中心、可拖拽 AI 客服入口。
- 管理后台：服务管理、商品管理、订单管理、用户管理、门店管理、评论管理、首页配置、系统设置。
- AI 知识库：预置干洗业务知识，支持价格、取送、售后、洗护周期等问答。
- 门店选择：支持从下单、购物车、确认订单页面跳转附近门店页，选择后实时回填。
- 首页轮播：使用本地三张主题轮播图，避免外链图片失效。

## 环境要求

| 软件 | 建议版本 |
| --- | --- |
| JDK | 17+ |
| Maven | 3.6+ |
| Node.js | 18+ |
| npm | 8+ |
| MySQL | 8.x |
| 微信开发者工具 | 调试小程序 |

## 数据库初始化

先创建数据库：

```sql
CREATE DATABASE IF NOT EXISTS dry_clean_mall
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

导入完整数据：

```bash
mysql -u root -p dry_clean_mall < database/dry_clean_mall.sql
```

如果只需要更新 AI 知识库或轮播图，可执行：

```bash
mysql -u root -p dry_clean_mall < database/ai_knowledge_patch.sql
mysql -u root -p dry_clean_mall < database/update_client_banners.sql
```

## 后端配置与启动

后端配置文件：

```text
backend/src/main/resources/application.yml
```

常用环境变量：

| 环境变量 | 说明 | 默认值 |
| --- | --- | --- |
| `DB_URL` | MySQL JDBC 地址 | 本地 `dry_clean_mall` |
| `DB_USERNAME` | MySQL 用户名 | `root` |
| `DB_PASSWORD` | MySQL 密码 | `20060128` |
| `JWT_SECRET` | JWT 签名密钥 | 开发默认值 |
| `OPENAI_API_KEY` | OpenAI API Key | 空 |
| `OPENAI_API_URL` | OpenAI 接口地址 | `https://api.openai.com/v1/responses` |
| `OPENAI_MODEL` | OpenAI 模型 | `gpt-5` |
| `ZHIPU_API_KEY` | 智谱 API Key | 空 |
| `ZHIPU_MODEL` | 智谱模型 | `glm-4-flash` |

启动后端：

```bash
cd backend
mvn spring-boot:run
```

接口地址：

```text
http://localhost:8080/api
```

## 顾客网页版

```bash
cd frontend
npm install
npm run dev
```

访问：

```text
http://localhost:5173
```

构建：

```bash
npm run build
```

## 管理后台

```bash
cd admin
npm install
npm run dev
```

访问：

```text
http://localhost:5174
```

构建：

```bash
npm run build
```

## 微信小程序端

```bash
cd app
npm install
npm run dev:mp-weixin
```

微信开发者工具打开：

```text
app/dist/dev/mp-weixin
```

构建发布：

```bash
npm run build:mp-weixin
```

发布目录：

```text
app/dist/build/mp-weixin
```

小程序请求地址配置在：

```text
app/src/config/index.ts
```

真机调试时，将后端地址从 `127.0.0.1` 或 `localhost` 改成电脑局域网 IP，并在微信开发者工具中勾选“不校验合法域名”。

## 测试账号

默认演示数据密码均为：

```text
123456
```

| 端 | 用户名 | 角色 |
| --- | --- | --- |
| 顾客端 | `zhangsan` | USER |
| 顾客端 | `lisi` | USER |
| 顾客端 | `wangwu` | USER |
| 管理后台 | `admin` | ADMIN |
| 管理后台 | `supperadmin` | SUPPERADMIN |

## AI 客服说明

AI 客服接口优先匹配数据库中的 `ai_knowledge` 知识库。知识库没有完全匹配时，会根据配置调用外部模型：

- OpenAI：配置 `OPENAI_API_KEY`
- 智谱：配置 `ZHIPU_API_KEY`

未配置外部 API Key 时，系统仍会返回本地知识库或兜底提示。

## 常见问题

| 问题 | 处理 |
| --- | --- |
| 后端 8080 端口占用 | 关闭占用进程，或修改 `server.port` |
| 前端请求失败 | 确认后端已启动，且 Vite 代理指向 `localhost:8080` |
| 小程序 502 / 请求不到后端 | 修改 `app/src/config/index.ts` 为可访问的电脑 IP |
| 首页轮播空白 | 执行 `database/update_client_banners.sql`，并刷新浏览器缓存 |
| AI 提示 API Key 未配置 | 设置 `OPENAI_API_KEY` 或 `ZHIPU_API_KEY` 后重启后端 |
| 图片不显示 | 检查后端 `uploads/` 目录和图片路径是否正确 |

## GitHub 提交说明

本项目已配置 `.gitignore`，默认不提交以下内容：

- `node_modules/`
- `dist/`
- `target/`
- `.env`
- 本地 IDE 配置
- 运行日志和上传目录

公开仓库中不要提交真实 API Key、数据库密码、JWT 生产密钥。开发时请使用环境变量或本地未提交配置文件。
