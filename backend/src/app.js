// Backend entry point (Node.js)
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const chatRoutes = require('./routes/chat');
const expressLayouts = require('express-ejs-layouts');

const app = express();
const PORT = process.env.PORT || 3000;

const adminRouter = require('./routes/admin');
const path = require('path');


// 设置模板引擎
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(expressLayouts);                 // 启用布局中间件
app.set('layout', 'layout');             // 指定默认布局文件（views/layout.ejs）

// 静态资源
app.use(express.static(path.join(__dirname, 'public')));

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 挂载后台管理路由（注意放在原有 /api 路由之前或之后，建议先于 chat 路由）
app.use('/admin', adminRouter);

app.use('/api/chat', chatRoutes);

app.listen(PORT, () => {
    console.log(`Backend running on http://localhost:${PORT}`);
});