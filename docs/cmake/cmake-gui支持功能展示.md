`cmake-gui` 是 CMake 提供的**官方图形界面配置工具**，主要用于简化 CMake 项目的配置和生成过程，特别适合跨平台工程、复杂工程、需要手动调整编译参数的场景。

下面总结一下 **cmake-gui 的主要功能和典型用途**：

------

## 1. **CMakeLists.txt 可视化配置**

- **加载项目**：选择含有 `CMakeLists.txt` 的源码根目录。
- **生成目录**：指定一个独立的构建目录（推荐 out-of-source 构建）。
- **解析和显示全部 CMake 变量**（包括 cache 变量和 option）。

------

## 2. **编译选项管理**

- **一键查找/添加/修改变量**：
  - 包括 `CMAKE_BUILD_TYPE`、`CMAKE_TOOLCHAIN_FILE`、`CMAKE_C_COMPILER`、`EXAMPLE_ENABLE_TESTS`、各种库路径等。
- **支持分组显示和快速搜索**变量。
- **支持类型检查**：如布尔值、路径、字符串、整数。

------

## 3. **可选组件（Feature/Option）勾选**

- 可以**勾选 ON/OFF 类型的开关选项**，比如 `BUILD_SHARED_LIBS`、`ENABLE_FOO` 等。
- 适合有多个模块、插件、驱动、功能包可选启用/禁用的工程。

------

## 4. **重新配置与自动依赖解析**

- **Configure**：读取并解析 CMakeLists.txt，根据当前设置生成（或更新）可配置项。
- **Generate**：生成指定平台/IDE/Makefile 的工程文件（如 Visual Studio、Ninja、Unix Makefiles 等）。
- **变量变更后自动重算依赖关系**。

------

## 5. **导入和导出配置**

- 支持直接**编辑和保存 `CMakeCache.txt`**（工程编译选项和状态都记录在这里）。
- 可切换/管理多个 Preset（如 CMake 3.19+ 的 Presets 功能）。

------

## 6. **跨平台支持**

- 可在 Windows、Linux、macOS 上使用。
- 支持配置/生成 Visual Studio、Makefile、Xcode、Ninja、Eclipse CDT4 等多种工程。

------

## 7. **错误和提示输出**

- 显示 CMake 配置和生成过程中的所有消息、警告和错误，便于调试 CMake 脚本问题。

------

## 8. **辅助查找和环境变量配置**

- 支持设置 `CMAKE_PREFIX_PATH`、`CMAKE_MODULE_PATH`，方便查找外部库和自定义 CMake 模块。
- 支持设置编译器路径、工具链文件，常用于交叉编译和嵌入式工程。

------

## 典型用法总结

- **无需手写 cmake 命令**，通过 GUI 点选/切换功能、自动刷新依赖、调整路径，非常适合初学者或需要频繁试错的工程。
- 支持复杂工程的多配置管理（如 debug/release、不同目标平台、不同功能组合等）。
- 是大型/多组件/嵌入式项目（如 Zephyr、OpenCV、Qt、STM32CubeMX CMake 工程等）常用的项目管理利器。



**绝大多数现代跨平台 C/C++ 项目都支持 CMake**，而且都可以用 `cmake-gui` 来配置和管理。下面列举一些**最具代表性、开源且社区活跃的项目**，它们的源码你可以直接下载并用 `cmake-gui` 体验、学习 CMake 的工程结构和选项管理：



## 1. **OpenCV**

- **简介**：世界著名的计算机视觉与图像处理库，C++/Python 支持，跨平台。
- **CMake 特色**：选项众多（模块启用/禁用、第三方库集成、编译优化等），非常适合学习复杂 CMake 工程管理。
- **源码地址**：https://github.com/opencv/opencv
- **学习建议**：下载源码后用 `cmake-gui` 配置，可以看到诸如 `WITH_CUDA`、`BUILD_EXAMPLES` 等丰富选项。

------

## 2. **LLVM/Clang**

- **简介**：工业级 C/C++/Rust/Swift 编译器框架，CMake 项目的典范。
- **CMake 特色**：极度模块化，支持交叉编译，分模块构建。
- **源码地址**：https://github.com/llvm/llvm-project
- **学习建议**：可以感受大规模 CMake 工程的管理方式。

------

## 3. **Qt (Qt6 开源版)**

- **简介**：全球知名的 GUI 应用开发框架（Qt6 以后全面 CMake 管理）。
- **源码地址**：https://github.com/qt/qtbase
- **学习建议**：看 Qt 项目如何用 option 分模块、管理平台差异。