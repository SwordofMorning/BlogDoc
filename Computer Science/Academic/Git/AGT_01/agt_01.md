# Advanced Git Tutorial

## 一、工作流程

&emsp;&emsp;为了了解git是如何工作的，我们首先需要知道代码在什么地方。对于使用git管理的项目，主要会有如下4个位置用来存放代码：

1. Working Directory: 我们本地编辑代码的位置，也就是我们从编辑器中看见的代码；
2. Staging Area: Committing之前的的临时保存点；
3. Local Repository: 本地存储更改的地方；
4. Remote Repository: 类似Github用于备份、共享的服务器。

&emsp;&emsp;下面我们来看一下常用的git命令是如何在这四个地方移动代码的。

<!-- 图1 -->

### 1.1 clone

&emsp;&emsp;当我们使用`git clone`的时候，代码从远程仓库拷贝到本地仓库。

### 1.2 checkout

&emsp;&emsp;将本地仓库中的代码切换到我们的本地文件，使得我们可以在编辑器中查看。通常来说，一般使用`git clone`包含了切换到`master`分支这一选项，因此我们可以直接在本地找到相应的文件，不需要手动的`checkout`一次。

### 1.3 add

&emsp;&emsp;将代码添加到暂存区，此时不影响本地或远程仓库。

### 1.4 commit

&emsp;&emsp;将暂存区中所有文件提交到本地仓库，并生成相应的提交记录。

### 1.5 push

&emsp;&emsp;将本地仓库的记录同步到远程仓库。

### 1.6 fetch

&emsp;&emsp;将远程仓库的记录同步到本地。

### 1.7 merge

&emsp;&emsp;将本地仓库的代码与当前工作目录的代码进行合并。

### 1.8 pull

&emsp;&emsp;相当于`fetch` + `merge`，直接将当前工作目录的代码和远程仓库的代码合并。

## 二、分支合并

&emsp;&emsp;`git checkout`和`git switch`允许我们切换分支：

<!-- 图2 -->

&emsp;&emsp;`git merge`允许我们合并分支，参数`--no-ff`指定了不使用fast forward的合并方式。

<!-- 图3 -->

&emsp;&emsp;`git rebase`则可以作为一种显式的`ff`进行合并：

