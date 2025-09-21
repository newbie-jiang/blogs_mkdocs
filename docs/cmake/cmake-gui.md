# cmake-gui 控制编译

code https://github.com/newbie-jiang/cmake-study/tree/master/cmake-gui

## 功能展示

- cmake gui来决定编译运行哪一个库
- 主函数中的使能同步

![image-20250805201419738](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805201419738.png)

### 同时使能三个库

![image-20250805201744434](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805201744434.png)

![image-20250805201722349](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805201722349.png)

### 使能两个库

![image-20250805201830115](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805201830115.png)

![image-20250805201858358](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805201858358.png)

## 创建的文件以及目录

在项目中的单元测试，我希望一种简单的方式来决定编译哪些模块，上述的做了三个库 alib  blib clib  每一个库都有单独的CMakeLists.txt来管理库文件，与所有库文件同目录的CMakeLists.txt 用来管理所有的lib库 , 主CMakeLists.txt控制所有的编译过程

- 此种方式需要再代码中加上cmake的语法规则来决定编译哪一些代码，可以看做是C语言的#ifdef 之类的，cmake gui配置相当于一个可视化的宏开关

```
$ tree -L 3
.
|-- CMakeLists.txt
|-- main.c
`-- test_lib
    |-- CMakeLists.txt
    |-- alib
    |   |-- CMakeLists.txt
    |   |-- alib.c
    |   `-- alib.h
    |-- blib
    |   |-- CMakeLists.txt
    |   |-- blib.c
    |   `-- blib.h
    |-- clib
    |   |-- CMakeLists.txt
    |   |-- clib.c
    |   `-- clib.h


4 directories, 12 files

```



## 代码展示

## main.c

```c
#include <stdio.h>
#ifdef HAVE_ALIB
#include "alib.h"
#endif
#ifdef HAVE_BLIB
#include "blib.h"
#endif
#ifdef HAVE_CLIB
#include "clib.h"
#endif

int main(void) {
#ifdef HAVE_ALIB
    alib_hello();
#endif
#ifdef HAVE_BLIB
    blib_hello();
#endif
#ifdef HAVE_CLIB
    clib_hello();
#endif
    return 0;
}
```

## 主CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.14)
project(demo_cmake_libs)

add_executable(demo main.c)

# 添加 test_lib 目录，集中管理
add_subdirectory(test_lib)

if (TARGET alib)
    target_link_libraries(demo PRIVATE alib)
    target_compile_definitions(demo PRIVATE HAVE_ALIB)
endif()
if (TARGET blib)
    target_link_libraries(demo PRIVATE blib)
    target_compile_definitions(demo PRIVATE HAVE_BLIB)
endif()
if (TARGET clib)
    target_link_libraries(demo PRIVATE clib)
    target_compile_definitions(demo PRIVATE HAVE_CLIB)
endif()
```



## test_lib目录下的CMakeLists.txt

```cmake
option(ENABLE_ALIB "Build alib library" ON)
option(ENABLE_BLIB "Build blib library" ON)
option(ENABLE_CLIB "Build clib library" ON)

if (ENABLE_ALIB)
    add_subdirectory(alib)
endif()
if (ENABLE_BLIB)
    add_subdirectory(blib)
endif()
if (ENABLE_CLIB)
    add_subdirectory(clib)
endif()
```



## test_lib\alib下

- alib.c

```c
#include <stdio.h>

void alib_hello(void) {
    printf("Hello from alib!\n");
}
```

- alib.h

```c
#ifndef ALIB_H
#define ALIB_H

void alib_hello(void);

#endif
```

- CMakeLists.txt

```cmake
add_library(alib STATIC alib.c)
target_include_directories(alib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

## test_lib\blib下

- blib.c

```c
#include <stdio.h>

void blib_hello(void) {
    printf("Hello from blib!\n");
}
```

- blib.h

```c
#ifndef BLIB_H
#define BLIB_H

void blib_hello(void);

#endif
```

- CMakeLists.txt

```cmake
add_library(blib STATIC blib.c)
target_include_directories(blib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

## test_lib\clib下

- clib.c

```c
#include <stdio.h>

void clib_hello(void) {
    printf("Hello from clib!\n");
}
```

- clib.h

```c
#ifndef CLIB_H
#define CLIB_H

void clib_hello(void);

#endif
```

- CMakeLists.txt

```cmake
add_library(clib STATIC clib.c)
target_include_directories(clib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```



## 编译命令

```
mkdir build && cd build
cmake-gui ..      (可视化配置并生成makefile文件【看下面的图】)
make
.\demo.exe
```

![image-20250805204348229](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805204348229.png)

![image-20250805204446962](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805204446962.png)

![image-20250805204600136](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250805204600136.png)
