# CMake基础介绍

&emsp;&emsp;本篇文章将简要介绍CMake的基础入门，<a href = "https://www.bilibili.com/video/BV1vR4y1u77h?p=1">参考视频</a>。

[toc]

## 一、CMkae一个Hello World

（1）编写一个Hello World文档

```cpp
#include <iostream>

int main()
{
    std::cout << "Hello world" << std::endl;
    return 0;
}
```

（2）编写一个CMakeLists.txt，注意，文件名严格区分大小写

```cmake
# CMakeLists.txt

PROJECT (HELLO)

SET(SRC_LIST main.cpp)

MESSAGE(STATUS "This is BINARY dir " ${HELLO_BINARY_DIR})

MESSAGE(STATUS "This is SOURCE dir "${HELLO_SOURCE_DIR})

ADD_EXECUTABLE(hello ${SRC_LIST})
```

(3)创建一个build文件夹，我们将在该文件下面生产Makefile文件。

```shell

mkdir build

# 此时文件目录如下
.
├── buld
├── CMakeLists.txt
└── main.cpp
```

(4)进入build文件夹，然后调用cmake命令生成makefile，最后使用make生产可执行文件。

```shell
cd build

# ..表示调用上级目录的CMakeLists.txt
cmake ..

make

ls
# CMakeCache.txt  CMakeFiles  cmake_install.cmake  hello  Makefile

./hello
# Hello world
```

## 二、语法基本介绍

&emsp;&emsp;我们将使用上面的CMakeLists.txt来介绍其基本语法，下面介绍几个关键字。

### 2.1 PROJECT

```cmake
# 指定了工程的名字，默认支持所有语言
PROJECT (HELLO)   

# 指定了工程的名字，并且支持语言是C++
PROJECT (HELLO CXX)      

# 指定了工程的名字，并且支持语言是C和C++
PROJECT (HELLO C CXX)      
```

该指定隐式定义了两个CMAKE的变量

```cmake
<projectname>_BINARY_DIR，本例中是 HELLO_BINARY_DIR

<projectname>_SOURCE_DIR，本例中是 HELLO_SOURCE_DIR
```

&emsp;&emsp;MESSAGE关键字就可以直接使用者两个变量，当前都指向当前的工作目录，后面会讲外部编译

- 问题：如果改了工程名，这两个变量名也会改变。
- 解决：又定义两个预定义变量：PROJECT_BINARY_DIR和PROJECT_SOURCE_DIR，这两个变量和HELLO_BINARY_DIR，HELLO_SOURCE_DIR是一致的。所以改了工程名也没有关系。

### 2.2 SET

&emsp;&emsp;用来显示的指定变量的。

```cmake
# SRC_LIST变量就包含了main.cpp
SET(SRC_LIST main.cpp)

# 多个cpp文件的情况
SET(SRC_LIST main.cpp t1.cpp t2.cpp) 
```

### 2.3 MESSAGE

&emsp;&emsp;向终端输出用户自定义的信息，主要包含一下三种信息：

1. SEND_ERROR，产生错误，生产过程被跳过。
2. SATUS，输出前缀为“-”的信息。
3. FATAL_ERROR，立即终止所有cmake过程。

### 2.4 ADD_EXECUTABLE

&emsp;&emsp;生产可执行文件，``ADD_EXECUTABLE(hello ${SRC_LIST})``生产的可执行文件，可执行文件名为hello，源文件读取SRC_LIST中的内容。也等同于，``ADD_EXECUTABLE(hello main.cpp)``。值得注意的是，可执行文件hello，与工程名HELLO无关。

### 2.4 基本原则

1. 变量使用``${ }``的方式取值，但是在IF语句中直接使用变量名。
2. ``指令(参数1 参数2...)``，参数之间使用**空格**或**分号**隔开。
3. 指令与大小写无关，参数和变量与大小写有关，推荐指令使用大写。

注意：

1. ``SET(SRC_LIST main.cpp)``Equal2``SET(SRC_LIST "main.cpp")``，当源文件有空格时，必须使用引号。
2. ``ADD_EXECUTABLE(hello main.cpp)``可以写作``ADD_EXECUTABLE(hello main)``，它会自动去寻找.c或者时.cpp文件，但是不推荐这么做，可能存在多个filename为main的文件，导致冲突。

## 三、让Hello更像一个工程

&emsp;&emsp;这里将源码放入``./src``下，此时需要再创建两个CMakeLists.txt，一个在外层目录，一个在src目录下。此时tree：

```shell
.
├── build
├── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── main.cpp
```

&emsp;&emsp;外部CMakeLists.txt内容如下：

```cmake
PROJECT (HELLO)

# ADD_SUBDIRECTORY(source_dir [binary_dir] [EXCLUDE_FROM_ALL])
ADD_SUBDIRECTORY(src bin)
```

1. ``ADD_SUBDIRECTORY()``，用于指定工程文件src的存放目录，同时可以指定中间二进制和目标二进制的存放位置。
2. ``EXLUCE_FROM_ALL``，将写的目录从编译中排除，如程序中的example。
3. ``ADD_SUBDIRECTORY(src bin)``，将src子目录加入工程，并指定编译输出（包含中间结果）的路径为bin目录。如果不指定bin目录，所有输出（包括中间结果）都将存放在``build/src``目录下。

&emsp;&emsp;src下CMakeLists.txt的内容：

```cmake
SET(SRC_LIST main.cpp)

# 更改二进制的保存目录
# SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR/bin})
# SET(LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR/lib})

ADD_EXECUTABLE(hello.exe ${SRC_LIST})
```

## 四、安装

&emsp;&emsp;我们这里使用``make install``安装，这里需要使用的cmake指令有``INSTALL``。这里我们安装文件、脚本和文档，分别对应了COPYRIGHT、README；runhello.sh、doc|hello.txt。

```shell
.
├── build
├── CMakeLists.txt
├── COPYRIGHT
├── doc
│   └── hello.txt
├── README
├── runhello.sh
└── src
    ├── CMakeLists.txt
    └── main.cpp
```

### 4.1 安装文件 - FILES

&emsp;&emsp;我们在外层CMakeLists.txt中添加如下内容：

```cmake
INSTALL(FILES COPYRIGHT README DESTINATION myDemo/doc/camke)
```

其中FILES指定类型，DESTINATION为绝对路径，默认指向usr/locl/myDemo/doc/camke，如果要改变绝对路径可以在cmake时使用``cmake -DCMAKE_INSTALL_PERFIX=/home/``一类的命令。

### 4.2 安装脚本 - PROGRAMS

&emsp;&emsp;PROGRAMS指非目标文件的可执行安装程序（例如脚本）：

```cmake
INSTALL(PROGRAMS runhello.sh DESTINATION bin)
```

需要注意的时，这里脚本同样安装在/usr/local下

### 4.3 安装文本 - doc

&emsp;&emsp;因为这里我们将需要安装的hello.txt放在了/doc下，所以这里有两个选择，一是在doc下写一个CMakeLists.txt，二是写在工程文件里，这里我们直接写到工程文件。

```cmake
INSTALL(DIRECTORY doc DESTINATION myDemo/doc/camke)
# or
INSTALL(DIRECTORY doc/ DESTINATION myDemo/doc/camke)
```

这里需要注意``doc``和``doc/``的区别，前者安装doc这个文件夹到目标，后者安装文件夹里的所有文件到目标。

### 4.4 小结

&emsp;&emsp;外层cmake配置如下：

```cmake
PROJECT (HELLO)

ADD_SUBDIRECTORY(src bin)

INSTALL(FILES COPYRIGHT README DESTINATION myDemo/doc/camke)
INSTALL(PROGRAMS runhello.sh DESTINATION bin)

INSTALL(DIRECTORY doc DESTINATION myDemo/doc/camke)
```

安装结果：

```shell
Install the project...
-- Install configuration: ""
-- Installing: /usr/local/myDemo/doc/camke/COPYRIGHT
-- Installing: /usr/local/myDemo/doc/camke/README
-- Installing: /usr/local/bin/runhello.sh
-- Installing: /usr/local/myDemo/doc/camke/doc
-- Installing: /usr/local/myDemo/doc/camke/doc/hello.txt
```

## 五、静态库与动态库

&emsp;&emsp;现在我们有工程文件如下：

```shell
.
├── build
├── CMakeLists.txt
└── lib
    ├── CMakeLists.txt
    ├── hello.cpp
    └── hello.h
```

外层CMakeLists.txt，这里添加了一个cmake的版本需求，避免抛出警告。

```cmake
PROJECT (HELLO)
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)

ADD_SUBDIRECTORY(lib bin)
```

内部CMakeLists.txt：

```cmake
SET(LIBHELLO_SRC hello.cpp)

ADD_LIBRARY(hello_static STATIC ${LIBHELLO_SRC})
# 重命名静态库
SET_TARGET_PROPERTIES(hello_static PROPERTIES OUTPUT_NAME "hello")
# 清除重名的hello，避免和后面的动态库冲突
SET_TARGET_PROPERTIES(hello_static PROPERTIES CLEAN_DIRECT_OUTPUT 1)

ADD_LIBRARY(hello_shared SHARED ${LIBHELLO_SRC})
SET_TARGET_PROPERTIES(hello_shared PROPERTIES OUTPUT_NAME "hello")
SET_TARGET_PROPERTIES(hello_shared PROPERTIES CLEAN_DIRECT_OUTPUT 1)
# 版本号，前者是动态库本版，后者是API版本
SET_TARGET_PROPERTIES(hello_static PROPERTIES VERSION 1.0 SOVERSION 1.0)
```

&emsp;&emsp;在构建完成之后，进入/build/bin目录，可以查看

```shell
xjt@ubuntu:~/MyFloder/myCmakeDemo/build/bin$ tree
.
├── CMakeFiles
│   ├── CMakeDirectoryInformation.cmake
│   ├── hello_shared.dir
│   │   ├── build.make
│   │   ├── cmake_clean.cmake
│   │   ├── CXX.includecache
│   │   ├── DependInfo.cmake
│   │   ├── depend.internal
│   │   ├── depend.make
│   │   ├── flags.make
│   │   ├── hello.cpp.o
│   │   ├── link.txt
│   │   └── progress.make
│   ├── hello_static.dir
│   │   ├── build.make
│   │   ├── cmake_clean.cmake
│   │   ├── cmake_clean_target.cmake
│   │   ├── CXX.includecache
│   │   ├── DependInfo.cmake
│   │   ├── depend.internal
│   │   ├── depend.make
│   │   ├── flags.make
│   │   ├── hello.cpp.o
│   │   ├── link.txt
│   │   └── progress.make
│   └── progress.marks
├── cmake_install.cmake
├── libhello.a
├── libhello.so
└── Makefile
```

这里可以看见，已经生成了静态库libhello.a和动态库libhello.so，后缀在windows平台为.lib和.dll。

### 5.1 安装静态库

&emsp;&emsp;这里我们需要安装头文件和库，如下：

```cmake
# 文件放到该目录下
INSTALL(FILES hello.h DESTINATION include/hello)

# 二进制，静态库，动态库安装都用TARGETS
# ARCHIVE 特指静态库，LIBRARY 特指动态库，RUNTIME 特指可执行目标二进制。
INSTALL(TARGETS hello_shared hello_static LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
```

&emsp;&emsp;构建之后安装：

```shell
Install the project...
-- Install configuration: ""
-- Installing: /usr/local/include/hello/hello.h
-- Installing: /usr/local/lib/libhello.so
-- Installing: /usr/local/lib/libhello.a
```