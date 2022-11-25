# Linux Driver Programming 02 File System and Device File

[toc]

&emsp;&emsp;在本节中，我们将介绍Linux下的藉由Linux API或C库实现的文件操作。

## 一、Linux文件操作

### 1.1 文件操作系统调用

&emsp;&emsp;Linux的文件操作API涉及创建、打开、读写和关闭文件。

#### 1 创建文件

```c
int creat(const char* filename, mode_t mode);
```
&emsp;&emsp;参数mode指定新建文件的存取权限，它同`umsak`一起决定文件的最终权限(mode&mask)。其中，umask代表了文件在创建时需要去掉的一些存取权限。umask可以通过系统调用`umask()`来改变：

```c
int umask(int newmask);
```

改调用将umask设置为newmask，返回旧的umask，它只影响*读*、*写*和*执行*权限。

#### 2 打开

```c
int open(const char* pathname, int flags);
int open(const char* pathname, int flags, mode_t mode);
```

&emsp;&emsp;`open()`函数有两个形式，其中pathname是打开的文件名（包含路径），flags可以是下表中的一个值或几个值的组合。

|   标志    |                             含义                             |
| :-------: | :----------------------------------------------------------: |
| O_RDONLY  |                             只读                             |
| O_WRONLY  |                             只写                             |
|  O_RDWR   |                             读写                             |
| O_APPEND  |                             追加                             |
|  O_CREAT  |                             创建                             |
|  O_EXEC   | 如果使用了O_CREAT且文件已存在，则发生错误。可用于测试文件是否存在 |
| O_NOBLOCK |                  以非阻塞的方式打开一个文件                  |
|  O_TRUNC  |               如果文件已经存在，则删除文件内容               |

O_RDONLY、O_WRONLY、O_RDWR三个标志只能选其一。

&emsp;&emsp;<font color = "red">注意：</font>如果使用了O_CREAT标志,则使用的函数是`int open(const char* pathname, int flags, mode_t mode)`。此时还需指定其mode标志，以表示其访问权限。mode可以是下表中的值的组合。

|  标志   |         含义         |
| :-----: | :------------------: |
| S_IRUSR |       用户可读       |
| S_IWUSR |       用户可写       |
| S_IXUSR |      用户可执行      |
| S_IRWXU |  用户可读、写、执行  |
| S_IRGPR |        组可读        |
| S_IWGPR |        组可写        |
| S_IXGPR |       组可执行       |
| S_IRWXG |   组可读、写、执行   |
| S_IROTH |      其他人可读      |
| S_IWOTH |      其他人可写      |
| S_IXOTH |     其他人可执行     |
| S_IRWXO | 其他人可读、写、执行 |
| S_ISUID |    设置用户执行ID    |
| S_ISGID |     设置组执行ID     |

&emsp;&emsp;除了使用上表的宏进行“或”之外，还可以使用数字来指定其权限：

> Linux使用5个数字来表示其权限，第一位表示用户ID，第二位表示组ID，第三位表示用户自己的权限，第四位表示组的权限，第五位表示其他人的权限。

如果要创建一个*用户可读、写、执行；组无权限；其他人可读、执行*的文件，则是：

1. 第1位：1，设置用户ID。
2. 第2位：0，不设置组ID。
3. 第3位：7，（1+2+4），可读、可写、可执行。
4. 第4位：0，无权限。
5. 第5位：5，（1+4），可读、可执行。

```c
open("test", O_CREAT, 10 705);
// equal
open("test", O_CREAT, S_IRWXU | S_IROTH | S_IXOTH | S_ISUID);
```

#### 3 读写

&emsp;&emsp;在打开文件之后，我们才可以对刚才的文件进行读写，Linux系统提供接口是`read`和`write`函数：

```c
int read(int fd, const void* buf, size_t length);
int write(int fd, const void* buf, size_t length);
```

其中，参数`buf`为指向缓冲区的指针，`length`为缓冲区大小（以字节为单位）。函数`read()`实现从文件描述符fd中所指定的文件读取length个字符到buf所指向的缓冲区中，返回值为实际读取的字节数。`write()`函数与之相反，则是从buf所指向的缓冲区读取length个字节到fd所指的文件中，并返回实际写入的字节数。

#### 4 定位

&emsp;&emsp;对于随机文件，我们可以随机指定位置进行读写，使用如下函数进行定位：

```c
int lseek(int fd, offset_t offset, int whence);
```

`lseek()`将文件读写指针相对`whence`移动offset个字节。操作成功时，返回文件指针相对于文件头的位置。参数`whence`可使用下述值：

1. `SEEK_SET`：相对文件开头。
2. `SEEK_CUR`：相对文件读写指针的当前位置。
3. `SEEK_END`：相对文件末尾。

offset可以取负值，例如下述调用可将文件指针相对当前位置向前移动5个字节：

```c
lseek(fd, -5, SEEK_CUR);
```

由于lseek函数的返回值的返回值为文件的文件头位置，因此可以使用`lseek(fd, 0, SEEK_END);`来测量文件的长度。

#### 5 关闭

&emsp;&emsp;当我们操作完成后，要关闭文件，此时，只用调用class就可以了，其中fd是我们要关闭的文件描述符。

```c
int close(int fd);
```

例程：编写一个程序，在当前目录下创建一个可读写文件`hello.txt`，在其中写入`hello world`，并关闭程序。之后再次打开该文件，并将内容打印出来。

```c
// in user space

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>

#define LENGTH 100

int main()
{
    int fd;
    char str[LENGTH];

    // create file and specify permission
    fd = open("hello.txt", O_CREAT | O_RDWR, S_IRUSR | S_IWUSR);
    if (!fd) return -1;

    // write sth
    write(fd, "Hello World", strlen("Hello World"));
    close(fd);

    // read sth
    fd = open("hello.txt", O_RDWR);
    int len = read(fd, str, LENGTH);
    str[len] = '\0';
    printf("%s\n", str);
    close(fd);

    return 0;
}
```

### 1.2 C库文件操作

&emsp;&emsp;C库函数的文件操作实际上独立于具体的操作平台，无论是DOS、Windows还是Linux中，都是相同的函数：

#### 1 创建和打开

```c
FILE* fopen(const char* path, const char* mode);
```

&emsp;&emsp;`fopen()`用于打开指定的文件`filename`，其中`mode`为打开模式，C库函数中支持的打开模式如下表所示：

|     标志     |                    含义                    |
| :----------: | :----------------------------------------: |
|    r、rb     |                    只读                    |
|    w、wb     |                    只写                    |
|    a、ab     |                    追加                    |
| r+、r+b、rb+ |                    读写                    |
| w+、w+b、wb+ | 读写，如果不存在则新建文件，否则文件被截断 |
| a+、a+b、ab+ |  以读和追加的方式打开，如果不存在，则新建  |

其中，b用于区分二进制和文本文件，DOS和Windows区分二者，但是Linux并不区分。

#### 2 读写

&emsp;&emsp;C库函数支持以字符、字符串为单位，按照某种格式进行文件的读写，这一组函数为：

```c
int fgetc(FILE *stream);
int fputc(int c, FILE* stream);
char* fgets(char *s, int n, FILE* stream);
int fputs(const char* s, FILE* stream);
int fprintf(FILE* stream, const char* format, ...);
int fscanf(FILE* stream, const char* format, ...);
size_t fread(void* ptr, size_t size, size_t n, FILE* stream);
size_t fwrite(const void* ptr, size_t size, size_t n, FILE* stream);
```

&emsp;&emsp;`fread()`实现从stream中读取n个字符，每个字段为size字节，并将读取的字段放入ptr所指向数组中，返回实际读取的字段数。当读取的字段数小于num时，可能是在函数调用调用阶段出现了错误，也可能是读取到了文件的结尾。因此要通过调用`feof()`和`ferror()`来判断。

&emsp;&emsp;`write()`实现从缓冲区ptr指的数组把n个字段写到stream中，每个字段长度为size个字节，返回实际写入的字段数。

&emsp;&emsp;另外，C库还提供了读写过程中的定位能力，这些函数包括：

```c
int fgetpos(FILE* stream, fpos_t* pos);
int fgetpos(FILE* stream, const fpos_t* pos);
int fseek(FILE* stream, long offset, int whence);
```

#### 3 关闭

&emsp;&emsp;利用C库关闭文件：

```c
int fclose(FILE* stream);
```

下面是一个简单的示例：

```c
#include <stdio.h>

#define LENGTH 100

int main()
{
    FILE* fd;
    char str[LENGTH];

    fd = fopen("hello.txt", "w+");
    if (!fd) return -1;
    fputs("Hello World", fd);
    fclose(fd);

    fd = fopen("hello.txt", "r");
    fgets(str, LENGTH, fd);
    printf("%s\n", str);
    fclose(fd);

    return 0;
}
```

## 二、文件系统

### 2.1 Linux文件系统

&emsp;&emsp;进入Linux根目录，使用`ls -l`命令，可以看到如下目录：

#### /bin

&emsp;&emsp;包含基本命令，如`ls`、`cp`、`mkdir`等，这个目录中的文件都是可执行的。

#### /sbin

&emsp;&emsp;包含系统命令，如`modprobe`、`hwclock`、`ifconfig`等。其中大多数命令均为涉及系统管理的命令。

#### /dev

&emsp;&emsp;设备文件存储目录，应用程序通过对这些文件的读写和控制以访问实际的设备。

#### /etc

&emsp;&emsp;系统配置文件所在地，一些服务器的配置文件也在这里，如用户账号密码等。busybox的启动脚本也放在此处。

#### /lib

&emsp;&emsp;库目录。

#### /mnt

&emsp;&emsp;一般用于存放挂载存储设备的挂在目录，比如含有cdrom等目录。可以参考`/etc/fsab`的定义。

#### /opt

&emsp;&emsp;optional，可选项，包含了一些软件的安装包。

#### /proc

&emsp;&emsp;操作系统运行时，进程及内核信息（比如CPU、硬盘分区、内存信息等）存放在这里。proc目录为伪文件系统proc的挂载目录，proc并非真正的文件系统，它存在于内存之中。

#### /tmp

&emsp;&emsp;系统运行是的临时文件存放目录。

#### /usr

&emsp;&emsp;存放程序的目录，如用户命令、库等。

#### /var

&emsp;&emsp;variable，指该目录经常发生变化，如`/var/log`目录经常被用来存放系统日志。

#### /sys

&emsp;&emsp;Linux 2.6之后的内核所支持的sysfs文件系统被映射在此目录上。Linux设备驱动模型中的总线、驱动和设备都可以在sysfs文件系统中找到对应的节点。当内核检测到在系统中发现了新设备之后，内核会在sysfs中为该新设备生成一项新的记录。

### 2.2 文件系统与设备驱动

&emsp;&emsp;如图1所示为Linux中的虚拟文件系统、磁盘/flash文件系统及一般的设备文件与驱动程序之间的关系。

[caption width="835" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Linux/DriverProgramming/01/01.png" width="835" height="565" alt="图1" class="size-full" /> 图1：文件系统与设备驱动[/caption]

&emsp;&emsp;应用程序和VFS之间的接口是系统调用，而VFS与文件系统及设备文件之间的接口是file_operations结构体成员函数，这个结构体包含对文件进行打开、关闭、读写控制的一系列成员函数。

&emsp;&emsp;由于字符设备的上层没有类似于磁盘的ext2等文件系统，所以字符设备的file_operations成员函数直接由驱动提供，在后面的章节我们会看到，file_operations正是字符设备驱动的核心。块设备有两种访问方法，一种是不通过文件系统直接访问裸设备，在Linux内核中实现了统一的`def_blk_fops`这一file_operations，源码位于`fs/block_dev.c`，当我们运行类似于`dd if=/dev/sdb1 of=sdb1.img`类似的命令时，内核以`def_blk_fops`实现；另一种则是通过文件系统来访问设备，file_operations的实现位于文件系统内，文件系统会把针对文件的读写转换为针对设备原始扇区的读写。ext2、fat、Btrfs等文件系统会实现针对VFS的file_operations成员函数，设备驱动层将看不到file_operations的存在。

#### 1 file结构体

&emsp;&emsp;file结构体表示一个打开的文件，系统中每个打开的文件在内核空间中都会有一个关联的struct file。它由内核在打开文件时创建，并传递给在文件上进行操作的任何函数。在文件的所有实例关闭后，内核释放该数据结构。在内核和驱动代码中，struct file的指针通常被命名为file或filp（file pointer）。

```c
struct file {
        union {
           struct llist_node         fu_llist;
            struct rcu_head          fu_rcuhead;
        } 
        f_u;
        struct path               f_path;
        struct inode              *f_inode;/* cached value */
        const struct file_operations      *f_op;/* 和文件关联的操作 */
        /*
         * Protects f_ep_links, f_flags.
         * Must not be taken from IRQ context.
         */
        spinlock_t                f_lock;
        enum rw_hint              f_write_hint;
        atomic_long_t              f_count;
        unsigned int              f_flags;/* 文件标志，如O_RDONLY、O_NONBLOCK、O_SYNC */
        fmode_t                 f_mode;/* 文件读/写模式，FMODE_READ、FMODE_WRITE */
        struct mutex              f_pos_lock;
        loff_t                  f_pos;/* 当前读写位置 */
        struct fown_struct        f_owner;
        const struct cred        *f_cred;
        struct file_ra_state        f_ra;
        u64                f_version;

        #ifdef CONFIG_SECURITY
        void *f_security;
        #endif
        /* needed for tty driver, and maybe others */
        void *private_data; /* 文件私有数据 */
        #ifdef CONFIG_EPOLL
        /* Used by fs/eventpoll.c to link all the hooks to this file */
        struct list_head f_ep_links;
        struct list_head f_tfile_llink;
        #endif /* #ifdef CONFIG_EPOLL */
        struct address_space *f_mapping;
        errseq_t f_wb_err;
    }
    __randomize_layout
    __attribute__((aligned(4)));/* lest something weird decides that 2 is OK */
  
    struct file_handle {
        __u32 handle_bytes;
        int handle_type;
        /* file identifier */
        unsigned char f_handle[0];
    };
```

&emsp;&emsp;文件读写模式mode、标志f_flag都是设备驱动关心的内容，而私有数据指针private_data在设备驱动中被广泛应用，大多指向设备驱动自定义以用于描述设备的结构体。

&emsp;&emsp;下面的代码可以用来判断是以阻塞还是非阻塞的方式打开设备文件：

```c
if (file->f_flags & O_NONBLOCK)
    pr_debug("open: non-blocking\n");
else
    pr_debug("open: blocking\n");
```

#### 2 inode结构体

&emsp;&emsp;VFS inode包含对文件访问的权限、属主、大小、生成时间、访问时间及最后修改时间等信息。它是Linux文件管理系统的最基本单位，也是文件系统连接任何子目录、文件的桥梁：

```c
struct inode{
    // ...

    // inode的权限
    umode_t i_mode;
    // inode拥有者的id
    uid_t i_uid;
    // inode所属群组id
    gid_t i_gid;
    // 若是设备文件，此字段将记录设备的设备号
    dev_t i_rdev;
    // inode设备的文件大小
    ioff_t i_size;

    // inode最近一次的存取时间
    struct timespec i_atime;
    // inode最近一次的修改时间
    struct timespec i_mtime;
    // inode的生产时间
    struct timespec i_ctime;

    unsigned int i_blkbits;
    // inode 使用的block数
    blkcnt_t i_blocks;
    union{
        struct pipe_inode_info* i_pipe;
        struct block_device* i_bdev;
        struct cdev* i_cdev;
        /*
            若是块设备，对应block_device结构体指针
            若是字符设备，对应cdev结构体指针
        */
    }

    //...
}
```

&emsp;&emsp;对于表示设备文件的inode结构，i_rdev字段包括设备编号。Linux内核设备编号分为主设备编号和次设备编号，前者为dev_t的高12位，后者为dev_t的低20位。下列操作用于从一个inode中获得主设备和次设备号：

```c
unsigned int iminor(struct inode* inode);
unsigned int imajor(struct inode* inode);
```

&emsp;&emsp;查看`/proc/devices`文件可以获知系统中注册的设备，第1列为主设备，第2列为设备名。查看`/dev`目录可以获知系统中包含的设备文件。主设备号是与驱动相对应的概念，同一类设备会有不同的主设备号，不同的设备一般使用不同的主设备号。因为同一驱动可以支持多个同类设备，因此用设备号来描述该驱动的设备序号，序号一般从0开始。

&emsp;&emsp;内核Document目录下的device.txt文件描述了Linux设备号的分配情况。

## 三、devfs

&emsp;&emsp;设备文件系统（devfs）由Linux 2.4内核引入，它的引入使得设备驱动程序能自主的管理自己的设备文件。具体来说，devfs具有如下优点：

1. 可以通过程序在设备初始化时，在`/dev`目录下创建设备文件，卸载设备时将它删除。
2. 设备驱动程序可以指定设备名、所有者和权限位，用户空间程序仍可以修改所有者和权限位。
3. 不再需要为设备驱动程序分配主设备号以及处理次设备号，在程序中可以直接向`register_device()`传递0主设备号以获得可用的设备号，并在`devfs_register()`中指定次设备号。

&emsp;&emsp;驱动程序调用下面这些函数来进行文件的创建和撤销工作。

```c
// 创建设备目录
devfs_handle_t devfs_mk_dir(devfs_handle_t dir, const char* name, void* info);
// 创建设备文件
devfs_handle_t devfs_register(devfs_handle_t dir, const char* name, unsigned int flags, unsigned major, unsigned minor, umode_t mode, void* ops, void* info);
// 撤销设备文件
void devfs_unregister(devfs_handle_t de);
```

## 四、udev用户空间设备管理

&emsp;&emsp;尽管devfs有这样或那样的优点，但是在Linux 2.6中，udev代替了devfs。