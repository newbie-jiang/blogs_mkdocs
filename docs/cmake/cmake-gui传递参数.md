https://cmake.org/cmake/help/latest/command/set.html 

https://cmake.org/getting-started/

## cmake的五种参数类型

官方文档说明一共是五种参数

| TYPE     | cmake-gui表现   | 输入限制   | 备注               |
| -------- | --------------- | ---------- | ------------------ |
| BOOL     | 复选框          | 只能ON/OFF | 真正限制用户       |
| STRING   | 文本框          | 无         | 可配STRINGS做下拉  |
| INT      | 文本框          | 无         | 实际上和STRING类似 |
| PATH     | 文本框+目录按钮 | 无         | 推荐用选择按钮     |
| FILEPATH | 文本框+文件按钮 | 无         | 推荐用选择按钮     |



写一个main.c 与cmake测试

## main.c

```c
#include <stdio.h>

#ifndef MY_BOOL
#define MY_BOOL 0
#endif
#ifndef MY_STRING
#define MY_STRING "none"
#endif
#ifndef MY_INT
#define MY_INT 0
#endif
#ifndef MY_PATH
#define MY_PATH "none"
#endif
#ifndef MY_FILE
#define MY_FILE "none"
#endif
#ifndef MY_MODE
#define MY_MODE "none"
#endif
#ifndef MY_STATIC
#define MY_STATIC "none"
#endif
#ifndef MY_INTERNAL
#define MY_INTERNAL "none"
#endif

int main(void) {
    printf("==== cmake-gui 数据类型输入演示 ====\n");
    printf("MY_BOOL    = %d\n", MY_BOOL);
    printf("MY_STRING  = %s\n", MY_STRING);
    printf("MY_INT     = %d\n", MY_INT);
    printf("MY_PATH    = %s\n", MY_PATH);
    printf("MY_FILE    = %s\n", MY_FILE);
    printf("MY_MODE    = %s\n", MY_MODE);
    printf("MY_STATIC  = %s\n", MY_STATIC);
    printf("MY_INTERNAL= %s\n", MY_INTERNAL);
    return 0;
}

```

##  CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.16)
project(cmake_gui_types_demo C)

# BOOL 类型（复选框）
set(MY_BOOL ON CACHE BOOL "一个布尔值 (ON/OFF)")

# STRING 类型（自由文本）
set(MY_STRING "abc" CACHE STRING "任意字符串")

# INT 类型（数值输入，表现为字符串输入框）
set(MY_INT "123" CACHE STRING "整数（文本框，需手动填数字）")

# PATH 类型（路径，带目录选择按钮）
set(MY_PATH "${CMAKE_SOURCE_DIR}" CACHE PATH "请选择一个文件夹路径")

# FILEPATH 类型（文件路径，带文件选择按钮）
set(MY_FILE "${CMAKE_SOURCE_DIR}/CMakeLists.txt" CACHE FILEPATH "请选择一个文件")

# STRINGS 下拉选项
set(MY_MODE "auto" CACHE STRING "模式选择（下拉菜单）")
set_property(CACHE MY_MODE PROPERTY STRINGS "auto" "manual" "expert")

# INTERNAL 类型（不可见，测试用）
set(MY_INTERNAL "secret" CACHE INTERNAL "内部变量，不会显示在 cmake-gui")

# STATIC 类型（只读，显示但不可编辑）
set(MY_STATIC "readonly" CACHE STATIC "只读变量，只能查看")

# 传递给 main.c
add_compile_definitions(
    MY_BOOL=$<IF:$<BOOL:${MY_BOOL}>,1,0>
    MY_STRING="${MY_STRING}"
    MY_INT=${MY_INT}
    MY_PATH="${MY_PATH}"
    MY_FILE="${MY_FILE}"
    MY_MODE="${MY_MODE}"
    MY_STATIC="${MY_STATIC}"
    MY_INTERNAL="${MY_INTERNAL}"
)

add_executable(main main.c)

```



