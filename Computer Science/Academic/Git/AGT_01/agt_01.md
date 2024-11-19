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


<!-- 图4 -->

## 三、冷门知识

### 3.1 git blame

1. `git blame <filename>`，逐行显示指定文件的每一行代码是由谁在什么时候引入或修改的；
2. `git blame <filename> -L x,y`，指定查看范围行号的修改；
3. `git blame <filename> -w`，忽略空格；
4. `git blame <filename> -C`，检测在同一提交中移动或复制的行；
5. `git blame <filename> -C -C`，检测在同一个提交或创建文件的提交中移动或复制的行;
6. `git blame <filename> -C -C -C`，检测在同一个提交或创建文件的提交或任何提交中移动或复制的行。

&emsp;&emsp;因此使用`git blame <filename> -w -C -C -C`，可以更好的查询到代码的“最终”责任人。

### 3.2 git log

1. `git log -p <hash/name>`，查看提交的具体补丁；
2. `git log -S <str>`，查找和str有关的提交；
3. `git log -S <str> -p`，查找和str有关的提交，并显示其具体内容。

&emsp;&emsp;`git log -S <str> -p`用于查找仓库中历史更改，尤其是删除的内容十分有效。

### 3.2 git reflog

```log
0b98876 (HEAD -> dev) HEAD@{0}: rebase (finish): returning to refs/heads/dev
0b98876 (HEAD -> dev) HEAD@{1}: rebase (pick): up1
003600d (master) HEAD@{2}: rebase (start): checkout master
5bba514 HEAD@{3}: checkout: moving from master to dev
003600d (master) HEAD@{4}: commit: m
ffb409c HEAD@{5}: checkout: moving from dev to master
5bba514 HEAD@{6}: commit: up2
ef04433 HEAD@{7}: commit: up1
ffb409c HEAD@{8}: checkout: moving from master to dev
ffb409c HEAD@{9}: commit: test
37f33ca (origin/master, origin/HEAD) HEAD@{10}: pull: Fast-forward
```

