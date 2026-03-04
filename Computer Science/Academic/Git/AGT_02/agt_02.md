# Advanced Git Tutorial 02

## 一、同步上游下游仓库

### 1.1 PR rebase

&emsp;&emsp;假设我们面对一个如下的场景：

1. 我们通过PR将origin仓库的`master`分支同步到了upstream上；
2. upstream通过`rebase`接收了PR；
3. origin和upstream有了不同的提交历史；
4. 现在我们需要同步upstream和origin。

&emsp;&emsp;其工作流程如下：

```sh
# 1. 确保在 master 分支
git checkout master

# 2.1 获取 upstream 的最新提交
git fetch upstream
# 2.2 将本地 master 重置到 upstream/master
git reset --hard upstream/master
# 如果可以直接pull的话, 也可以使用
git pull upstream master

# 3. 使用 force-with-lease 强制推送
git push -u origin master --force-with-lease
```

### 1.2 Different Assets

&emsp;&emsp;假设我们面对一个如下的场景：

1. Fork了某个仓库(upstream)；
2. 修改了其中的部分`assets`文件(例如修改了icon)；
3. 现在upstream做出了修改，我们想要保留我们自己的commit(修改icon)、同步upstream上的commit。

在github上来看则是：

```
This branch is 1 commit ahead of and 177 commits behind xx/xx
```

```sh
# 1. 获取上游更新
git fetch upstream

# 2. 切换对应分支
git checkout master

# 3. 变基：把我们的修改加在 upstream 之后
git rebase upstream/master

# (在此处处理可能出现的冲突，如果没有冲突则忽略)

# 4. 使用 force-with-lease 强制推送
git push -u origin master --force-with-lease
```

### 1.3 PR Modify

&emsp;&emsp;假设我们面对一个如下的场景：

1. 我们在upstream上提交了一个`upstream:feat`到`upstream:main`的PR(`pr-292`)；
2. 但是产生了冲突，需要我们手动checkout处理解决Bug。

```sh
# 1.1 fetch远程仓库到本地仓库
git fetch upstream pull/292/head:pr-292
# 1.2 切换到pr-292
git checkout pr-292
# 1.3 再次同步远程仓库(确保一致性)
git fetch upstream

# 2. 手动进行Merge
git merge upstream/main -> 手动修文件 -> git add . -> git commit

# 3. 推送回原有发feat分支
git push origin pr-292:feat
```