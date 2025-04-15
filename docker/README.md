# 开发环境容器集合

这个仓库包含了多种开发环境的 Docker 容器配置，便于快速搭建和使用各种开发环境。

## 可用环境

### Java 开发环境

- **OpenJDK 8 + IDEA** - 基于 OpenJDK 8 的 Java 开发环境
- **OpenJDK 11 + IDEA** - 基于 OpenJDK 11 的 Java 开发环境
- **OpenJDK 17 + IDEA** - 基于 OpenJDK 17 的 Java 开发环境
- **多 JDK 版本** - 支持在 JDK 8/11/17 之间切换的开发环境

### C++ 开发环境

- **Ubuntu 24.04 + CLion + GCC 13** - 现代 C++ 开发环境，基于 GCC 13

### 通用开发环境

- **Ubuntu 24.04 基础环境** - 基础的 Ubuntu 24.04 开发环境
- **统一开发环境** - 集成了 C++/Java/Python 的统一开发环境

## 使用方法

每个环境目录下都有以下统一的脚本：

1. `build.sh` - 构建容器
2. `start.sh` - 启动容器

### 标准使用流程

```bash
# 进入所需环境目录
cd <环境目录>

# 构建容器
./build.sh

# 启动容器
./start.sh

# 通过SSH连接到容器
ssh -p <端口> shijiashuai@localhost
```

### 离线构建版本

对于网络受限的环境，每个目录都提供了预下载资源的选项：

```bash
# 进入离线构建目录
cd <环境目录>/offline-build

# 预下载所需资源
./download_resources.sh

# 然后构建
./build.sh

# 启动容器
./start.sh
```

## 环境端口分配

| 环境名称 | 目录 | SSH端口 |
|----------|------|--------|
| OpenJDK 8 + IDEA | openjdk-idea-jdk8 | 28960 |
| OpenJDK 11 + IDEA | openjdk-idea-jdk11 | 28961 |
| OpenJDK 17 + IDEA | openjdk-idea-jdk17 | 28962 |
| 多JDK版本 | openjdk-idea-multi-jdk | 28964 |
| Ubuntu 24.04 | ubuntu-2404 | 28965 |
| Ubuntu 24.04 + CLion + GCC13 | ubuntu-2404-clion-gcc13 | 28963 |
| 统一开发环境 | unified-dev-environment | 28966 |

## 统一用户信息

所有环境均使用相同的用户信息：

- **用户名**: shijiashuai
- **密码**: phoenix2024

## 目录挂载

所有容器均会自动挂载以下数据目录:
- `/data`
- `/data1`
- `/data2`
- `/data-lush`
- `/data_test`
- `/mnt/nas1`
- `/data_melody`
- `/data-melody`

## 开发建议

1. 推荐使用 Visual Studio Code 的远程 SSH 扩展连接到容器进行开发
2. 对于 Java 开发，可以根据项目需求选择合适的 JDK 版本
3. C++ 开发推荐使用 Ubuntu 24.04 + CLion + GCC13 环境，支持最新的 C++20/23 特性
4. 如果需要同时进行多种语言开发，推荐使用统一开发环境 