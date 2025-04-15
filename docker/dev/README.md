# 统一开发环境

这是一个集成了C++、Java和Python的统一开发环境，专为个人开发者设计，以简化多语言项目的开发流程。

## 功能特点

### C++开发环境
- **编译器**: GCC-13, Clang
- **构建工具**: CMake, Ninja, Make, Autotools
- **调试工具**: GDB, Valgrind
- **C++标准**: 支持C++11/14/17/20

### Java开发环境
- **JDK版本**: OpenJDK 8, 11, 17（可动态切换）
- **构建工具**: Maven, Gradle
- **版本切换**: 通过命令`jdk8`, `jdk11`, `jdk17`快速切换

### Python开发环境
- **Python 3**: 内置pip和venv

### 通用工具
- **版本控制**: Git
- **Shell环境**: Zsh + Oh-My-Zsh（配置了常用插件）
- **编辑器**: Vim, Neovim
- **终端工具**: tmux, htop

## 快速开始

### 1. 构建容器

```bash
./build.sh
```

构建过程可能需要一些时间，因为需要安装多种开发工具和环境。

### 2. 启动容器

```bash
./start.sh
```

### 3. 连接到容器

通过SSH连接到容器:
- **主机**: localhost
- **端口**: 28965
- **用户**: shijiashuai
- **密码**: phoenix2024

```bash
ssh -p 28965 shijiashuai@localhost
```

或者使用CLI工具:

```bash
./dev-cli.sh ssh
```

## 便捷CLI工具

提供了一个便捷的命令行工具用于管理容器:

```bash
./dev-cli.sh [命令]
```

可用命令:
- `build` - 构建容器
- `start` - 启动容器
- `stop` - 停止容器
- `restart` - 重启容器
- `ssh` - SSH连接到容器
- `status` - 查看容器状态
- `logs` - 查看容器日志
- `clean` - 清理容器和镜像
- `exec` - 在容器中执行命令
- `help` - 显示帮助信息

示例:
```bash
# 启动容器
./dev-cli.sh start

# 查看容器状态
./dev-cli.sh status

# 在容器中执行命令
./dev-cli.sh exec "g++ --version"
```

## JDK版本切换

在容器内部，你可以使用以下命令切换Java版本:

```bash
# 切换到JDK 8
jdk8

# 切换到JDK 11
jdk11

# 切换到JDK 17
jdk17

# 查看当前JDK版本和帮助
jdk
```

## 目录挂载

容器会自动挂载以下目录:
- `/data`
- `/data1`
- `/data2`
- `/data-lush`
- `/data_test`
- `/mnt/nas1`
- `/data_melody`
- `/data-melody`

## 常用操作示例

### 开发环境管理
```bash
# 完整重建环境
./build.sh
./start.sh

# 快速重启容器
docker restart shuai-dev

# 进入容器执行命令
docker exec -it shuai-dev bash
```

### C++开发示例
```bash
# 编译C++20项目
g++ -std=c++20 main.cpp
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

### Java多版本开发示例
```bash
# Spring Boot项目使用JDK 17
jdk17
./mvnw spring-boot:run

# 旧项目使用JDK 8
jdk8
mvn clean package
```

### Python虚拟环境示例
```bash
# 创建新项目环境
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 注意事项

1. 首次构建可能需要较长时间
2. 确保你的Docker服务已启动
3. 如果构建失败，可以使用`./dev-cli.sh clean`清理后重试
4. 容器会占用较多磁盘空间，请确保有足够的存储空间 
