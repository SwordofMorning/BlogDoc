# Linux Driver Programming 03 Char Driver

&emsp;&emsp;本章将了解Linux字符设备驱动的关键，并基于globalmem开展一系列的实验。

## 一、字符设备驱动结构

### 1.1 cdev结构体

&emsp;&emsp;在Linux内核中，使用cdev结构体描述一个字符设备，cdev的定义如下：

```c
struct cdev
{
    // 内嵌kobj对象
    struct kobject kobj;
    // 所属模块
    struct module* owner;
    // 文件操作结构体
    struct file_operations* ops;
    struct list_head list;
    // 设备号
    dev_t dev;
    unsigned int count;
}
```

&emsp;&emsp;cdev结构体的dev_t成员定义了设备号，为32位，其中12位为主设备号，20位为次设备号。使用下列宏可以从dev_t获得设备号：

```c
MAJOR(dev_t dev)
MINOR(dev_t dev)
```

而使用下列宏则可以通过主设备号和次设备号生成dev_t：

```c
MKDEV(int major, int minor)
```

&emsp;&emsp;cdev结构体的另一个重要成员file_operation定义了字符设备驱动提供给虚拟文件系统的接口函数。Linux提供了一系列用于操作cdev结构体的函数：

```c
void cdev_init(struct cdev* , struct file_operations*);
struct cdev* cdev_alloc();
void cdev_put(struct cdev*);
int cdev_add(struct cdev*, dev_t, unsigned);
int cdev_del(struct cdev*);
```

&emsp;&emsp;``cdev_init()``用于初始化cdev的成员，并建立cdev和file_operations之间的连接，其源代码如下所示：

```c
void cdev_init(struct cdev* cdev, struct file_oprations* fops)
{
    memset(cdev, 0, sizeof *cdev);
    INIT_LIST_HEAD(&cdev->list);
    kobjec_init(&cdev->kobj, &ktype_cdev_default);
    cdev->ops = fops;
}
```

&emsp;&emsp;`cdev_alloc()`函数用于动态申请一个cdev内存，其源代码如下所示：

```c
struct cdev* cdev_alloc()
{
    struct cdev* p = kzalloc(sizeof(struct cdev), GFP_KERNEL);
    if (p)
    {
        INIT_LIST_HEAD(&p->list);
        kobject_init(&p->kobj, &ktype_cdev_dynamic);
    }
    return p;
}
```

&emsp;&emsp;`cdev_add()`和`cdev_del()`分别向系统添加和删除一个cdev，完成字符设备的注册和注销。对`cdev_add()`的调用通常发生在字符设备驱动模块加载函数中，而对`cdev_del()`的调用通常发生在字符设备驱动的卸载函数中。

### 1.2 分配和释放设备号

&emsp;&emsp;在调用`cdev_add()`函数向系统注册字符设备之前，首先应该调用`register_chrdev_region()`或`alloc_chrdev_region()`向系统申请设备号，两个函数的原型为：

```c
int register_chrdev_region(dev_t from, unsigned count, const char* name);
int alloc_chrdev_region(dev_t* dev, unsigned baseminor, unsigned count, const char* name);
```

&emsp;&emsp;`register_chrdev_region()`用于已知起始设备的设备号的情况，而`alloc_chrdev_region()`用于设备号未知，向系统动态申请未被占用的设备号的情况，函数调用成功后，会把得到的设备号放入第一个参数`dev`中。`alloc_chrdev_region()`与`register_chrdev_region()`相比，优点在于自动避开与其他的设备号冲突。

&emsp;&emsp;相应的，在调用`cdev_del()`从系统注销字符设备驱动之后，`unregister_chrdev_region()`应该被调用以释放原先申请的设备号，这个函数原型为：

```c
void unregister_chrdev_region(dev_t from, unsigned count);
```

### 1.3 file_oprations结构体

&emsp;&emsp;file_oprations结构体中的成员函数是字符设备驱动设计的主要内容，这些函数实际会在应用程序进行linux的`open()`、`write()`、`read()`和`close()`等操作时被调用。其定义如下所示：

```c
struct file_operations { 
 
    // 拥有该结构的模块的指针，一般为THIS_MODULES 
    struct module *owner;
 
    // 用来修改文件当前的读写位置，并返回新位置，如果出错，则返回一个负值。
    loff_t (*llseek) (struct file *, loff_t, int);
 
    // 从设备中同步读取数据，成功时返回读取的字节数，出错时返回一个负值。
    ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
 
    // 向设备发送数据，成功时返回写入的字节数，出错时返回一个负值。
    ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);

    /*
        read()或write()返回0，则说明EOF
    */
 
    // 初始化一个异步的读取操作
    ssize_t (*aio_read) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
 
    // 初始化一个异步的写入操作 
    ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
 
    // 仅用于读取目录，对于设备文件，该字段为NULL 
    int (*readdir) (struct file *, void *, filldir_t);
 
    // 轮询函数，判断目前是否可以进行非阻塞的读写或写入 
    unsigned int (*poll) (struct file *, struct poll_table_struct *); 
 
    // 执行设备I/O控制命令（既不是读操作，也不是写操作），当调用成功时，给出一个非负的值。
    int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long); 
 
    // 不使用BLK文件系统，将使用此种函数指针代替ioctl 
    long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long); 
    
    // 在64位系统上，32位的ioctl调用将使用此函数指针代替 
    long (*compat_ioctl) (struct file *, unsigned int, unsigned long); 
 
    /* 
        用于请求将设备内存映射到进程虚拟地址空间，如果驱动未实现此功能，用户调用mmap时获得-ENOEV返回值。
        这个函数对于帧缓存设备有特别的意义，帧缓存被映射到用户空间后，应用程序可以之间访问它，而无需在内核与应用程序的内存间复制
    */
    int (*mmap) (struct file *, struct vm_area_struct *); 
 
    // 打开 
    int (*open) (struct inode *, struct file *); 
 
    int (*flush) (struct file *, fl_owner_t id); 
 
    // 关闭 
    int (*release) (struct inode *, struct file *); 
 
    // 刷新待处理的数据 
    int (*fsync) (struct file *, struct dentry *, int datasync); 
 
    // 异步刷新待处理的数据 
    int (*aio_fsync) (struct kiocb *, int datasync); 
 
    // 通知设备FASYNC标志发生变化 
    int (*fasync) (int, struct file *, int); 
 
    int (*lock) (struct file *, int, struct file_lock *); 
 
    ssize_t (*sendpage) (struct file *, struct page *, int, size_t, loff_t *, int); 
 
    unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long); 
 
    int (*check_flags)(int); 
 
    int (*flock) (struct file *, int, struct file_lock *);
 
    ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 
    ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int); 
 
    int (*setlease)(struct file *, long, struct file_lock **); 

    long (*fallocate) (struct file* file, int mode, loff_t offset, lofft_t len);
};
```

### 1.4 字符设备驱动的构成

&emsp;&emsp;在Linux中，字符设备驱动由以下几个部分组成：

1. 加载、卸载函数。
2. file_oprations。

#### 1 加载、卸载函数

&emsp;&emsp;加载函数实现：设备号的申请和cdev的注册；卸载函数则相反。Linux内核的编码习惯是为设备定义一个设备相关的结构体，该结构体包含设备所设计的cdev、私有数据及锁信息。加载、卸载函数模板如下：

```c
// 设备结构体
struct xxx_dev_t
{
    struct cdev cdev;
    // ...
}xxx_dev;

// 加载函数
static int __init xxx_init()
{
    // ...

    // 初始化cdev
    cdev_init(&xxx_dev.cdev, &xxx_fops);
    xxx_dev.cdev.owner = THIS_MODULE;

    // 获取设备号
    if (xxx_major)
    {
        register_chrdev_region(xxx_dev_no, 1, DEV_NAME);
    }
    else
    {
        alloc_chrdev_region(&xxx_dev_No, 0, 1, DEV_NAME);
    }

    // 注册设备
    ret = cdev_add(&xxx_dev.cdev, xxx_dev_no, 1);
}

// 卸载函数
static void __exit xxx_init()
{
    // ...
    
    unregister_chrdev_region(xxx_dev_no, 1);
    cdev_del(&xxx_dev.cdev);

    // ...
}
```

#### 2 file_operations成员函数

&emsp;&emsp;file_operations结构体中的成员函数是字符设备驱动与内核虚拟文件系统的接口，是用户空间Linux进行进行系统调用的落实者。大多数字符设备驱动会实现read()、write()和ioctl()函数，常见的字符设备驱动的这三个函数形式如下所示：

```c
ssize_t xxx_read(struct file* filp, char __user* buf, sizt_t count, loff_t* f_pos)
{
    // ...

    copy_to_user();

    // ...
}

ssize_t xxx_write(struct file* filp, const char __user* buf, size_t count, loff_t* f_pos)
{
    // ...

    copy_from_user();

    // ...
}

long xxx_ioctl(struct file* filp, unsigned int cmd, unsigned long arg)
{
    // ...

    switch (cmd)
    {
        case XXX_CMD1:
            // ...
            break;
        case XXX_CMD2:
            // ...
            break;
        default:
            // ...
            return -ENOTTY;
    }

    return 0;
}
```

&emsp;&emsp;设备驱动的读写函数中，`filp`是文件结构体指针；`buf`是用户空间内存的地址，该地址在内核空间不能直接读写；`count`是要读写的字节数；`f_ops`是读写位置相对于文件开头的偏移量。

&emsp;&emsp;由于用户空间不能直接访问内核空间的内存，因此借助了函数`copy_from_user()`和`copy_to_user()`来完成用户空间与内核空间直接的内存交换。其原型为：

```c
unsigned long copy_from_user(void* to, const void __user* from, unsigned long count);
unsigned long copy_to_user(void __user* to, const void* from, unsigned long count);
```

&emsp;&emsp;上述函数返回**不能被复制的字节数**，因此如果完全复制成功，则返回0。如果要复制的内存是简单类型，如`char`、`int`、`long`等，可以使用`put_user()`和`get_user()`完成：

```c
// 内核空间int变量
int val;
// 用户->内核，arg是用户空间地址
get_user(val, (int*)arg);
// 内核->用户，arg是用户空间地址
put_user(val, (int*)arg);
```

&emsp;&emsp;读和写函数中的`__user`是一个宏，表明其后的指针指向用户空间。

&emsp;&emsp;内核空间虽然可以访问用户空间的缓冲区，但是在访问之前，一般需要先检查其合法性，通过`access_ok(type, addr, size)`进行判断，确保其传入的缓冲区属于用户空间：

```c
static ssize_t read_port(struct file* file, char __user* buf, size_t count, loff_t* ppos)
{
    unsigned long i = *ppos;
    char __user* tmp = buf;

    if (!access_ok(VERTIFY_WRITE, buf, count))  return -EFAULT;

    while(count-- > 0 && i < 65536)
    {
        if(__put_user(inb(i), tmp) < 0) return -EFAULT;

        i++;
        tmp++;
    }
    *ppos = i;
    return tmp - buf;
}
```

&emsp;&emsp;在上述代码中，`__put_user()`与`put_user()`的区别在于，前者不进行`access_ok()`的检查，而后者会指向这一检查。在上述代码中，因为我们以及手动地使用了`access_ok()`检查用户空间缓存区`buf + count`，因此直接使用`__put_user()`而无需重复检查。同样的，`get_user()`和`__get_user()`也有相同的用法；`copy_from_user()`和`copy_to_user()`内部同样进行了该种检查。

&emsp;&emsp;IO控制函数的`cmd`参数为事先定义的IO控制命令，而`arg`为对应该命令的参数。例如，对于串口设备，如果`SET_BAUDRATE`是一道设置波特率的命令，则其后的`arg`就是波特率值。

&emsp;&emsp;在字符设备驱动中，需要定义一个file_operations的实例，并将具体设备驱动的函数赋值给file_operations的成员：

```c
struct file_operations xxx_fops
{
    .owner = THIS_MODULE;
    .read = xxx_read;
    .write = xxx_write;
    .unlocked_ioctl = xxx_ioctl;
    // ...
}
```

[caption width="1041" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Linux/DriverProgramming/03/01.png" width="1041" height="442" alt="图1" class="size-full" /> 图1：字符驱动设备结构[/caption]

## 二、globalmem虚拟内存设备实例描述

&emsp;&emsp;从本节之后的章节，都将基于虚拟globalmem设备进行字符设备驱动的编写。globalmem意味着“全局内存”，在globalmem字符设备驱动中会分配一片大小为GLOBALMEM_SIZE（4KB）的内存空间，并在驱动中提供针对此片的读写、控制和定位函数，以提供用户空间进程能通过Linux系统调用来读写这篇内存的内容。

&emsp;&emsp;实际上，这个虚拟的globalmem设备并没有什么实际作用，仅仅是一个演示用的实例。本节将给出这个驱动的雏形，后面会完善这一驱动。

## 三、globalmem设备驱动

### 3.1 头文件、宏以及设备结构体

```c
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/cdev.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

#define GLOBALMEM_SIZE 0x1000
#define MEM_CLEAR 0x1
#define GLOBALMEM_MAJOR 230

static int globalmem_major = GLOBALMEM_MAJOR;
module_param(globalmem_major, int, S_SIRUGO);

/**
    @brief globalmem_dev package cdev & mem
 */
struct globalmem_dev
{
    struct cdev cdev;
    unsigned char mem[GLOBALMEM_SIZE];
};

struct globalmem_dev* globalmem_devp;
```

### 3.2 加载与卸载设备驱动

```c
/**
    @brief 完成cdev的初始化与添加
 */
static void globalmem_setup_cdev(struct globalmem_dev* dev, int index)
{
    int err;
    int devno = MKDEV(globalmem_major, index);

    cdev_init(&dev->cdev, &globalmem_fops);
    dev->cdev.owner = THIS_MODULE;
    err = cdev_add(&dev->cdev, devno, 1);

    if (err) printk(KERN_NOTICE "Error %d adding gloablmem%d", err, index);
}

static int __init globalmem_init()
{
    // 设备号申请
    if (globalmem_major)
        ret = register_chrdev_region(devno, 1, "globalmem");
    else
    {
        ret = alloc_chrdev_region(&devno, 0, 1, "globalmem");
        globalmem_major = MAJOR(devno);
    }
    if (ret < 0) return ret;

    // 申请globalmem_dev结构体的内存
    globalmem_devp = kzalloc(sizeof(struct globalmem_dev), GFP_KERNEL);
    if (!globalmem_devp)
    {
        ret = -ENOMEM;
        goto fail_malloc:
    }

    // 并清0
    globalmem_setup_cdev(globalmem_devp, 0);
    return 0;

fail_malloc:
    unregister_chrdev_region(devno, 1);
    return ret;
}
module_init(globalmem_init);
```

&emsp;&emsp;在`globalmem_init()`中，与globalmem的dev关联的file_operations结构体如下所示：

```c
static const struct file_operations globalmem_fops = {
    .owner = THIS_MODULE,
    .llseek = globalmem_llseek,
    .read = globalmem_read,
    .write = globalmem_write,
    .unlocked_ioctl = globalmem_ioctl,
    .open = globalmem_open,
    .release = globalmem_release,
};
```

### 3.3 读写函数

&emsp;&emsp;globalmem设备驱动的读写函数主要功能是让设备结构体的`mem[]`数组与用户空间交互数据，并且随着访问字节数的更变更新文件读写位置的便宜。读写函数的实现如下所示：

```c
static ssize_t globalmem_read(struct file* filp, char __user* buf, size_t size, loff_t* ppos)
{
    unsigned long p = *ppos;
    unsigned int count = size;
    int ret = 0;
    struct globalmem_dev* dev = file->private_data;

    // *ppos读取的位置是相对于文件开头的偏移，如果偏移量大于或等于GLOBALMEM_SIZE
    // 则表示已经到达文件结尾，所以返回0(EOF)
    if (p >= GLOBALMEM_SIZE) return 0;

    count = count > GLOBALMEM_SIZE - p ?
        GLOBALMEM_SIZE - p :
        0;

    if (copy_to_user(buf, dev->mem + p, count))
        ret = -EFAULT;
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_NOTICE "read %u bytes from %lu\n", count, p);
    }

    return ret;
}

static ssize_t globalmem_write(struct file* filp, const char __user* buf, size_t size, loff_t* ppos)
{
    unsigned long p = *ppos;
    unsigned int count = size;
    int ret = 0;
    struct globalmem_dev* dev = filp->private_data;

    if (p >= GLOBALMEM_SIZE) return 0;

    count = count > GLOBALMEM_SIZE - p ?
        GLOBALMEM_SIZE - p :
        0;

    if (copy_from_user(dev->mem + p, buf, count)) 
        ret = -EFAULT;
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_NOTICE "write %u bytes from %lu\n", count, p);
    }
    
    return ret;
}
```

### 3.4 seek函数

&emsp;&emsp;`seek()`函数对文件定位的起始地址可以是文件开头`(SEEK_SET, 0)`、当前位置`(SEEK_CUR, 1)`和文件尾`(SEEK_END, 2)`。假设globalmem支持从文件开头和当前位置的相对偏移。

&emsp;&emsp;在定位时，应该检查用户请求的合法性，如果不合法，返回`-EINVAL`；合法时更新文件的当前位置并返回该位置，如下所示：

```c
static loff_t globalmem_llseek(struct file* filp, loff_t offset, int orig)
{
    loff_t ret = 0;
    switch (orig)
    {
        // 文件开头位置
        case 0:
            if (offset < 0)
            {
                ret = -EINVAL;
                break;
            }
            if ((unsigned int)offset > GLOBALMEM_SIZE)
            {
                ret = -EINVAL;
                break;
            }
            filp->f_ops = (unsigned int)offset;
            ret = filp->f_ops;
            break;
        // 文件当前位置
        case 1:
            if ((filp->f_ops + offset) > GLOBALMEM_SIZE)
            {
                ret = -EINVAL;
                break;
            }
            filp->f_ops += offset;
            ret = filp->f_ops;
            break;
        default:
            ret = -EINVAL;
            break;
    }

    return ret;
}
```

### 3.5 ioctl函数

#### globalmem设备驱动的ioctl()函数

&emsp;&emsp;假设：globalmem设备驱动的`ioctl()`函数接受`MEM_CLEAR`命令，这个命令会将全局内存的所有值置为0；对于不接受的设备命令，返回`-EINVAL`，代码如下所示：

```c
static long globalmem_ioctl(struct* file filp, unsigned int cmd, unsigned long arg)
{
    struct globalmem_dev* dev = filp->private_data;

    switch (cmd)
    {
        // MEM_CLEAR is a macro
        case MEM_CLEAR:
            memset(dev->mem, 0, GLOBALMEM_SIZE);
            printk(KERN_INFO "globalmem is set to 0\n");
            break;
        default:
            return -EINVAL;
    }

    return 0;
}
```

&emsp;&emsp;在上述程序中，`MEM_CLEAR`的值被设置为`0x01`，但这并不是一种推荐的方法。如果设备A和B都支持`0x01`、`0x02`或`0x03`等命令，则可以造成代码污染。因此，Linux内核推荐采用一套统一的ioctl()命令的生成方式。

#### ioctl()命令

&emsp;&emsp;Linux建议的命令如下所示：

| 设备类型 | 序列号 | 方向 | 数据尺寸 |
| :------: | :----: | :--: | :------: |
|   8位    |  8位   | 2位  | 13/14位  |

&emsp;&emsp;命令码的**设备类型**字段为一个“幻数”，可以是`0 ~ 0xFF`的值，内核中的ioctl-number.txt给出了一些推荐和已经使用的“幻数”，新设备使用的“幻数”应该避免与其冲突。

&emsp;&emsp;命令码的**方向**为2位，表示数据的传输方向。可能的值是`_IOC_NONE`（无数据传输）、`_IOC_READ`（读）、`_IOC_WRITE`（写）和`_IOC_READ | _IOC_WRITE`（双向）。**数据传输的方向是从应用程序的方向来看的**。

&emsp;&emsp;命令码数据长度字段表示涉及用户的数据大小，这个成员的宽度依赖于体系结构，通常是13位或者14位。

&emsp;&emsp;内核还定义了`_IO()`、`_IOR()`、`_IOW()`和`_IOWR()`来辅助生成命令，这四个宏通用的代码定义如下所示：

```c
#define _IO(type,nr)            _IOC(_IOC_NONE, (type), (nr), 0)
#define _IOR(type, nr, size)    _IOC(_IOC_READ, (type), (nr), \
                                    (_IOC_TYPECHECK(size)))
#define _IOW(type, nr, size)    _IOC(_IOC_WRITE, (type), (nr), \
                                    (_IOC_TYPECHECK(size)))
#define _IOWR(type, nr, size)   _IOC(_IOC_READ | _IOC_WRITE, (type), (nr), \
                                    (_IOC_TYPECHECK(size)))

#define _IOC(dir,type,nr,size) \
    (((dir)  << _IOC_DIRSHIFT) | \
     ((type) << _IOC_TYPESHIFT) | \
     ((nr)   << _IOC_NRSHIFT) | \
     ((size) << _IOC_SIZESHIFT))
```

由此可见，这几个宏的作用是根据传入的type、nr、size和宏名隐含的方向字段位移组合生成命令码。

&emsp;&emsp;由于globalmem的`MEM_CLEAR`不涉及数据传输，它可以被定义为：

```c
#define GLOBALMEM_MAGIC 'g'
#define MEM_CLEAR _IO(GLOBALMEM_MAGIC, 0)
```

#### 预定义命令

&emsp;&emsp;内核中预定义了一些IO控制命令，如果某设备驱动包含了一些与预定义一样的命令，这些命令会被作为预定义的内核命令被执行，而不是作为设备驱动被处理，例如：

1. `FIOCLEX`：即File IOctl Close on Exec，对文件设置专用标识，通知内核`exec()`系统调用发生时自动关闭打开的文件。
2. `FIONCLEX`：即File IOctl Not Close on Exec，与`FIOCLEX`相反，清楚由`FIOCLEX`创建的标识。
3. `FIOQSIZE`：获得一个文件或目录的大小，当用于设备文件时，返回`ENOTTY`错误。

这些宏定义在内核的`/include/uapi/asm-generic/ioctls.h`文件中。

### 3.6 使用文件私有数据

&emsp;&emsp;在之前的例子中，我们使用`struct globalmem_dev* dev = filp->private_data`来获取`globalmem_dev`的实例指针。但实际上，大多数Linux驱动遵循这么一个规则：将文件私有数据`private_data`指向设备结构体，而`read()`、`write()`通过`private_data`来访问设备结构体。这体现了Linux中面向对象的设计思想。对于globalmem驱动而言，私有数据的设置是在`globalmem_open()`中完成的，代码如下所示：

```c
static int globalmem_open(struct inode* inode, struct file* filp)
{
    filp->private_data = globalmem_devp;
    return 0;
}
```

**下面是完整的globalmem驱动代码**：

```c
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/cdev.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

#define GLOBALMEM_SIZE 0x1000
#define MEM_CLEAR 0x1
#define GLOBALMEM_MAJOR 230

static int globalmem_major = GLOBALMEM_MAJOR;
module_param(globalmem_major, int, S_IRUGO);

// 创建设备结构体
struct globalmem_dev
{
    struct cdev cdev;
    unsigned char mem[GLOBALMEM_SIZE];
};
struct globalmem_dev* globalmem_devp;

static int globalmem_open(struct inode* inode, stuct file* filp)
{
    // 将设备结构体交给private_data
    filp->private_data = globalmem_devp;
    return 0;
}

static int globalmem_release(struct inode* inode, struct file* filp)
{
    return 0;
}

static long globalmem_ioctl(struct file* filp, unsigned int cmd, unsigned long arg)
{
    switch (cmd)
    {
        case MEM_CLEAR:
            memset(dev->mem, 0, GLOBALMEM_SIZE);
            printk(KERN_INFO "globalmem is set to 0\n");
            break;
        default:
            return -EINVAL;
    }
    
    return 0;
}

static ssize_t globalmem_read(struct file* filp, char __user* buf, size_t size, loff_t* ppos)
{
    unsigned long p = *ppos;
    unsigned int count = size;
    int ret = 0;

    // 具体的操作藉由private_data来完成
    struct globalmem_dev* dev = filp->private_data;

    if (p >= GLOBALMEM_SIZE)
        return 0;
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_INFO "read %u bytes from %lu\n", count, p);
    }
    
    return ret;
}

static ssize_t globalmem_write(struct file* filp, const char __user* buf, size_t size, loff_t* ppos)
{
    unsigned long p = *ppos;
    unsigned int count = size;
    int ret = 0;

    struct globalmem_dev* dev = filp->private_data;

    if (p >= GLOBALMEM_SIZE) return 0;

    count = count > GLOBALMEM_SIZE - p ?
        GLOBALMEM_SIZE - p :
        0;

    if (copy_to_user(buf, dev->mem + p, count))
        ret = -EFAULT;
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_NOTICE "read %u bytes from %lu\n", count, p);
    }

    return ret;
}

static loff_t globalmem_llseek(struct file* filp, loff_t offset, int orig)
{
    loff_t ret = 0;
    
    switch (orig)
    {
        case 0:
            if (offset < 0 |
                (unsigned int)offset > GLOBALMEM_SIZE)
            {
                ret = -EINVAL;
                break;
            }
            
            filp->f_ops = (unsigned int)offset;
            ret = filp->f_ops;
            break;
        case 1:
            if ((filp->f_ops + offset) > GLOBALMEM_SIZE |
                (filp->f_ops + offset) < 0)
            {
                ret = -EINVAL;
                break
            }
            filp->f_ops += offset;
            ret = filp->f_ops;
            break;
        default:
            ret = -EINVAL;
            break;
    }

    return ret;
}

static const struct file_operations globalmem_fops = 
{
    .owner = THIS_MODULE,
    .llseek = globalmem_llseek,
    .read = globalmem_read,
    .write = globalmem_write,
    .unlocked_ioctl = globalmem_ioctl,
    .open = globalmem_open,
    .release = globalmem_release,
};

static void globalmem_setup_cdev(struct globalmem_dev* dev, int index)
{
    int err, devno = MKDEV(globalmem_major, index);

    cdev_init(&dev->cdev, &globalmem_fops);
    dev->cdev.owner = THIS_MODULE;

    err = cdev_add(&dev->cdev, devno, 1);

    if (err) printk(KERN_INFO "Error %d adding globalmem%d\n", err, index);
}

static int __init globalmem_init()
{
    int ret;
    dev_t devno = MKDEV(globalmem_major, 0);

    if (globalmem_major) 
        ret = register_chrdev_region(devno, 1, "globalmem");
    else
    {
        ret = alloc_chrdev_region(&devno, 0, 1, "globalmem");
        globalmem_major = MAJOR(devno);
    }

    if (ret  < 0) return ret;

    globalmem_devp = kzalloc(sizeof(struct globalmem_dev), GFP_KERNEL);

    if (!globalmem_devp)
    {
        ret = -ENOMEM;
        goto fail_malloc;
    }

    globalmem_setup_cdev(globalmem_devp, 0);
    return 0;

fail_malloc:

    unregister_chrdev_region(devno, 1);
    return ret;
}
module_init(globalmem_init);

static void __exit globalmem_exit()
{
    cdev_del(&globalmem_devp-cdev);
    kfree(globalmem_devp);
    unregister_chrdev_region(MKDEV(globalmem_major, 0), 1);
}
module_exit(globalmem_exit);

MODULE_AUTHOR("xx");
MODULE_LICENSE("GPL v2");
```

&emsp;&emsp;如果globalmem不包括一个设备，而是同时包括两个以上的设备，采用`private_data`的优势就会集中体现出来。只要修改`globalmem_init()`、`globalmem_exit()`和`globalmem_open()`就可以使得globalmem驱动中包含N个相同的设备（设备号位0~N），改动如下所示：

```c
#define GLOBALMEM_SIZE 0x1000
#define MEM_CLEAR 0x1
#define GLOBALMEM_MAJOR 230
#define DEVICE_NUM 10

static int globalmem_open(struct inode* inode, struct file* filp)
{
    // container_of 通过结构体成员的指针找到对应结构指针
    // 第一个参数是结构体成员的指针，第二个参数是整个结构体的类型，第三个参数是第一个结构体成员的类型
    // 返回整个结构体的指针
    struct globalmem_dev* dev = container_of(inode->i_cdev, struct globalmem_dev, cdev);
    filp->private_data = dev;
    return 0;
}

static int __init globalmem_init()
{
    int ret;
    dev_t devno = MKDEV(globalmem_major, 0);

    if (globalmem_major)
        ret = register_chrdev_region(devno, DEVICE_NUM, "globalmem");
    else
    {
        ret = alloc_chrdev_region(&devno, DEVICE_NUM, "globalmem");
        globalmem_major = MAJOR(devno);
    }

    if (ret < 0) return ret;

    globalmem_devp = kzalloc(sizeof(struct globalmem_dev)* DEVICE_NUM, GFP_KERNEL);

    if (!globalmem_devp)
    {
        ret = -ENOMEM;
        goto fail_malloc;
    }

    for (int i = 0; i < DEVICE_NUM; ++i)
        globalmem_setup_cdev(globalmem_devp + i, i);

    return 0;

fail_malloc:
    unregister_chrdev_region(devno, DEVICE_NUM);
    return ret;
}
module_init(globalmem_init);


static void __exit globalmem_exit()
{
    for (int i = 0; i < DEVICE_NUM; ++i)
        cdev_del((&globalmem_devp + i)->cdev);

    kfree(globalmem_devp);
    unregister_chrdev_region(MKDEV(globalmem_major, 0), DEVICE_NUM);
}
module_exit(global_exit);
```

&emsp;&emsp;