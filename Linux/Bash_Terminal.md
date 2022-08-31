# Bash 01 Terminal

[toc]

&emsp;&emsp;在本节中，我们将介绍Bash Terminal的一些基础语法。

## 一、文件目录相关

1. `ls` i.e. list storage：显示当前目录下的文件与文件夹。
2. `pwd` i.e. print work directory：显示当前目录。
3. `cd` i.e. change directory：使用dir/dir/来切换相对目录（个人习惯使用./）；使用/dir/dir来切换绝对目录。

### 1.1 pushd和popd

&emsp;&emsp;为了实现多个目录的相互跳转，这里使用一个目录堆来完成。当前的目录如下：

```bash
.
├── 01.sh
├── T1
├── T2
└── T3
```

&emsp;&emsp;使用`dirs`可以查看该堆：

```bash
xjt@u16:~/mk/Bash$ dirs -p -v
 0  ~/mk/Bash
 1  ~/mk/Bash/T1
```

&emsp;&emsp;我已经向该堆添加了两个目录。下面我们使用`pushd`可以向其中添加目录：

```bash
xjt@u16:~/mk/Bash$ pushd T2/
~/mk/Bash/T2 ~/mk/Bash ~/mk/Bash/T1
xjt@u16:~/mk/Bash/T2$ dirs -p -v
 0  ~/mk/Bash/T2
 1  ~/mk/Bash
 2  ~/mk/Bash/T1
xjt@u16:~/mk/Bash/T2$ 
```

&emsp;&emsp;之后在使用`pushd +n`来切换目录：

```bash
xjt@u16:~/mk/Bash/T2$ pushd +2
~/mk/Bash/T1 ~/mk/Bash/T2 ~/mk/Bash
xjt@u16:~/mk/Bash/T1$ 
```

&emsp;&emsp;出栈则使用`popd`来完成：

```bash
xjt@u16:~/mk/Bash/T1$ popd +0
~/mk/Bash/T2 ~/mk/Bash
xjt@u16:~/mk/Bash/T2$ dirs -p -v
 0  ~/mk/Bash/T2
 1  ~/mk/Bash
```

### 1.2 文件与查找

1. file：用于查看文件属性。
2. locate：用于模糊查找文件。

### 1.3 创建文件夹与文件

1. mkdir：创建文件夹。
2. touch：创建文件。

### 1.4 拷贝与移动

1. cp：拷贝。
2. mv：移动。

## 二、文件编辑

### 2.1 concatenate

&emsp;&emsp;bash使用`cat`来连接文件，我们有如下文件：

```bash
.
├── file1.txt
└── file2.txt
```

&emsp;&emsp;我们可以使用`cat`来打印文件内容：

```bash
xjt@u16:~/mk/Bash$ cat file1.txt 
hello
xjt@u16:~/mk/Bash$ cat file2.txt 
world
```

&emsp;&emsp;同时能使用`>>`来向文件中**追加**内容，使用`>`来**覆写**：

```bash
xjt@u16:~/mk/Bash$ cat >> file1.txt 
world
xjt@u16:~/mk/Bash$ cat file1.txt 
hello
world
xjt@u16:~/mk/Bash$ 
```

当我们结束追加内容的时候，使用`Ctrl+D`来结束命令。欲清空文件的内容则可以使用`cat /dev/null > file1.txt`来完成，该命令是将一个文件的内容**覆写**到另外一个文件，追加则使用`>`。

### 2.2 more & less

&emsp;&emsp;当我们想要查看文件内容的时候，可以使用`more`或者`less`来查看。使用more一次跳转多行，less则可以一行一行地跳转。两者均可以使用`q`键退出。

### 2.3 文本编辑器

&emsp;&emsp;linux下的编辑器常用的有nano、vim、gedit。其中nano操作简单，在界面的下方有相应的提示；vim和gedit则没有，但是功能更加多样，比如同时处理多个文件等。

