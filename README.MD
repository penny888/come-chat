# 来聊吧 (Come Chat)

一个基于 RAG（检索增强生成）的全栈 AI 聊天应用，支持 Web 端和移动端，具备流式对话、知识库管理、会话历史等功能。

## 技术架构

```
come-chat/
├── .gitignore                        # Git 忽略规则
├── README.MD                         # 项目说明
│
├── backend/                          # Node.js 后端服务
│   ├── .env                          # 环境变量配置
│   ├── package.json                  # Node 依赖与脚本
│   ├── package-lock.json
│   ├── data/
│   │   └── app.db                    # SQLite 数据库文件
│   ├── src/
│   │   ├── app.js                    # Express 应用入口
│   │   ├── public/
│   │   │   └── admin.css             # 管理后台样式
│   │   ├── routes/
│   │   │   ├── chat.js               # 聊天 API（SSE 流式）
│   │   │   └── admin.js              # 知识库管理后台 API
│   │   ├── services/
│   │   │   ├── langchainService.js   # DeepSeek 对话 + RAG 逻辑
│   │   │   └── embeddingService      # 文本 Embedding 向量化
│   │   ├── utils/
│   │   │   ├── milvusClient.js       # Milvus 向量数据库客户端
│   │   │   └── sqliteDb.js           # SQLite 数据持久化
│   │   └── views/                    # EJS 模板（管理后台页面）
│   │       ├── layout.ejs            # 页面布局模板
│   │       └── admin/
│   │           ├── index.ejs         # 知识库管理主页
│   │           └── upload.ejs        # 文档上传页面
│   └── uploads/                      # 文件上传临时目录
│
├── web/                              # React + TypeScript 前端
│   ├── package.json                  # 前端依赖与脚本
│   ├── package-lock.json
│   ├── tsconfig.json                 # TypeScript 配置
│   ├── public/
│   │   ├── index.html                # HTML 入口
│   │   └── assets/
│   │       └── logo.png              # 应用 Logo
│   └── src/
│       ├── index.tsx                 # React 挂载入口
│       ├── App.tsx                   # 应用根组件
│       ├── components/
│       │   ├── Chat.tsx              # 聊天主组件
│       │   └── Chat.css              # 聊天组件样式
│       └── services/
│           └── api.ts                # 后端 API 服务层
│
└── mobile/                           # Flutter 移动端
    ├── pubspec.yaml                  # Flutter 项目配置
    ├── pubspec.lock
    ├── assets/
    │   └── fonts/
    │       ├── NotoSansSC-Regular.otf         # 中文字体
    │       └── NotoSansSymbols-Regular.ttf    # 符号字体
    └── lib/
        ├── main.dart                          # Flutter 入口
        ├── screens/
        │   └── chat_screen.dart               # 聊天页面
        └── services/
            └── api_service.dart               # 后端 API 服务层
```

## 核心功能

- **AI 流式对话** — 基于 DeepSeek 模型，支持 SSE 流式输出，打字机效果实时显示
- **RAG 知识库增强** — 上传文档（txt / pdf / docx）自动分块、向量化存入 Milvus，对话时可检索增强回答
- **多轮对话** — 自动维护会话上下文（最近 10 条历史），支持会话列表与历史回溯
- **管理后台** — Web 界面管理知识库，支持上传、查看、删除知识文档
- **多端支持** — React Web 端 + Flutter 移动端，统一的 SSE 流式交互体验
- **Markdown 渲染** — AI 回复支持 Markdown 格式渲染

## 环境依赖

| 组件 | 用途 |
|------|------|
| Node.js | 后端运行时 |
| Milvus | 向量数据库（存储知识库 embedding） |
| SQLite | 关系数据存储（用户、会话、消息） |
| DeepSeek API | 大语言模型对话 |
| OpenAI API (兼容) | 文本 Embedding 向量化 |
| Flutter SDK | 移动端构建 |

## 快速开始

### 1. 启动 Milvus

```bash
# 使用 Docker 启动 Milvus（需要至少 4GB 可用内存）
wget https://github.com/milvus-io/milvus/releases/download/v2.3.3/milvus-standalone-docker-compose.yml -O docker-compose.yml
docker-compose up -d
```

### 2. 配置后端

```bash
cd backend
npm install
```

创建 `backend/.env` 文件：

```env
# 后端运行端口
PORT=3100

# DeepSeek 大模型
DEEPSEEK_API_KEY=your_deepseek_api_key
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1

# OpenAI Embedding（或兼容接口）
OPENAI_API_KEY=your_openai_api_key
OPENAI_BASE_URL=https://api.openai.com/v1

# Milvus 向量数据库
MILVUS_ADDRESS=localhost:19530

# SQLite 路径
SQLITE_DB_PATH=./data/app.db

# JWT秘钥
JWT_SECRET=123456
```

### 3. 启动后端

```bash
npm start     # 默认端口 3100
# 或开发模式
npm run dev   # nodemon 热重载
```

管理后台访问：`http://localhost:3100/admin`

### 4. 启动 Web 前端

```bash
cd web
npm install
npm start     # 默认端口 3000
```

Web 端访问：`http://localhost:3000`

### 5. 启动 Flutter 移动端

```bash
cd mobile
flutter pub get
flutter run
```

> 移动端通过 `10.0.2.2:3100`（Android 模拟器）访问本机后端，实机调试需修改 `api_service.dart` 中的 `baseUrl`。

## API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/chat/stream` | 流式聊天（SSE），入参 `{ message, conversationId?, useRag? }` |
| GET | `/api/chat/conversations` | 获取当前用户所有会话 |
| GET | `/api/chat/history/:conversationId` | 获取指定会话的消息历史 |
| GET | `/admin` | 知识库管理页面 |
| POST | `/admin/upload` | 上传知识文档（multipart） |
| POST | `/admin/delete` | 删除知识条目 |

## 知识库工作流程

1. 通过管理后台上传 txt / pdf / docx 文档
2. 后端使用 LangChain `CharacterTextSplitter` 分块（chunkSize=1000, overlap=200）
3. 调用 OpenAI Embedding 接口为每个 chunk 生成 1536 维向量
4. 向量及原文存入 Milvus `knowledge_base` 集合
5. 用户开启"知识库增强"对话时，先对问题向量化，再在 Milvus 中相似检索 top-3 相关内容
6. 相关内容作为 System Prompt 注入，指导 DeepSeek 基于知识库回答

## 数据库表结构

### SQLite

| 表名 | 说明 |
|------|------|
| `users` | 用户表（id, email, password_hash） |
| `conversations` | 会话表（id, user_id, title, model） |
| `messages` | 消息表（id, conversation_id, role, content, tokens） |

### Milvus Collection: `knowledge_base`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | Int64 (主键, 自增) | 知识条目 ID |
| `content` | VarChar (65535) | 文本内容 |
| `embedding` | FloatVector (1536) | 文本向量 |
| `metadata` | JSON | 元信息（来源文件名等） |
| `created_at` | Int64 | 创建时间戳 |
