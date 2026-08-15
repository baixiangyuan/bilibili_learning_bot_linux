# bilibili_learning_bot

> **B站 AI 学习互动机器人** — AI 自动刷视频、学知识、评论互动、私信回复、自我进化，内置 Web 管理面板，支持一键打包 Windows EXE。
>
> 版本: **3.1.3** | License: MIT | 项目文档: https://bxya.top/

## 维护约定

- 每次功能或 bug 修复都同步更新本 README 与 CHANGELOG。
- 每次修改前先在 `F:\bililearn` 创建源码小备份，目录名使用 `bililearn_YYYY_M_D说明` 格式。
- 每个备份目录必须包含 `更新内容.txt`，记录快照范围、变更内容、优点、已知问题和验证结果。
- 备份默认排除账号 Cookie、真实配置、Data、模型、二维码、运行日志和构建产物，避免泄露隐私。
- 每次任务完成后发送桌面/系统通知；通知只包含结果和验证状态，不包含 API Key、Cookie 或私信内容。

## 当前维护状态

- 长期记忆与 B 友画像已支持在网页端管理；检索命中的永久记忆和联系人兴趣/聊天风格会作为私聊、评论回复的受限上下文。
- 多模态已收敛为一个总开关，统一控制封面、评论图片和视频抽帧理解，并兼容旧配置字段。
- 主人分享增加“分享意愿”设置，仍受评分阈值、每日限额、冷却时间和行为审核约束。
- 登录页会区分“资料已同步”与“本地凭据待验证”，并显示可操作的状态读取错误；所有动态 Lucide 图标均使用当前依赖实际提供的通用图标。
- 当前版本为 `3.1.3`，已有 319 个自动化测试通过。
- 已发现的重点待修项：观看历史卡顿、停止机器人后学习实况残留、知识库封面补全不同步、私信视频上下文串用、移动端私聊溢出和完整日志刷新稳定性。
- 当前快照备份：`F:\bililearn\bililearn_2026_8_8第一个备份`。

---

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 📺 **智能视频浏览** | AI 驱动 B站推荐流浏览，自动判断内容价值（评分 / 收藏 / 投币 / 点赞） |
| 📚 **知识库系统** | 自动归档高质量视频，3 层分类 + 语义检索 + 复习回顾 |
| 💬 **评论互动** | 真实/模拟评论模式，AI 深度回复，支持图片分析 |
| 📩 **私信处理** | 自动回复粉丝私信，持久上下文 + 长期记忆，支持节奏控制 |
| 📡 **实时监听** | 独立监听引擎，只盯私信 + 评论实时 AI 回复，不刷视频不耗精力 |
| 🔔 **@通知响应** | 视频下评论 "@bot 总结这个视频"，自动识别并总结回复 |
| 🧬 **日记与自我进化** | 行为日志 + AI 自我反思 + 人格动态进化 |
| 🎙️ **ASR 语音识别** | 视频语音转文字（FunASR / Whisper，可选安装） |
| 🤖 **Agent 技能系统** | 自主规划目标 → 搜索 B站 → 看视频 → 总结知识，全自动闭环 |
| 🎓 **知识辅导** | AI 讲解 / 问答 / 二次创作 / 生成 HTML 学习卡片 |
| 🎨 **视频→网页** | 视频生成 PPT 风格 HTML，19 种视觉风格，支持 Claude 主题 |
| 📊 **思维导图 & Word 导出** | 视频一键导出 `.mindmap.html` 与 `.docx` 文档 |
| 🔍 **深度研习** | 长视频多章节深研，证据链式总结（`services/deep_dive.py`） |
| 🎯 **智能兴趣引擎** | 多维度评分 + 同义词 + 排除词 + 灵光一闪探索 + PsychoProfile 同步 |
| 😊 **AI 心情系统** | 动态心情影响互动风格，支持自定义 |
| 🏆 **干货点赞回顾** | 定期回顾收藏的干货视频，AI 复习（`services/like_review.py`） |
| 🔔 **本地提醒** | 桌面通知 + 待办提醒（`services/reminders.py`） |
| 🛡️ **安全审查** | 关键词过滤 + 政治敏感拦截 + 提示词注入防护 + 操作风控 |
| 🔄 **备用 API 降级** | 主 API 连续失败自动切换备用提供商 / 备用模型 |
| 🖥️ **Windows EXE** | 一键打包免 Python 运行（托盘 + 浏览器面板） |
| 🌓 **Web 面板** | Claude 设计风格，亮/暗双主题，仪表盘 / 机器人控制 / 配置 / 知识管理 |
| 🐳 **Docker 部署** | 支持 Docker / docker-compose 一键部署 |
| 📱 **Termux 支持** | Android 手机一键启动脚本 |

---

## 📊 v3.0.2 → v3.1.x 版本对比

| 维度 | v3.0.2 | v3.1.2+（当前 3.1.2） |
|------|--------|----------------------|
| **代码规模** | 77 个 Python 文件 / ~34k 行 | 113 个 Python 文件 / ~54k 行（+47%） |
| **Windows 桌面版** | ❌ 仅源码运行 | ✅ `desktop_app.py` 一键打包 EXE（托盘图标 + 自动开浏览器） |
| **数据目录** | 项目内 `Data/`（打包/升级易丢） | ✅ `%LOCALAPPDATA%\BiliLearn`（打包产物零隐私数据，升级不丢） |
| **Web 面板** | 基础控制页 | ✅ 仪表盘 / 机器人控制 / 实时监听 / 人格管理 / 知识辅导 / 深研 / 备份还原 |
| **人格管理** | 简单 prompt 配置 | ✅ Web 可视化多人格（创建 / 编辑 / 激活 / 删除），key 与显示名双匹配 |
| **HTML 渲染** | 各模块各自维护模板 | ✅ `services/html_renderer.py` 统一渲染（阅读页 / 幻灯片 / 导出） |
| **服务模块** | 12 个 | ✅ 32 个（新增深度研习、测验生成、思维导图、Word 导出、本地收藏、点赞回顾、提醒、RAG 问答、平台适配、代理配置、版本历史…） |
| **评论回复** | 基础回复 | ✅ 顶层/子回复路由修复、12006 失效处理、AI 选择失效 ID 跳过 |
| **监听引擎** | 基础轮询 | ✅ 上下文合并、超时跳过、`-509` 退避、网页日志可视化 |
| **开放平台桥接** | ❌ | ✅ `ob_bridge/`（开放平台鉴权、AB 测试、审计） |
| **备份与恢复** | 手动导出 | ✅ 分组备份（设置 / 记忆 / 知识 / 产物）+ 恢复 |
| **测试** | 43 个 pytest | ✅ 181 个 pytest（`319 passed` 全量发布验证） |
| **稳定性修复** | — | 人格持久化、Cookie 校验、风控、多实例锁、AI 降级冷却、上下文截断保护 |

> 详细演进见 [CHANGELOG.md](CHANGELOG.md)。

---

## 🧱 项目结构

```
├── main.py               # 🚀 主入口（CLI 交互菜单 + 自动化启动）
├── desktop_app.py        # 🖥️ Windows EXE 启动器（托盘 + 面板）
├── web_panel.py          # 🌐 Flask Web 管理面板（后端）
├── web_panel.html        # Web 面板模板（Claude 风格，亮暗双模式）
├── BiliLearn.spec        # 📦 PyInstaller 打包配置
├── build_windows_exe.bat # 📦 一键打包脚本（Windows）
│
├── api/                  # 🔌 B站 API 层（客户端 / 登录 / 字幕 / 节流）
├── brain/                # 🧠 核心大脑（Mixin 组合：主循环 / 视频理解 / AI 调用 / 会话）
├── cli/                  # 💻 命令行菜单
├── core/                 # ⚙️ 配置 / 全局变量 / 用户数据路径 / 恢复出厂
├── knowledge/            # 📚 知识库（分类 / 搜索 / 浏览 / 复习 / 自定义）
├── persona/              # 🎭 人格 + 心理画像引擎
├── security/             # 🛡️ 内容安全审查
├── services/             # 🔧 32 个服务（深研 / 测验 / 思维导图 / Word / 兴趣引擎 / RAG…）
├── ob_bridge/            # 🌉 开放平台桥接（鉴权 / AB 测试 / 审计）
├── xingye_bot/           # 🤖 扩展组件（LLM / 状态 / 记忆 / 进化 / ASR / 网格帧）
├── utils/                # 🛠 通用工具（托盘 / 启动器 / 存储 / 锁）
├── templates/claude/     # 🎨 Claude 设计系统模板 + 7 个参考页
├── tests/                # 🧪 181 个 pytest 测试
├── app-icons/            # 应用图标
└── dev_refs/             # 📖 二次开发参考文档
```

---

## 🚀 快速开始

### 1️⃣ 安装依赖

```bash
pip install -r requirements.txt

# 推荐安装 ffmpeg（视频帧提取）
# apt install ffmpeg        # Linux
# pkg install ffmpeg        # Termux
```

> ⚠️ B站 API 包名是 **`bilibili-api-python`**（不是 `bilibili-api`）。若之前装过旧包：
> ```bash
> pip uninstall bilibili-api -y
> ```

### 2️⃣ 配置

```bash
cp config.example.json Data/config.json   # 源码运行
# 编辑填入 API Key（统一 API 或任意 OpenAI 兼容端点）
```

> Web/EXE 版会自动在 `%LOCALAPPDATA%\BiliLearn` 创建数据目录，无需手动复制。

### 3️⃣ 启动

| 方式 | 命令 |
|------|------|
| **CLI 交互菜单** | `python main.py` |
| **Web 管理面板** | `python web_panel.py` → http://localhost:18083 |
| **Windows EXE** | 运行 `BiliLearn Web.exe`（自动开浏览器 + 托盘） |
| **Docker** | `docker-compose up -d` |
| **Termux** | `bash start.sh` |

### 4️⃣ 首次使用

1. 网页面板「B站登录」扫码登录
2. 「机器人控制」→ 启动机器人（自动刷视频）
3. 「人格管理」配置 AI 人格
4. 或 CLI：`python main.py` → 按 `3` 登录 → 按 `1` 启动

---

## 📦 Windows EXE 打包教程

项目已内置完整的 PyInstaller 配置，**无需手写命令行**：

### 前置条件

```bash
pip install pyinstaller
```

### 一键打包

双击运行（或命令行执行）：

```bat
build_windows_exe.bat
```

等价命令：

```bash
python -m PyInstaller --noconfirm --clean BiliLearn.spec
```

产物：`dist/BiliLearn Web/BiliLearn Web.exe`（绿色免安装，复制整个文件夹即可分发）。

### spec 配置要点（源码可抄）

`BiliLearn.spec` 里解决了以下打包坑：

| 坑 | 解法 |
|----|------|
| **入口选谁** | 入口是 `desktop_app.py`（不是 `main.py` / `web_panel.py`）：它负责托盘、自动开浏览器，并按需以子模式拉起 bot / monitor / standby |
| **数据文件** | `datas` 显式带上 `web_panel.html`、`config.example.json`、`VERSION`、`app-icons/`、`templates/` |
| **Flask 版本元数据** | `copy_metadata('flask') + copy_metadata('werkzeug')`，否则 Python 3.13 下 Flask 启动报错 |
| **bilibili-api 动态导入** | `hiddenimports` 显式声明 `bilibili_api.clients.HTTPXClient` 等，否则冻结版二维码登录/视频分析失败 |
| **托盘** | `pystray._win32` 显式 hiddenimport，否则窗口版无托盘 |
| **子进程模块** | `main`、`brain.monitor`、`brain.standby` 显式 hiddenimport，供 desktop_app 以 `runpy` 拉起 |
| **排除 ML 巨物** | `excludes` 排除 torch / transformers / onnxruntime / faiss 等可选依赖，否则打包体积 2GB+ 且启动必崩 |
| **窗口模式** | `console=False`（无黑窗）；子进程日志由面板捕获写入 `%LOCALAPPDATA%\BiliLearn\Data` |

### 打包后常见报错速查

| 报错 | 原因与解法 |
|------|-----------|
| `cannot import name '_imaging' from 'PIL'` | Pillow 与解释器版本不匹配（cp312 装进 3.13）。`pip uninstall Pillow && pip install Pillow==12.1.0` |
| `ModuleNotFoundError: bilibili_api.clients...` | spec 缺 hiddenimports，抄上面的列表 |
| 启动后没有托盘 | 缺 `pystray._win32` hiddenimport |
| 双击闪退 | 先命令行运行 `BiliLearn Web.exe` 看报错；或检查是否从 `dist/BiliLearn Web/` 整个目录运行（不能只拷 exe） |
| 子进程中文日志乱码/崩溃 | desktop_app 已对 stdout/stderr 做 `utf-8 reconfigure`，勿删 |

---

## 📝 更新日志

### 2026-08-11 更新（星野助手）
- **启动自动检测更新**：每次打开面板自动检查 gengxin.bxya.app 新版本，弹窗提供「跳过当前版本」「下载新版本」两个选项；跳过后的版本不再自动提醒（可手动取消跳过）。后端新增 `POST /api/update/skip`、`POST /api/update/unskip`，跳过记录存 `Data/skipped_version.json`。
- **兴趣偏好分区稳定**：确认后端兴趣数据完整保留、前端正常渲染（含优先级/同义词/AI建议来源标签）。
- **导出目录回归项目内**：源码版运行下 KnowledgeBase/MindMaps/html_exports/Word/highlights 默认生成在项目目录内（frozen 打包版仍在用户目录）。

### v3.1.3（2026-08-07）

**✨ 新增功能**
- **仪表盘图表点击放大**：资源趋势 / 占用对比 / 资源明细 三个图表支持点击弹出大屏查看
- **检查更新**：关于分区新增"检查更新"按钮，连接 `https://gengxin.bxya.app/v{版本号}` 检查新版本，智能识别"未发布/开发版"（服务器无当前版本登记时不误报更新），有更新时展示更新内容并跳转下载
- **项目介绍页**：关于分区新增「查看本项目介绍」按钮，一键打开精美的项目介绍页面（`project_intro.html`，随项目附带，版本号自动同步）
- **手机端主题切换**：移动端底部 Tab 栏新增 深色/浅色 一键切换按钮（原主题切换藏在侧边栏底部，手机上难以发现）
- **新手教程大改版**：从 4 步扩展为 8 步完整导览（配置 AI → 兴趣偏好 → 审核互动 → 启动机器人 → 实时监听 → 私聊管理 → 知识库 → 思维导图），每步带分区图标与详细说明

**🎨 动画与体验优化**
- 面板整体引入动画库（抄自项目介绍页）：页面切换淡入上浮、仪表盘统计卡弹跳入场
- 实时监听 / 完整日志刷新按钮点击时旋转加载动画，操作反馈更直观

**🐛 Bug 修复**
- 私聊黑名单从独立行移回「系统」折叠分组内（按用户要求归位）
- 手机端私聊聊天记录溢出屏幕、无法滑动：聊天区域改为自适应宽度，气泡最大宽度放宽至 80%，滚动区域修复
- 移除系统仪表盘误加的 B站账号大头照卡片（账号信息仅保留在 B站登录分区）

## 📝 更新日志（2026-08-07 追加）

### v3.1.3 · 第二轮优化（2026-08-07）

**✨ Agent 深度增强（Web Agent · 深度查探）**
- 新增 `do_share` 转发分享工具、`triple_action` 伪三连工具（点赞+投币+收藏）
- Agent 提示词注入主动互动能力：可主动点赞/投币/收藏/关注UP主/转发，受功能开关控制

**🐛 私信 AI 答非所问修复**
- 私信发纯视频链接时现会强制读取该视频内容，不再误走视频搜索谈论其他视频

**🎨 学习实况优化**
- 未启动机器人时显示醒目空状态 + 去启动按钮
- 视频新增「分数 + 是否通过」判定显示

**🛠 思维导图 / 知识辅导**
- 新增「补全封面资料」按钮，一键拉取缺失封面（复用观看历史机制）

**🔧 图表修复**
- 仪表盘图表点击放大（修复 Chart.js 实例克隆报错）

---

## 📝 更新日志（2026-08-10 追加）

### v3.1.3 · 第三轮优化（2026-08-10）

**✨ 新增功能**
- **视频转网页升级**：① 视频来源支持选择（手动输入 / 观看历史 / 稍后再看 / 知识库 / 本地收藏夹）② 新增「底部水印」开关（默认开启：bilibili_learning_bot 视频学习助手）③ 预览页支持键盘 ←/→ 切换上/下一页
- **思维导图**：新增「下载选中」按钮，一键下载思维导图为 HTML 文件
- **知识辅导**：加载选中文件后自动下滑到 AI 辅导对话区
- **语言系统完善**：切换语言时侧边栏分区名即时翻译（中/英），存储于本地
- **关于页美化**：信息卡带图标 + 悬停动效；「查看本项目介绍」的暗色/亮色与主面板同步

**🐛 修复与体验**
- **ASR 面板**：补全「选择 FFmpeg」「选择模型位置」「停止请求」「删除模型」四个缺失按钮函数；下载前检测本地模型，已存在时弹出确认不再重复下载；运行中/有模型时按钮状态自动启用
- **全局动画**：移除页面切换的全局淡入动画（改用卡片分区逐个弹出），解决卡顿
- 主题/语言按钮图标统一 18px，视觉对齐

**✅ 质量**
- 修复 3 个过时测试断言（安全关键词后端化、Agent 占位文案），**319 测试全过**

---

## 🧪 测试

```bash
python -m pytest -q          # 全部测试
python -m pytest tests/test_web_personas_api.py -q   # 单模块
```

发布前验证基线：**319 passed**。

---

## ❓ 常见问题（FAQ）

**Q: 数据存在哪里？**
源码版：项目根 `Data/`；Web/EXE 版：`%LOCALAPPDATA%\BiliLearn`（Cookie、API Key、知识库、二维码均只在本机，打包产物不含任何隐私数据）。

**Q: 机器人启动后立刻退出，日志报 `ImportError`？**
检查是否用了干净的 Python 环境。若 `PYTHONPATH` 指向了其他 Python 的 site-packages（例如安装了多个 Python），`import PIL` 可能加载到版本不匹配的 Pillow。运行前 `echo %PYTHONPATH%`，为空最稳妥。

**Q: AI 调用报 `'ascii' codec can't encode...`？**
检查 `config.json` 的 `api.vision_api_key` / `unified_api_key` 是否被写成了 `"[已隐藏]"` 之类占位符（导出配置脱敏后勿直接回写）。把该字段清空会回退到 `unified_api_key`。

**Q: 人格保存提示「不存在」？**
旧版数据中人格存储键与显示名不一致导致。3.1.2+ 已支持 key/显示名双匹配；若仍出现，重启面板加载新代码，或删除 `Data/web_personas.json` 让其从 `personas.json` 重新迁移。

**Q: 导出的配置怎么没有 Cookie 和 API Key？**
导出分为两种模式：**脱敏导出**（默认，API Key / Cookie 替换为 `[已隐藏]`，可安全分享给他人）和**完整导出**（含真实 Key 与登录 Cookie，仅限自己迁移备份，文件名带 `_full` 后缀）。网页端导出时会询问选择，CLI 菜单输入 `f` 选完整导出。完整导出导入新机器后登录态与 AI 配置直接可用。

**Q: 导入别人的配置备份后 AI 全挂，报 `'ascii' codec can't encode`？**
备份导出时 API Key / Cookie 会脱敏为 `[已隐藏]`，老版本直接导入会用占位符覆盖真实配置。3.1.2 正式版已修复：导入时自动过滤 `[已隐藏]`（有现有值则保留，否则删除该字段，需重新填写）。已中招的用户请手动编辑 `%LOCALAPPDATA%\BiliLearn\Data\config.json`，把 `unified_api_key` / `vision_api_key` 的 `[已隐藏]` 换成真实 Key。

**Q: 端口被占用？**
默认 18083；被占用时自动顺延。也可 `set WEB_PORT=xxxx && python web_panel.py`。

---

## ⚠️ 免责声明（叠甲区，认真看）

> 本项目作者深知"工具无罪、乱用有责"，以下免责声明**有多层就叠几层**，请逐条阅读：

1. **非官方出品**：本项目与哔哩哔哩（B 站）官方**没有任何关系**，非官方发布，B 站不背书、不负责。所有商标、名称归其各自所有者所有。
2. **仅限个人学习交流**：本项目仅供学习 HTTP / 数据处理 / AI 应用等技术的**个人学习用途**。**禁止**任何形式的商业用途、牟利行为、大规模批量爬取、攻击或滥用 B 站服务。
3. **法律风险自负**：B 站接口及服务条款可能随时变更，且 B 站已对同类逆向项目（如 bilibili-api）采取过法律行动。本项目基于公开接口实现，**不保证长期可用**，因使用本项目导致的任何纠纷、封号、法律责任均由使用者自行承担。
4. **账号安全**：`SESSDATA` / Cookie 是 B 站账号的**最高权限凭证**，本项目仅将其保存在你本机用户目录。**严禁**公开分享扫码二维码截图、auth.json 或 Cookie 内容，泄露等于把账号交给别人。
5. **内容版权**：提取的字幕、弹幕、评论、封面等内容的版权归原作者与 B 站所有，仅限个人阅读学习，**请勿**转载、二次分发、商用。
6. **稳定性与可用性**：本项目按"现状"提供，不提供任何明示或默示的保证。B 站改版、风控、网络环境等因素都可能使其失效；接口失效时按 README 指引重新扫码或自行修复，**作者不承诺修复时间**。
7. **不构成建议**：本项目产出的任何内容均不构成投资、理财、法律或其他专业建议；引用他人内容不代表赞同其观点。
8. **风险自担条款**：使用即视为同意以上全部条款。如果你所在地区或你的使用场景不允许此类工具，请**立即停止使用并删除本项目**。

**看视频一时爽，一直看一直爽 🫡**

---

## 📄 License

[MIT](LICENSE) © xiaoyaya191

## 2026-08-08 maintenance notes

- Library pages keep the 30-item default, use lazy/async cover loading, and avoid entry animations for large collections.
- Stopped bots no longer expose a stale video in Learning Live; video cards show score and pass status consistently.
- Knowledge cover enrichment now refreshes the returned file list after fetching metadata.
- Full-log refresh and Live refresh use explicit button elements instead of the browser-global `event`; mobile DM layout uses the actual `.dm-side` class.
- Private-message video inspection accepts an explicit message-level related BV when available, before falling back to conversation context.
- Verification: `python -m compileall -q -f .`, `pytest -q --disable-warnings --maxfail=20` -> `319 passed`; live `/api/health` returned version `3.1.3`.

## 2026-08-09 storage and knowledge export

- The About page shows the active user-data root and the locations for runtime data, knowledge, highlights, HTML, mind maps, documents, and QR codes. A new path can be persisted with optional non-destructive migration; restart the panel to apply it.
- Storage exports reuse the existing sanitized group backup API. API keys, cookies, and private messages are not included in the safe export.
- Individual knowledge notes can be exported as `md`, `txt`, `json`, or a local PNG. PNG export supports a local background image and a local font path. No image-generation API key is stored by this feature.
- The Agent recognizes explicit BV-based like, favorite, coin, and pseudo-triple requests, then routes every action through existing owner checks, feature switches, coin policy, dedupe, and review rules.

## 2026-08-09 AI quota email alerts

- Configure SMTP mail alerts in `配置编辑 -> AI 接入 -> AI 额度与邮件提醒`. The SMTP password is encrypted in local user data and is never returned by the Web API, shown in the page, or written to logs.
- A provider response indicating HTTP 402, insufficient balance, insufficient quota, or quota exceeded triggers an asynchronous email alert with a persisted cooldown. It reuses the existing critical-AI-failure path that stops the bot.
- The optional spend threshold uses only the locally recorded `web_costs.json` total. It is not represented as a live provider balance because OpenAI-compatible gateways do not have a reliable common balance endpoint.

## 2026-08-09 dashboard and smart safety polish

- Dashboard runtime cards use compact metric spacing, and Learning Live no longer reserves large empty subtitle, recent-video, or log panels while the bot is idle.
- `系统设置 -> 行为 -> 安全` exposes one Smart Safety System switch. Existing backend word rules, prompt-injection checks, and incoming/outgoing/context checks remain available, but their rule text is not displayed or returned by the panel API.

## 2026-08-09 ASR and Agent workspaces

- `ASR 语音识别` is now the single configuration page for ASR enablement, engine choice, Whisper model, device, FFmpeg, VAD, punctuation, model download location, and real download/load status.
- `Agent 工作台` centralizes task settings, reusable Skills, and MCP service registration. MCP entries are stored as endpoint metadata only; registering an entry does not contact it or bypass the existing tool/action safeguards.
- A BV can be summarized into a reusable video or interaction Skill. The operation first retrieves public metadata and asks the configured AI to write a bounded workflow; it does not claim playback or execute account interactions.

## 2026-08-09 visual, email, and log controls

- Visual-note grids retain their timestamped 3x3 layout and now remove near-identical consecutive frames using a lightweight grayscale fingerprint. The configured vision model receives the grids for evidence-based image understanding.
- Full logs can be exported in TXT or JSON for the selected source. Exports use the same redaction as the log viewer.
- Email alerts have an optional `邮件发送前进入审核` switch, disabled by default. In review mode an alert is saved as pending instead of connecting to SMTP.

## 2026-08-09 social workspaces and reminder controls

- `稍后再看` reads the logged-in Bilibili account's list and supports explicit add, remove, and clear operations. These account writes are controlled by the dedicated feature switch.
- `待办与提醒` exposes the same local reminder store used by AI-recognized private-message reminders, so manual and AI-created reminders appear together.
- `动态发布中心` stores local drafts first. The publish switch is off by default; when enabled, a publish request enters the existing AI behavior review queue by default rather than posting immediately.
- Feature switches now separately cover active private messages, watch later, owner sharing, dynamic drafts, and dynamic publishing.
- Storage settings include an `打开位置` action for predefined user-data directories. It never accepts an arbitrary path or exposes secrets.
- Generated private messages, mention replies, and owner shares request Bilibili bracket emotes instead of Unicode emoji.

## 2026-08-09 reliability follow-up

- Comment failures indicating that the target page has comments disabled (`12002`) are terminal and are no longer retried by the mention listener.
- Private-message contacts resolve Bilibili nickname and avatar in a dedicated event loop, avoiding the previous un-awaited coroutine fallback to placeholder names.
- Knowledge-file listings recover a BV identifier from legacy filenames when front matter is missing, allowing those cards to reuse the real public cover cache.
- All refresh buttons with a refresh icon now provide immediate rotation feedback. Small-screen DM layout uses a narrow contact rail and overflow-safe chat bubbles.
- `deploy_termux.sh` provides an interactive Termux deployment flow: environment check, deploy confirmation, explicit `我同意` acknowledgement, package setup, and local web-panel startup.


### 2026-08-11 细查修复（星野助手）
- **侧边栏重复菜单修复**：`mem`（记忆知识库）在语言翻译表 `_I18N` 中被错误标记为"长期记忆与 B 友画像"，导致侧边栏出现两个同名项。已修正为"记忆知识库"并补充 `memory-manage` 键。
- **评论空回复保护**：AI 未生成有效正文时不再发送只有签名的空回复（`brain/comment.py` 增加空内容拦截）。
- **评论回复一键三连 aid 兜底**：通知/艾特来源的评论只带 aid 不带 bvid，导致三连被跳过。已支持 aid 兜底构造 Video 对象，修复"回复评论不三连"。


### 2026-08-11 细查3（星野助手）
- **修复：视频转网页"本地收藏夹"来源加载失败（405）**：后端 `/api/favorites/items` 只有 POST/DELETE 没有 GET，而 v2w 来源选择调用了 GET → 405。已补 GET 返回扁平收藏项列表（bvid/title/up_name），实测 34 项正常返回。


### 2026-08-11 细查4（星野助手）
- **系统性回归审计**：浏览器实测全部 35 个分区导航零 JS 错误；前端 139 个 API 调用与后端契约逐一核对（实测返回键匹配）；API 方法契约（GET/POST/DELETE）全部正确；危险操作（清空/删除/重置）全部有确认框；时间计算逻辑正确。未发现新的活跃 bug。


### 2026-08-12 功能开关+动态自动发布（星嘢）
- **功能开关扩展**：新增 `enable_asr`（ASR语音识别）、`enable_monitor`（实时监听）开关，默认关闭。共 14 个开关。
- **动态发布中心增强**：新增「自动发布设置」面板（启用开关、每天发布时段 start/end hour、每日最少/最多发布数、内容来源多选：私信灵感/回复的评论/看过的视频/最近发生的事、自定义提示词）；新增「测试发动态」功能（真实发布）。
- **修复**：`social_center.publish_dynamic_draft` 和新增的 `publish_test_dynamic` 里对同步函数 `send_dynamic` 错误使用 `run_async` 导致的 "a coroutine was expected" 500 报错（动态实际已发布但接口报错）。


### 2026-08-12 修复好奇心深度搜索 NameError（星嘢）
- `brain/_brain_curiosity.py` 运行期报 `name 'SYSTEM_PROMPT_CURIOSITY_DIVE' is not defined`（好奇心深度搜索决策时炸）。
- 根因：`brain/_mixin_imports.py` 从 `api.subtitles` 导入 SYSTEM_PROMPT 常量组时漏加了后来新增的 `SYSTEM_PROMPT_CURIOSITY_DIVE`。
- 修复：一行，补齐 import。干净环境验证可导入，全量 327 测试通过。


### 2026-08-12 修复面板日志刷屏与恢复码失同步（星嘢）
- **现象**：面板日志页反复出现 `[Zen] 已就绪 + [Web] Panel started` + `面板使用一次性恢复码登录`，且用户用恢复码文件登录报"用户名或密码错误"。
- **根因排查**：① 面板进程当天被反复启动 9 次（调试/多实例并存）；② 每次恢复码登录都会轮换恢复码，多实例并发写 config/文件导致**恢复码文件与 config 哈希失同步**（文件 E790-9886-... 与 config 不匹配）→ 用文件里的旧码登录必然失败。
- **修复**：重新生成恢复码并**同时**写入 config.json + 恢复码文件，保证两者一致；确认项目哈希格式为 `$sha256$<hex盐>$<hex哈希>`（非 base64）。
- **附带发现**：Windows 事件日志有 4 次 python.exe 因 pyarrow 24.0.0 (arrow.dll) 段错误崩溃记录，属于环境依赖问题，当前面板未加载该库。


### 2026-08-12 三修：v2w 水印崩溃 / ASR 反复下载 / 死代码清理（星嘢）
- 🔴 **v2w 视频转网页必崩修复**：`services/video_to_ppt.py generate_ppt_from_bvid` 签名补 `watermark: bool = True` 参数（函数体 @2044 引用它但签名缺失 → NameError；web_panel.py 调用传参 → TypeError）。影响面：v2w 视频转网页、多格式导出 PPT。所有调用点兼容（默认 True）。
- 🟡 **ASR 反复下载修复**：`xingye_bot/asr_engine.py _get_model_dir` 配置分支补 `os.makedirs(..., exist_ok=True)`（此前配置了 funasr_model_dir 时不建目录 → 判定"模型未下载" → 反复下载 2GB）。
- 🟢 **死代码清理**：web_panel.html 删除 `renderInterestList`/`renderInterestExclusions` 的旧版重复定义（各 2 个中删掉前面的死代码，共 2374 字符），保留新版。


### 2026-08-12 CLI 与网页端同步：4 个新菜单项 + 版本号修正（星嘢）
- **版本号修正**：CLI 主菜单 v3.1.2 → v3.1.3（与 VERSION 文件一致）。
- **新增 4 个菜单项**（复用后端模块，零后端改动）：
  - `WL` 📌 稍后再看管理：查看列表/添加BV/移除BV/清空（services.social_center，走 B站 API 需登录）
  - `RM` 📝 待办与提醒：列表/添加/删除（services.reminders，本地 JSON）
  - `SW` 🎛️ 功能开关：14 项开关查看/切换（与网页端共用 config interaction 段，默认值完全对齐）
  - `WH` 📜 观看历史：本地 history_videos.json 前 50 条展示
- 跳过项：Agent 工作台（CLI 已有 J 学习工具 Agent）、学习实况（CLI 有日志）、仪表盘（终端交互有配置状态）——均为查看型，CLI 有替代。
- 测试：327 passed；CLI 交互实测（开关切换/待办列表/观看历史 76 条）；配置已还原。


### 2026-08-12 批量修 bug（10 项，星野）
- 🐛 **私聊消息不同步修复**：`private_message_log.json` 多进程覆盖（监听/主循环/面板 4 实例各持内存快照整体写回互相冲掉，实测丢 18 条）。`_save_log` 改跨进程安全合并（写前重读磁盘+按 msg_id 去重+processed 取并集）；补 3 个漏记路径（黑名单/超时/无需回复也写 log）；面板 `/api/dm/contacts`+`/api/dm/history` 双源合并（log + context_db 兜底）。
- 🐛 **动态评论不回复修复**：`_reply_notification_to_comment` business 白名单加 动态/dynamic；`reply_to_comment` 按 resource_type 用 `CommentResourceType.DYNAMIC(17)`（原硬编码 VIDEO）；动态评论跳过三连。
- 🐛 **私信进度标题错乱修复**：`_shared_video_title` 优先用户消息《》/【】标题，不再从整段历史取最后一个《》；兜底用 BV 号查真实标题。
- 🔗 **长期记忆与 B 友画像两套系统互通**：面板 permanent-memory/relationships API 合并 `PrivateContextDB._memories/_profiles`（原来面板空、AI 有数据完全脱节）；AI 私信 prompt 注入 `MemoryBank` 永久记忆。
- 📜 **动态发布日志**：`social_center` 发布（草稿+测试）写 `dynamic_publish_log.json`；面板新增 `/api/dynamic-publish-log` + 前端"发布记录"区块。
- 🛡️ **AI 行为审核补全**：测试发布动态也接入审核流（原仅草稿发布走审核）；执行器支持 test_text。
- 💬 **主动聊天增强**：`target_mode: owner`（只找主人）；允许聊天时段（active_hours）；触发概率/冷却/上限面板可配；时间感知注入（当前时间+星期+时段+距上次互动）。
- 🎨 **私聊分区外观设置**：外观设置按钮（文字色/对方气泡色/AI气泡色/AI文字色/背景图 URL），localStorage 存，仅本分区生效。
- 🚫 **黑名单升级**：默认拉黑哔哩哔哩智能机(12076317)；黑名单列表带头像+名字+主页跳转+逐行动画。
- ✨ **动画与头像**：聊天记录淡入动画、黑名单行动画；头像 URL 加 @240w_240h_1c.webp 缩略参数 + lazy 加载。
- ✅ 全量 327 测试通过；面板已重启。


### 2026-08-12 自查修复 4 个新 bug（星野）
- 🐛 **主动聊天 custom_prompt NameError**：`_compose_active_chat` 引用 `active_cfg` 但函数内未定义（AST 签名审计抓到）→ 函数内补 `active_cfg = config.get("active_chat", {})`。
- 🐛 **动态 @提及回复类型缺失**：monitor.py `reply_target` 没传 `resource_type`，动态 @提及评论会被当视频回复（type 错）→ 按 business 补 `resource_type: dynamic/video`。
- 🐛 **外观设置重置不生效**：`dmStyleApply({})` 空对象不清除旧的内联 CSS 变量 → 改为先 `removeProperty` 全部再按需设置。
- 🐛 **动态发布日志序列化崩溃**：B站原始响应可能含不可 JSON 序列化对象，整条日志丢失 → `_append_publish_log` 逐字段序列化校验，非序列化转 str 截断。
- 🔍 审计确认无问题项：API 方法契约 259 调用全匹配、跨进程日志合并实测不丢消息（A/B/C 三进程模拟）、认主人机制已存在（build_relationship_block）、前端 8 script 块 node --check 全过、compileall 全过、327 测试通过。


### 2026-08-12 日志格式统一：显示名字 + UID（星野）
- 用户需求：日志里不只显示 UID，还要显示对方名字。
- 统一格式：`@名字 (UID:123456)`，三个模块全部覆盖：
  - `brain/comment.py`：13 处评论日志（`@user` → `@名字 (UID:xxx)`，含 get 式与索引式，索引式改 get 兜底防 KeyError）
  - `brain/private_msg.py`：28 处私信日志（黑名单/白名单/接收/图片/合并/AI处理/发送全链路，`sender_name or talker_id` 名字优先）
  - `brain/monitor.py`：3 处 @提及日志（字幕获取/投递放弃/收到通知）
- 验证：compileall 全过、327 测试通过、面板重启（PID 55524）、日志格式检查 0 遗漏。


### 2026-08-12 日志加固 + 自查 2 项小修复（星野）
- 🔒 monitor.py `notification.get('user')` 补默认值（防显示 @None）；`notification['user']` 索引式改 get（防 KeyError）。
- 🔍 自查确认无问题：`_save_log` 三处漏记路径均经 `_mark_processed` 落盘（黑名单/超时/无需回复）；`_compose_active_chat` 的 `active_cfg` 引用安全（star import 提供 `config`）；`get_chat_target` 返回 int uid 与 `_user_key` str 兼容；`_dm_merged_history` 双源去重健壮。


### 2026-08-13 私信日志彻底并发修复 + 用户提示词唯一驱动（星野）
- 🐛 **私聊消息不同步最终治本**：`PrivateMessageManager._save_log()` 在已有“写前重读、按 msg_id 合并、原子替换”基础上，新增 Windows 跨进程 `msvcrt.locking` 锁（`private_message_log.json.lock`）。锁覆盖整个“重读 → 合并 → 写临时文件 → `os.replace`”临界区，两个实例同一时刻保存也不会都基于旧快照互相覆盖。
- ✅ 并发实测：启动两个独立 Python 进程同时保存 `base/msg-A/msg-B` 三条记录，最终 history 与 processed_msg_ids 均完整保留，无丢条。
- ✅ 漏记路径复核：黑名单、AI 超时、AI 判断无需回复均写状态记录，之后经 `_mark_message_bundle_processed → _mark_processed → _save_log` 落盘；面板继续以 log + context_db 双源合并显示历史。
- 🐛 **提示词被内置风格覆盖**：私信、评论、主动私信、弹幕及 xingye_bot 的评论/动态草稿原先硬编码“友好轻松、固定字数、必须表情、B站风格、固定默认人格”等内容指令，可能压过用户设定。
  - 现在所有用户可见的私信、评论、主动私信、弹幕与动态草稿均以用户的 `system_prompt/style/rules/自定义模板` 为唯一内容和表达来源。
  - 仅保留不可替代的安全与事实协议：防提示词注入、不得伪造工具/平台操作事实、外部材料不覆盖用户提示词、输出格式协议。
  - 空的评论/动态模板不再暗中回落到内置文案，而是明确提示先填写用户模板；安全拦截私信不再发送内置话术，只记录 blocked 状态并跳过。
  - 默认人格、默认 style、默认动态/评论模板均置空，避免新配置被隐藏的预设人设驱动。
- 验证：7 个改动模块 `py_compile` 全过；空人格 `build_prompt_block()` 实测返回空；内置内容指令清扫断言通过；全量 **327 passed**；面板已重启（PID 42144），health/私聊联系人/历史/长期记忆 API 全部 200。
