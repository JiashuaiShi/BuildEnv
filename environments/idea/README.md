# 多JDK版本开发环境

这是一个提供多个JDK版本(8/11/17)和IntelliJ IDEA开发工具的Docker容器环境，可以随时切换不同的JDK版本。

## 环境特点

- **JDK版本**: 
  - OpenJDK 8
  - OpenJDK 11
  - OpenJDK 17
- **操作系统**: Ubuntu 24.04
- **构建工具**: Maven, Gradle
- **开发工具**:
  - Git
  - Vim/Neovim
  - Zsh (Oh-My-Zsh + 常用插件)

## 使用方法

### 快速开始

1. **构建容器**:
   ```bash
   ./build.sh
   ```

2. **启动容器**:
   ```bash
   ./start.sh
   ```

3. **连接到容器**:
   ```bash
   ssh -p 28964 shijiashuai@localhost
   ```
   - 用户名: `shijiashuai`
   - 密码: `phoenix2024`

### JDK版本切换

在容器内部，可以使用以下命令快速切换JDK版本:

```bash
# 切换到JDK 8
jdk8

# 切换到JDK 11
jdk11

# 切换到JDK 17
jdk17

# 查看当前JDK版本和帮助信息
jdk
```

### 离线构建

如果您在网络受限环境工作，可以使用预下载资源的版本:

```bash
cd offline-build
./download_resources.sh
./build.sh
```

## 目录挂载

容器启动时会自动挂载以下数据目录:
- `/data`
- `/data1`
- `/data2`
- `/data-lush`
- `/data_test`
- `/mnt/nas1`
- `/data_melody`
- `/data-melody`

## 开发建议

1. 不同JDK版本支持不同的Java语言特性，开发时可根据项目需求选择合适版本
2. 建议使用Visual Studio Code的远程SSH扩展进行开发
3. 容器内已配置Git，可直接使用Git进行版本控制

## 故障排除

1. 如果构建失败，可尝试使用`--no-cache`选项:
   ```bash
   docker-compose build --no-cache
   ```

2. 如果网络环境受限，请使用`offline-build`目录中的构建方式

3. 如遇端口冲突，修改docker-compose.yaml中的端口映射 