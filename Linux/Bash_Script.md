# Bash 01 Script

&emsp;&emsp;在本节中，我们将介绍如何编写bash脚本。

## 一、开始

&emsp;&emsp;bash脚本与在终端中使用相同，直接使用命令即可，下面是一段简单的脚本，同时tree如下。

```bash
#! /bin/bash

ls
echo "Hello World"

# tree
# .
# └── run.sh
```
在第一行的`#! /bin/bash`表示除此之外的所有`#`引导的内容均为注释。值得注意的是，我们直接使用`./run.sh`是无法直接运行的，我们要么使用`bash run.sh`，要么给予它`+x`的权限。例如：

```shell
xjt@u16:~/mk/Bash$ bash run.sh 
run.sh
Hello World

xjt@u16:~/mk/Bash$ chmod +x run.sh 
xjt@u16:~/mk/Bash$ ./run.sh 
run.sh
Hello World
```

sh和bash有着相似的内容，但对于规则的兼容性不同。对于ubuntu来说，`/bin/sh`指向`/bin/bash`，但是也可以使用`-posix`来指定其模式。

## 二、基本语法

### 2.1 if

&emsp;&emsp;下面是一段基础的逻辑判断：

```bash
Name="XJT"

if [ "$Name" == "XJT" ]
then
    echo "Your name is XJT"
else
    echo "Your name is not XJT"
fi
```

在上面的代码中，有几个需要注意的地方。一是变量赋值之间是不允许有空格，即`Name="XJT"`，而不是`Name = "XJT"`；二是if之后不使用`()`，而是使用`[]`，同时需要注意括号前后均有空格，即`if [ $val ]`，而非`if [$val]`。

&emsp;&emsp;接下来我们看一下一般变量的情况。

```bash
Num1=3
Num2=5

if [ $Num1 -gt $Num2 ]
then
    echo "$Num1 is greater than $Num2"
else
    echo "$Num1 is less than $Num2"
fi
```

&emsp;&emsp;接下来看对于文件的处理。

```bash
File="hello.txt"

if [ -f $File ]
then 
    echo "$File Exist"
else
    echo "$File not Exist"
fi

# xjt@u16:~/mk/Bash$ tree
# .
# └── run.sh

# 0 directories, 1 file
# xjt@u16:~/mk/Bash$ ./run.sh
# hello.txt not Exist


# xjt@u16:~/mk/Bash$ touch hello.txt
# xjt@u16:~/mk/Bash$ tree
# .
# ├── hello.txt
# └── run.sh

# 0 directories, 2 files
# xjt@u16:~/mk/Bash$ ./run.sh
# hello.txt Exist
# xjt@u16:~/mk/Bash$ 
```

在上面的`if`中，我们使用`-f`来指定`$File`为文件。同样的，其他的标签如下：

1. `-d`，是目录
2. `-e`，文件存在，常用`-f`代替。
3. `-f`，提供的字符串是文件。
4. `-g`，文件已有group id。
5. `-r`，可读。
6. `-s`，大小不为零
7. `-u`，已有user id。
8. `-w`，可写。
9. `-x`，可执行。

### 2.2 case

&emsp;&emsp;case与C中的switch相同，下面来看一下它是如何运作的。

```bash
read -p "Input y/yes or n/no: " Input

case $Input in 
    [yY] | [yY][eE][sS])
        echo "yes!"
        ;;
    [nN] | [nN][oO])
        echo "no!"
        ;;
    *)
        echo "default output"
        ;;
esac
```

在上面的代码中，有几个需要注意的地方。一是在每一个分支的后面需要加上`)`；二是每个分支结束需要加上`;;`；三是最后的`*`相当于其他语言中的`default`。

### 2.3 for

&emsp;&emsp;for循环与python相似，下面是一个最基本的for循环。

```bash
Array="1 2 3 4 5"

for it in $Array 
    do
        echo "$it"
done
```

&emsp;&emsp;下面来看一个对文件重命名的脚本：

```shell
txtFiles=$(ls *.txt)
att="new"

for file in $txtFiles
    do
        echo "Rename $file to $att-$file"
        mv $file $att-$file
done
```

### 2.4 while

&emsp;&emsp;接下来看一下如何使用while来读取一个文件夹的内容。

```bash
Line=1
while read -r CURRENT_LINE
    do
        echo "$Line: $CURRENT_LINE"
        ((Line++))
done < "./file.txt"
```

### 2.5 function

&emsp;&emsp;下面是一个简单的Hello world函数。

```bash
function hello()
{
    echo "Hello world"
}

hello
```

&emsp;&emsp;bash中含参函数和其他语言并不一样，其参数并不需要声明到`()`中，来看一个例子：

```bash
function sum()
{
    let ans=$1+$2
    echo "Sum: $ans"
}

sum 5 6
```

