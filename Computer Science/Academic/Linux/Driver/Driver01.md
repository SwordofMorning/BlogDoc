# Linux Driver Programming 01 Kernel Module

[toc]

&emsp;&emsp;在本章节中，我们将了解如何编写一个linux内核模块，以及其相关概念与结构。

## 一、Linux内核模块简介

&emsp;&emsp;向Linux内核添加组件的方式有两种，一是将组件编入内核，二是以模块的方式来实现。内核具有如下的特点：

1. 模块本身不编入内核，从而减小内核的大小。
2. 模块一旦被加载，就和内核的其他部分一样。

下面是一个最简单的Hello World模块，其位于`kernel/drivers/myHelloWorld/`目录下：

```c
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int __init myHelloWorld_init()
{
    printk(KERN_INFO "Hello World init\n");
}

module_init(myHelloWorld_init);

static void __exit myHelloWorld_exit()
{
    printk(KERN_INFO "Hello World exit\n");
}
module_exit(myHelloWorld_exit);

MODULE_LICENSE("GPL v2");
```

&emsp;&emsp;这个模块只包含了简单的加载与退出功能，以及一个关于许可证的说明。加载模块可以使用`insmod ./myHelloWorld.ko`命令加载，卸载模块则是通过`rmmod myHelloWorld`来实现。

&emsp;&emsp;内核空间中用于输出的的函数是`printk`而不是用户空间使用的`printf`。`printk`和`printf`的使用方法基本相似，但是可以指定输出级别。

&emsp;&emsp;在linux中，可以使用`lsmod`命令来获取已加载的所有模块以及其依赖关系，例如：

```shell
Module                  Size  Used by
ccm                    20480  9
rfcomm                 77824  0
bnep                   20480  2
nls_iso8859_1          16384  1
snd_hda_codec_hdmi     49152  1
arc4                   16384  2
snd_soc_skl            86016  0
...
```

`lsmod`实际上是读取并分析`/proc/modules`文件，与之相同的是`cat /proc/modules`。内核中已加载的模块同样位于`/sys/module`目录下，加载hello.ko后，内核中也将包含`/sys/module/hello`目录。该目录下仅有一个refcnt文件和一个sections目录，

&emsp;&emsp;`modprobe`比`insmod`更强大，前者在加载mod时不仅会加载mod本身，同时也一并加载mod所依赖的其他mod。对于使用`modprobe`加载的模块，如果使用`modprobe -r filename`卸载，则同时将所有依赖的模块一并卸载。模块之间的依赖关系存放于`/lib/modules/<kernel-version>/modules.dep`文件中。使用`modinfo modname`可以查看mod的信息。

## 二、Linux内核模块程序结构

&emsp;&emsp;Linux内核模块由以下几部分组成：

1. **模块加载函数**。当通过`insmod`或者`modprobe`命令加载内核模块时，模块的加载函数会自动的执行，完成本模块相关的初始化工作。
2. **模块卸载函数**。当通过`rmmod`命令卸载某模块时，该函数会自动执行，并执行与加载函数相反的操作。
3. **内核许可声明**。LICENSE声明描述内核模块的许可权限，如果不声明LICENSE，模块加载到内核时将收到`Kernel Tainted`警告。可接受的LICENSE包括`GPL`、`GPL v2`、`GPL and additional rights`、`Dual BSD/GPL`、`Dual MPL/GPL`和`Proprietary`。
4. **模块参数（可选）**。加载模块时传递的值，它本身对应模块的全局变量。
5. **模块导出符号（可选）**。一个可导出的变量或函数，提供给其他的模块来使用。
5. **其他声明信息（可选）**。包括作者、描述、别名等。

## 三、模块加载函数

&emsp;&emsp;Linux内核模块加载函数一般由`__init`声明，例如：

```c
static int __init moduleInitFunction()
{
    /* init */
}
module_init(moduleInitFunction);
```

&emsp;&emsp;模块加载函数以`module_init(MODULE_NAME)`的形式被指定。它返回int型，若初始化成功则返回0，失败则返回错误编码。在Linux内核中，错误编码是一个接近于0的负值，定义于`<linux/errno.h>`中，包含`-ENODEV`、`-ENOMEM`之类的值。

&emsp;&emsp;在Linux中，可以使用`request_module(const char* fmt,...)`函数加载内核模块，驱动开发人员可以通过调用`request_module(MODULE_NAME)`来加载其模块。

&emsp;&emsp;在Linux中，所有标识为`__init`的函数如果直接编译入内核，成为内核镜像的一部分。其在连接的时候都会放在`.init.text`这个区段内。

```c
#define __init __attribute__((__section__(".init.text")))
```

所有的__init函数在区段`.initcall.init`中还保存了一份函数指针，在初始化内核会通过这些指针去调用这些__init函数，并在初始化完成之后释放__init区段（包括`.init.text`和`.initcall.init`等内容）的内存。

&emsp;&emsp;除了函数之外，变量也可以被定义为`__initdata`，对于只是初始化阶段需要的数据，内核在初始化完成之后，也可以释放其占有的内存。例如：

```c
static int myData __initdata = 1;
```

## 四、模块卸载函数

&emsp;&emsp;模块卸载函数一般以`__exit`标识声明，典型的模块卸载函数定义如下：

```c
static void __exit moduleExitFunction()
{
    /* exit */
}
module_eixt(moduleExitFunction);
```

&emsp;&emsp;exit函数在模块卸载时执行，并且无任何返回值，且必须以`module_exit(MODULE_NAME)`的形式来指定。通常来说，模块卸载函数要完成与模块加载函数相反的功能。

&emsp;&emsp;我们用`__exit`来修饰模块卸载函数，可以告内核如果相关的模块被直接编译进内核（即build-in），则exit函数会被省略，直接不链接入最后的镜像。除了函数外，只是退出阶段采用的数据也可以用`__exitdata`来修饰。

## 五、模块参数

&emsp;&emsp;我们可以使用`module_param(PARAM_NAME, PARAM_TYPE, READ_WRITE_PERMISSION)`，来为模块定义一个参数，如下代码例举了整形参数和字符型指针：

```c
static char* bookName = "BookName";
module_param(bookName, charp, S_IRUGO);

static int bookNum = 1;
module_param(bookNum, int, S_IRUGO);
```

&emsp;&emsp;在装载内核模块时，用户可以向模块传递参数，形式为`insmod MODULE_NAME=_MODULE_NAME_ PARAM_NAME=_PARAM_NAME_`，如果不传入参数，则将使用模块内的默认参数。如果以build in的方式构建，则无法使用`insmod`，但是bootloader里可以在bootargs里设置`MODULE_NAME.PARAM_NAME=VALUE`的形式来传递参数。同时，还可以使用`module_param_array(ARRAY_NAME, ARRAY_TYPE, ARRAY_LONGTH, READ_WRITE_PERMISSION)`来设置参数数组。

&emsp;&emsp;模块被加载后，在`/sys/module/`目录下将出现以此模块命名的目录。当`READ_WRITE_PERMISSION`为0时，表示此参数不存在`sysfs`文件系统下对应的文件节点，如果此模块存在读写权限不为0的命令行参数，在此模块的目录下还将出现parameters目录，其中包括一系列以参数名命名的文件节点，这些文件的权限值就是传入`module_param()`的参数读写权限，而文件的内容为参数的值。

运行`insmod`或`modprobe`命令时，应用逗号分隔输入的数组元素。

&emsp;&emsp;下面是一个带参数的内核模块示例：

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static char* bookName = "book_name";
module_param(bookName, charp, S_IRUGO);

static int bookNum = 1;
module_param(bookNum, int, S_IRUGO);

static int __init book_init()
{
    printk(KERN_INFO "book name is %s\n", bookName);
    printk(KERN_INFO "book num is %d\n", bookNum);
    return 0
}
module_init(book_init);

static void __exit book_exit()
{
    // do nothing
}
module_exit(book_exit);

MODULE_LICENSE("GPL v2");
```

## 六、导出符号

&emsp;&emsp;Linux的`/proc/kallsyms`文件对应着内核符号表，它记录了符号以及符号所在的内存地址。模块可以使用如下宏导出：

```c
EXPORT_SYMBOL(_SYMBOL_NAME_);
EXPORT_SYMBOL_GPL(_SYMBOL_NAME_);
```

导出的符号可以被其他模块使用，只需要在使用前声明即可。`EXPORT_SYMBOL_GPL()`只适用于包含GPL许可权的模块。如下是一个导出加减法函数的实例：

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

int add_int(int a, int b)
{
    return a + b;
}
EXPORT_SYMBOL(add_int);

int sub_int(int a, int b)
{
    return a - b;
}
EXPORT_SYMBOL(sub_int);

MODULE_LICENSE("GPL v2");
```

从`/proc/kallsyms`文件中可以找出`add_int`和`sub_int`的相关信息。

## 七、模块声明与描述

&emsp;&emsp;在Linux内核模块中，我们常用如下函数来声明模块的作者等信息：

1. `MODULE_AUTHOR(author)`，模块作者。
2. `MODULE_DRSCRIPTION(description)`，模块描述。
3. `MODULE_VERSION(version_string)`，模块版本。
4. `MODULE_DEVICE_TABLE(table_info)`，设备表。
5. `MODULE_ALIAS(alternate_name)`，别名。

对于USB和PCI等驱动设备，通常会建一个`MODULE_DEVICE_TABLE`，以表明该模块所支持的设备：

```c
static struct usb_device_id skel_table[] = 
{
    { USB_DEVICE(USB_SKEL_VENDOR_ID, USB_SKEL_PRODUCT_ID) },
    { /* terminating enttry */ }
};
```

在后续的章节中我们将介绍`MODULE_DEVICE_TABLE`的作用。

## 八、模块的使用计数

&emsp;&emsp;Linux 2.6之后的内核提供了模块计数接口`try_module_get(&module)`和`module_put(&module)`，以取代2.4当中的宏。模块的使用计数一般不必由模块自身管理，而且模块计数管理还考虑了SMP与PREEMPT的影响。

```c
int try_module_get(struct module* module);
```

该函数用于增加模块的计数；若返回0则表示调用失败，希望使用的模块没有被加载或正在被卸载。

```c
void module_put(struct module* module);
```

该函数用于减少模块的计数。

## 九、模块的编译

&emsp;&emsp;我们尝试为之前的myHelloWorld模块写一个Makefile：

```Makefile
KVERS = $(shell uname -r)

# Kernel Modules
obj-m += hello.o

build: kernel_modules

kernel_modules:
    make -C /lib/modules/$(KVERS)/build M=$(CURDIR) modules
clean:
    make -C /lib/modules/$(KVERS)/build M=$(CURDIR) clean
```