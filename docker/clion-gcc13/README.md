# Ubuntu 24.04 + CLion + GCC13 开发环境

这是一个为C/C++开发者量身定制的开发环境，基于Ubuntu 24.04，集成了CLion IDE和GCC 13编译器。

## 环境特点

- **操作系统**: Ubuntu 24.04 LTS
- **C/C++工具链**:
  - GCC/G++ 13 (支持C++20/23标准)
  - Clang/LLVM 最新版
  - CMake, Ninja
  - GDB, Valgrind
- **开发工具**:
  - Python 3
  - Git
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
   ssh -p 28963 shijiashuai@localhost
   ```
   - 用户名: `shijiashuai`
   - 密码: `phoenix2024`

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

## C++开发建议

1. 充分利用GCC 13的现代C++特性，包括C++20的协程、概念、范围等
2. 建议通过SSH连接到容器，使用CLion或Visual Studio Code的远程SSH扩展进行开发
3. 容器支持CMake和Ninja构建系统，可加速编译过程

## 故障排除

1. 如果构建失败，可尝试使用`--no-cache`选项:
   ```bash
   docker-compose build --no-cache
   ```

2. 如遇端口冲突，修改docker-compose.yaml中的端口映射 