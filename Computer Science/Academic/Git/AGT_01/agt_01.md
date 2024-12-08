# Advanced Git Tutorial

[toc]

## 一、工作流程

&emsp;&emsp;为了了解git是如何工作的，我们首先需要知道代码在什么地方。对于使用git管理的项目，主要会有如下4个位置用来存放代码：

1. Working Directory: 我们本地编辑代码的位置，也就是我们从编辑器中看见的代码；
2. Staging Area: Committing之前的的临时保存点；
3. Local Repository: 本地存储更改的地方；
4. Remote Repository: 类似Github用于备份、共享的服务器。

&emsp;&emsp;下面我们来看一下常用的git命令是如何在这四个地方移动代码的。

[caption width="841" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/01_clone.drawio.svg" width="841" height="523" alt="图1" class="size-full" /> 图1：Git的工作流程[/caption]

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

[caption width="561" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/02_chechkout.drawio.svg" width="561" height="241" alt="图2" class="size-full" /> 图2：Checkout and Switch[/caption]

&emsp;&emsp;`git merge`允许我们合并分支，参数`--no-ff`指定了不使用fast forward的合并方式。

[caption width="1008" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/03_merge.png" width="1008" height="836" alt="图3" class="size-full" /> 图3：Merge[/caption]

&emsp;&emsp;`git rebase`则可以作为一种显式的`ff`进行合并：

[caption width="882" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/04_rebase.drawio.svg" width="882" height="962" alt="图4" class="size-full" /> 图4：Rebase[/caption]

## 三、冷门但是有用

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

### 3.3 git reflog

&emsp;&emsp;`git reflog`允许我们查看当前HEAD的所有git操作历史记录。

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

### 3.4 git diff

&emsp;&emsp;默认的`git diff`会按照**行**给出diff，如果我们加上参数`--word-diff`则会按照“词/列”给出diff。

### 3.5 rerere

see：<a href=https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-Rerere>git-scm</a>

### 3.6 git branch

&emsp;&emsp;`git branch`可以查看分支，`git branch --column`允许我们按照多个列的方式查看。同时，我们可以使用：

```
git config --global column.ui auto

git config --global branch.sort -committerdate
```

### 3.7 git push

&emsp;&emsp;`git push --force-with-lease`，会检查当前的节点是否是remote上的最后一个节点（最新的），如果是的话，则可以进行push。常用于rebase之后的提交。

### 3.8 git maintenance

&emsp;&emsp;允许在后台自动维护项目，例如，它可以执行如下任务：

1. commit-graph
2. prefetch
3. gc
4. loose-objects
5. incremental-repack
6. pack-refs

### 3.9 git add

&emsp;&emsp;假设我们的一个文件其做了多个部分的修改，并且引入了我们自己的调试输出。直接使用add会添加全部的修改，使用`add -p`则可以指定其提交的部分。例如：

```diff
@@ -1,16 +1,31 @@
 #include <stdio.h>

+void fun1()
+{
+       printf("before hello world\n");
+}
+
 void demo()
 {
        ;
 }

+void fun2()
+{
+       printf("after hello world\n");
+}
+
 int main()
 {
+       fun1();
        printf("hello world\n");
+       printf("debug %s %d\n", __func__, __LINE__);
        printf("hello world\n");
        printf("hello world\n");
        printf("hello world\n");
+       printf("debug %s %d\n", __func__, __LINE__);
        printf("hello world\n");
+       fun2();
        demo();
+       printf("debug %s %d\n", __func__, __LINE__);
 }
```

如果我们只想提交fun1的内容，则使用`-p`来指定需要提交的部分。输入`git add -p test.c`，git会将代码拆分为多个片段，对于每一个片段有如下命令选择（git会提示你`Stage this hunk [y,n,q,a,d,/,s,e,?]?`）：

```
y - stage this hunk
n - do not stage this hunk
q - quit; do not stage this hunk or any of the remaining ones
a - stage this hunk and all later hunks in the file
d - do not stage this hunk or any of the later hunks in the file
g - select a hunk to go to
/ - search for a hunk matching the given regex
j - leave this hunk undecided, see next undecided hunk
J - leave this hunk undecided, see next hunk
k - leave this hunk undecided, see previous undecided hunk
K - leave this hunk undecided, see previous hunk
s - split the current hunk into smaller hunks
e - manually edit the current hunk
? - print help

y - 暂存此区块
n - 不暂存此区块
q - 退出；不暂存包括此块在内的剩余的区块
a - 暂存此块与此文件后面所有的区块
d - 不暂存此块与此文件后面所有的 区块
g - 选择并跳转至一个区块
/ - 搜索与给定正则表达示匹配的区块
j - 暂不决定，转至下一个未决定的区块
J - 暂不决定，转至一个区块
k - 暂不决定，转至上一个未决定的区块
K - 暂不决定，转至上一个区块
s - 将当前的区块分割成多个较小的区块
e - 手动编辑当前的区块
? - 输出帮助
```

## 四、Switch and Restore

### 4.1 git checkout branch

or `git switch branch`

1. 这个命令用于切换到一个已存在的分支(branch)；
2. 它会将你的工作目录更新到该分支的最新提交状态；
3. 例如，`git checkout master`会切换到主分支(master branch)。

### 4.2 git checkout -b branch

or `git switch -c branch`

1. 这个命令用于创建一个新的分支，并立即切换到该分支；
2. -b 选项表示创建(branch)一个新分支；
3. 例如，`git checkout -b feature`会创建一个名为"feature"的新分支，并切换到该分支。

### 4.3 git checkout file.txt

or `git restore file.txt`

1. 这个命令用于撤销对文件file.txt的修改,将其恢复到最近一次提交的状态；
2. 它会丢弃在工作目录中对file.txt所做的任何更改；
3. 这在你想要放弃对文件的修改时很有用。

### 4.4 git checkout -p file.txt

or `git restore -p file.txt`

1. 这个命令用于交互式地选择要恢复的file.txt文件的部分修改；
2. -p 选项表示交互式地补丁(patch)模式；
3. Git会逐个显示file.txt的变更区块(hunk)，你可以选择是否恢复每个区块；
4. 这在你只想恢复文件的部分修改时很有用。

### 4.5 git checkout branch -- file.txt

or `git restore --source branch file.txt`

&emsp;&emsp;这个命令会从指定的分支(branch)中获取文件(file.txt)的版本，并将其复制到当前分支的工作目录中。它通常用于：

1. 当你在一个分支上工作，但需要从另一个分支获取特定文件的更新版本时；
2. 当你误删了当前分支的文件，但该文件在另一个分支上仍然存在时，你可以从那个分支中恢复文件。

## 五、Hooks & Husky

1. Commit

> pre-commit
> prepare-commit-msg
> commit-msg
> post-commit

2. Merging

> post-merge
> pre-merge-commit

3. Rewriting

> pre-rebase
> post-rewrite

4. Switching/Pushing

> post-checkout
> reference-transaction
> pre-push

## 六、Attributes

### 6.1 二进制文件

&emsp;&emsp;一个典型的比较二进制文件的方式如下：

```sh
echo '*.png diff=exif' >> .gitattributes

git config diff.exif.textconv exiftool

diff --git a/image.png b/image.png
index 88839c4..4afcb7c 100644
--- a/image.png
+++ b/image.png
@@ -1,12 +1,12 @@
 ExifTool Version Number         : 7.74
-File Size                       : 70 kB
-File Modification Date/Time     : 2009:04:21 07:02:45-07:00
+File Size                       : 94 kB
+File Modification Date/Time     : 2009:04:21 07:02:43-07:00
 File Type                       : PNG
 MIME Type                       : image/png
-Image Width                     : 1058
-Image Height                    : 889
+Image Width                     : 1056
+Image Height                    : 827
 Bit Depth                       : 8
 Color Type                      : RGB with Alpha
```

### 6.2 关键字展开

&emsp;&emsp;对于习惯使用SVN或者CVS的使用者来说，如果要良好的使用keywords，则建议使用`smudge`和`clean`来实现一个filter：

[caption width="1278" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/05.png" width="1278" height="615" alt="图5" class="size-full" /> 图5：Sumdge[/caption]

[caption width="1275" align="aligncenter"]<img src="https://cdn.swordofmorning.com/SwordofMorning/Article%20Images/Git/AGT_01/06.png" width="1275" height="612" alt="图6" class="size-full" /> 图6：Clean[/caption]

```sh
# in .gitattributes file
*.c filter=indent

# then config
$ git config --global filter.indent.clean indent
$ git config --global filter.indent.smudge cat
```

&emsp;&emsp;`smudge`和`clean`的另一个作用是配合LFS进行大文件的过滤。例如我有一个2G的`.img`文件，我对其配置filter来使得git不会跟踪这个文件，而是保存它的指针，指向LFS服务器。

## 七、Fixup Commit

```sh
git commit --fixup=<commit>
git rebase --autosquash
```

&emsp;&emsp;假设我们现在有如下的提交记录：

```sh
c1: Add feature A
c2: Fix typo in feature A
c3: Add feature B
c4: Refactor feature A
```

你发现在提交`c2`中有一个小错误需要修复。你进行了必要的更改，然后使用 `git commit --fixup`提交这个修复:

```sh
git add .
git commit --fixup=c2
```

现在你的提交历史看起来像这样:

```sh
c1: Add feature A
c2: Fix typo in feature A
c3: Add feature B
c4: Refactor feature A
c5: fixup! Fix typo in feature A
```

现在运行`git rebase -i --autosquash HEAD~5`命令。Git会打开一个交互式rebase编辑器，它已经将`fixup`提交(c5)移动到了它所引用的提交(c2)之后，并将其标记为"fixup":

```sh
pick c1 Add feature A
pick c2 Fix typo in feature A
fixup c5 fixup! Fix typo in feature A
pick c3 Add feature B
pick c4 Refactor feature A
```

你保存并关闭编辑器。Git会自动将`fixup`提交(c5)合并到它所引用的提交(c2)中，并创建一个新的提交历史:

```sh
c1: Add feature A
c2: Fix typo in feature A
c3: Add feature B
c4: Refactor feature A
```

&emsp;&emsp;这样，`fixup`提交就被无缝地合并到了它所修复的提交中，使提交历史保持简洁和可读性。

## 八、Cherry pick