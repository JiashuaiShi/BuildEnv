# Ubuntu 24.04 开发环境

这是一个基于 Ubuntu 24.04 的基础开发环境，适用于各类开发场景。

## 环境特点

- **操作系统**: Ubuntu 24.04 LTS
- **开发工具**:
  - Python 3
  - GCC/G++ 13
  - Clang/LLVM
  - Git
  - CMake, Ninja
- **辅助工具**:
  - Miniconda3
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
   ssh -p 28965 shijiashuai@localhost
   ```
   - 用户名: `shijiashuai`
   - 密码: `phoenix2024`

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

1. 这是一个通用环境，可根据项目需求安装额外的软件包
2. 建议通过SSH连接到容器，使用Visual Studio Code的远程SSH扩展进行开发
3. 容器内已配置Git，可直接使用Git进行版本控制

## 故障排除

1. 如果构建失败，可尝试使用`--no-cache`选项:
   ```bash
   docker-compose build --no-cache
   ```

2. 如果网络环境受限，请使用`offline-build`目录中的构建方式

3. 如遇端口冲突，修改docker-compose.yaml中的端口映射 