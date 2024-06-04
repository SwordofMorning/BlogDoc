# Linear Algebra 03 Vector Spaces

[toc]

## 一、向量空间

### 1.1 简介

&emsp;&emsp;**向量空间(vector space)**包含了向量和标量的集合。在本篇文章中，所考察的是向量是列向量，标量均为实数。

&emsp;&emsp;向量空间要求该向量空间中的向量和标量——在标量乘法和向量加法的情况下是**封闭的(closed)**。这意味着，任意几个标量或者向量组合出来的向量，仍然位于这个向量空间。我们看一个例子：

我们有：

$$
{\rm u} =
\left(
\begin{array}{\*{20}{c}}
{u\_1} \newline
{u\_2} \newline
{u\_3}
\end{array}
\right),
{\rm v} =
\left(
\begin{array}{\*{20}{c}}
{v\_1} \newline
{v\_2} \newline
{v\_3}
\end{array}
\right)
$$

令${\rm w} = a{\rm u} + b{\rm v}$，于是：

$$
{\rm w} = a{\rm u} + b{\rm v} =
\left(
\begin{array}{\*{20}{c}}
{au\_1 + bv\_1} \newline
{au\_2 + bv\_2} \newline
{au\_3 + bv\_3}
\end{array}
\right)
$$

这个向量也是$3-{\rm by}-1$的，因此也属于$\rm u, v$所在的向量空间。这个向量空间被称为：$\mathbb{R}^{3}$。

&emsp;&emsp;我们研究向量空间主要是为了确定与矩阵相关的向量空间。一个$m-{\rm by}-n$的矩阵有四个基本的向量空间：

1. null space
2. column space
3. row space
4. left null space

### 1.2 如何判断向量空间

&emsp;&emsp;具体的，向量集合所构成的向量空间需要满足以下几个条件：

1. 封闭性。如果$\rm u$和$\rm v$在这个集合中，那么$\rm u+v$和$k {\rm u}$也要在这个集合中。
2. 存在零向量。集合中必须包含零向量。
3. 存在加法逆元。对于集合中的任意向量$\rm u$，必须存在一个向量$\rm -u$，使得$\rm u + (-u) = 0$。
4. 基本运算定律。向量$\rm u$和向量$\rm v$应该满足向量加法的交换律和结合律；标量$k$与向量的加法应该满足分配律和结合律。

&emsp;&emsp;因此，判断一个向量集合(矩阵)是否是一个向量空间，可以遵循如下步骤：

假设我们现在有向量$\rm u$和$\rm v$，以及标量$k$。

1. 验证$\rm u + v$是否仍然在集合之中。
2. 验证$k {\rm u}$，是否在集合之中。

### 1.3 例子

&emsp;&emsp;例1，假设我们有“第二行为零的所有$3-{\rm by}-1$矩阵”：

令:

$$
{\rm A} =
\left(
\begin{array}{\*{20}{c}}
{a\_1} \newline
{0} \newline
{a\_3}
\end{array}
\right),
{\rm B} =
\left(
\begin{array}{\*{20}{c}}
{b\_1} \newline
{0} \newline
{b\_3}
\end{array}
\right)
$$

首先验证矩阵加法：

$$
{\rm A + B} = \left(
\begin{array}{\*{20}{c}}
{a\_1 + b\_1} \newline
{0} \newline
{a\_3 + b\_3}
\end{array}
\right)
$$

仍然满足第二行为零。接着验证标量乘法：

$$
k {\rm A} = \left(
\begin{array}{\*{20}{c}}
{k a\_1} \newline
{0} \newline
{k a\_3}
\end{array}
\right)
$$

仍然满足第二行为零。这两个向量满足了封闭性，因此它们构成向量空间。

&emsp;&emsp;例2，假设我们有“所有行元素之和等于1的$3-{\rm by}-1$矩阵”：

令：

$$
{\rm A} =
\left(
\begin{array}{\*{20}{c}}
{a\_1} \newline
{a\_2} \newline
{a\_3}
\end{array}
\right),
{\rm B} =
\left(
\begin{array}{\*{20}{c}}
{b\_1} \newline
{b\_2} \newline
{b\_3}
\end{array}
\right)
$$

其满足：

$$
a\_1 + a\_2 + a\_3 = 1, b\_1 + b\_2 + b\_3 = 1
$$

首先验证矩阵加法：

$$
{\rm A + B} = 
\left(
\begin{array}{\*{20}{c}}
{a\_1 + b\_1} \newline
{a\_2 + b\_2} \newline
{a\_3 + b\_3}
\end{array}
\right)
$$

其中，$a\_1 + b\_1 + a\_2 + b\_2 + a\_3 + b\_3 = 2$，不满足“所有行之和为1”，不封闭。因此不构成向量空间。

## 二、线性无关

&emsp;&emsp;假设我们的向量空间中有向量集合$u\_1, u\_2, \dots , u\_n$以及任意标量$c\_1, c\_2, \dots , c\_n$，如果下面等式：

$$
{c}\_{1}{u}\_{1} + {c}\_{2}{u}\_{2} + \dots + {c}\_{n}{u}\_{n} = 0
$$

如果存在唯一解$c\_1 = c\_2 = \dots = c\_n = 0$，这意味着我们无法用向量集合$\rm U$中的任何几个向量来表示另一个向量，那么我们可以说这个向量集合是**线性无关(linear independent)**的。

&emsp;&emsp;我们从下面一个例子来看：

$$
{\rm u} =
\left(
\begin{array}{\*{20}{c}}
{1} \newline
{0} \newline
{0}
\end{array}
\right),
{\rm v} =
\left(
\begin{array}{\*{20}{c}}
{0} \newline
{1} \newline
{0}
\end{array}
\right),
{\rm w} =
\left(
\begin{array}{\*{20}{c}}
{2} \newline
{3} \newline
{0}
\end{array}
\right)
$$

我们可以用$\rm w = 2u + 3v$来表示，因此这个向量组是线性相关的。我们保持$\rm u,v$不变，更改$\rm w$来看一下：

$$
{\rm u} =
\left(
\begin{array}{\*{20}{c}}
{1} \newline
{0} \newline
{0}
\end{array}
\right),
{\rm v} =
\left(
\begin{array}{\*{20}{c}}
{0} \newline
{1} \newline
{0}
\end{array}
\right),
{\rm w} =
\left(
\begin{array}{\*{20}{c}}
{0} \newline
{0} \newline
{1}
\end{array}
\right)
$$

此时，我们无法用另外两个向量来表示第三个向量，因此现在这个向量组是线性无关的。同时我们也可以用线性无关的定义来看：

$$
a{\rm u} + b{\rm v} + c{\rm w} = 
\left(
\begin{array}{\*{20}{c}}
{a} \newline
{b} \newline
{c}
\end{array}
\right)=
\left(
\begin{array}{\*{20}{c}}
{0} \newline
{0} \newline
{0}
\end{array}
\right)
$$

因为$a = b = c = 0$，所以该向量组是线性无关的。

&emsp;&emsp;对于简单的例子，我们可以通过目视解决。对于复杂的矩阵，通常采取将其化简为行最简的形式：如果最后一行全为零则是线性相关的；如果最后一行不全为零，则是线性无关的。

## 三、Span, Basis, Dimension

&emsp;&emsp;给定一个向量组，可以由该向量组的组合生成向量空间。我们说该向量集合**span**这个向量空间。

&emsp;&emsp;下面是一个向量集合：

$$
\left\\{
\left(
\begin{array}{\*{20}{c}}
{1} \newline
{0} \newline
{0}
\end{array}
\right),
\left(
\begin{array}{\*{20}{c}}
{0} \newline
{1} \newline
{0}
\end{array}
\right),
\left(
\begin{array}{\*{20}{c}}
{2} \newline
{3} \newline
{0}
\end{array}
\right)
\right\\}
$$

该集合，跨越第三行包含零的所有$3-{\rm by}-1$矩阵的向量空间。此向量空间是所有满足第三行为零的$3-{\rm by}-1$矩阵的向量子空间。

&emsp;&emsp;不需要所有这三个向量来生成这个向量子空间，因为任何一个向量都线性依赖于其他两个向量。span一个向量空间所需的最小向量集构成了该向量空间的**基(basis)**：

$$
\left\\{
    \left(
    \begin{array}{\*{20}{c}}
    {1} \newline
    {0} \newline
    {0}
    \end{array}
    \right),
    \left(
    \begin{array}{\*{20}{c}}
    {0} \newline
    {1} \newline
    {0}
    \end{array}
    \right)
\right\\}
,
\left\\{
    \left(
    \begin{array}{\*{20}{c}}
    {1} \newline
    {0} \newline
    {0}
    \end{array}
    \right),
    \left(
    \begin{array}{\*{20}{c}}
    {2} \newline
    {3} \newline
    {0}
    \end{array}
    \right)
\right\\}
,
\left\\{
    \left(
    \begin{array}{\*{20}{c}}
    {0} \newline
    {1} \newline
    {0}
    \end{array}
    \right),
    \left(
    \begin{array}{\*{20}{c}}
    {2} \newline
    {3} \newline
    {0}
    \end{array}
    \right)
\right\\}
$$

虽然这三种组合都构成了向量子空间的基，但通常首选第一种组合，因为这是正交基。此基中的向量相互正交，且具有单位范数。基的数量决定了向量的维度，在第三行全为零的$3-{\rm by}-1$向量空间中，其维度是2。

&emsp;&emsp;对于一个向量空间的正交基，其满足：

1. 每一个向量都满足向量空间的封闭性。
2. 这组正交基的向量两两正交。

## 四、格拉姆-施密特正交化

### 4.1 向量投影

&emsp;&emsp;假设现在我们有两个向量：$\rm v$和$\rm u$，其夹角为$\theta$；$\rm u$在$\rm v$上的投影为$\rm u'$。现在我们想要用$\rm u$和$\rm v$来表示投影$\rm u'$。于是有：

$$
\rm u' = {\left| u' \right|} \times \frac{v}{\left| v \right|}
$$

模长${\left| u' \right|}$可以表示为：

$$
{\rm \left| u' \right|} = {\rm \left| u \right|} \times {\rm cos}{\theta}
$$

夹角$\theta$由向量的内积给出：

$$
\begin{eqnarray}
{\rm v\_1}{\rm v\_2} &=& {\rm \left| v\_1 \right|} \times {\rm \left| v\_2 \right|} \times {\rm cos}{\theta} \newline
{\rm cos}{\theta} &=& \frac{\rm v\_1 v\_2}{{\rm \left| v\_1 \right|}{\rm \left| v\_2 \right|}}
\end{eqnarray}
$$

因此：

$$
\begin{eqnarray}
{\rm \left| u' \right|} &=&  {\rm \left| u \right|} \times \frac{\rm u v}{{\rm \left| u \right|}{\rm \left| v \right|}} = \frac{\rm u v}{{\rm \left| v \right|}} \newline
{\rm u'} &=& \frac{\rm u v^2}{{\rm \left| v \right|}^2}
\end{eqnarray}
$$

### 4.2 格拉姆-施密特正交化

&emsp;&emsp;给定一个向量空间的任意基，我们可以用**格拉姆-施密特正交化(Gram-Schmidt process)**来构造其正交基。

假设我们含有基：

$$
\rm \left\\{ v\_1, v\_2, \dots , v\_n \right\\}
$$

我们想要构造这个向量空间的正交基：

$$
\rm \left\\{ u\_1, u\_2, \dots , u\_n \right\\}
$$

构造过程如下：

1. 寻找正交基；
2. 归一化。

&emsp;&emsp;我们先看一个从普通基$\rm v$构造正交基$\rm u$的一般例子：

我们首先选择第一个正交基$\rm u\_1$，令$\rm u\_1 = v\_1$。然后构造下一个正交基$\rm u\_2$：

$$
\rm u\_2 = v\_2 - \frac{(u\_1^T v\_2)u\_1}{(u\_1^T u\_1)}
$$

显然，$\rm u\_2$等于$\rm v\_2$减去$\rm v\_2$中平行于$\rm u\_1$的部分。下面我们来验证一下$\rm u\_1$和$\rm u\_2$是否是正交的：

$$
\begin{eqnarray}
\rm u\_2 &=& \rm v\_2 - \frac{(u\_1^T v\_2)u\_1}{u\_1^T u\_1} \newline
\rm u\_1^T u\_2 &=& \rm u\_1^T v\_2 - u\_1^T \frac{(u\_1^T v\_2)u\_1}{(u\_1^T u\_1)} \newline
\rm u\_1^T u\_2 &=& \rm v\_1^T v\_2 - v\_1^T \frac{(v\_1^T v\_2)v\_1}{(v\_1^T v\_1)} \newline
\rm u\_1^T u\_2 &=& \rm v\_1^T v\_2 - v\_1^T v\_2 = 0
\end{eqnarray}
$$

证明$\rm u\_1$和$\rm u\_2$是正交的，接着我们来构造下一个正交基$\rm u\_3$。按照经验，这个正交基应该是“$\rm v\_3$，减去$\rm v\_3$与$\rm u\_1$平行的部分，减去$\rm v\_3$与$\rm u\_2$平行的部分”。因此：

$$
\rm u\_3 = v\_3 - \frac{(u\_1^T v\_3)u\_1}{(u\_1^T u\_1)} - \frac{(u\_2^T v\_3)u\_2}{(u\_2^T u\_2)}
$$

上面的正交向量还未进行归一化。向量的归一化可以通过如下公式完成：

$$
\hat{\rm u}\_1 = \frac{\rm u\_1}{{(\rm u\_1^T u\_1)}^{\frac{1}{2}}}
$$

&emsp;&emsp;因为$\rm u\_k$是$\rm v\_1, v\_2, \dots , v\_k$的线性组合，因此原始向量空间的前$k$个基向量所构成的向量子空间与通过格拉姆-施密特正交化生成的前$k$个正交向量所构成的子空间相同。可以表示为：

$$
\rm span\\{ u\_1, u\_2, \dots, u\_k \\} = \rm span\\{ v\_1, v\_2, \dots, v\_k \\}
$$

## 五、矩阵基本子空间

### 5.1 Null Space

&emsp;&emsp;矩阵$\rm A$的null space被记作$\rm Null(A)$，它是一个被所有满足如下条件的列向量横跨的向量空间：

$$
\rm Ax = 0
$$

显然，如果$\rm x$和$\rm y$属于null space，那么$a{\rm x} + b{\rm y}$也属于null space，其符向量空间的合封闭原则。如果矩阵$\rm A$大小是$m-{\rm by}-n$，那么$\rm Null(A)$是所有$n-{\rm by}-1$的列矩阵的向量子空间。如果$\rm A$是一个可逆方阵，那么$\rm Null(A)$仅有零向量组成。

&emsp;&emsp;我们从下面一个例子来考察如何寻找到一个不可逆矩阵的null space。假设我们有一个$3-{\rm by}-5$的矩阵：

$$
{\rm A} =
\left(
\begin{array}{\*{20}{r}}
{-3} & {6} & {-1} & {1} & {-7} \newline
{1} & {-2} & {2} & {3} & {-1} \newline
{2} & {-4} & {5} & {8} & {-4} \newline
\end{array}
\right)
$$

我们将其化简为行最简的形式：

$$
{\rm A} =
\left(
\begin{array}{\*{20}{r}}
{1} & {-2} & {0} & {-1} & {3} \newline
{0} & {0} & {1} & {2} & {-2} \newline
{0} & {0} & {0} & {0} & {0} \newline
\end{array}
\right)
$$

因为$\rm Ax = 0$，我们将矩阵$A$中主元列(pivot columns)对应的的$x\_1$和$x\_3$称为**基础变量(basic variables)**，将非主元列(non-pivot columns)对应的$x\_2$、$x\_4$和$x\_5$称为**自由变量(free variables)**。我们用自由变量来表示基础变量有：

$$
\begin{eqnarray}
x\_1 &=& 2x\_2 + x\_4 - 3\_x5 \newline
x\_3 &=& -2x\_4 + 2x\_5
\end{eqnarray}
$$

通过消除$x\_1$和$x\_3$，我们得到：

$$
\left(
\begin{array}{\*{20}{c}}
{2x\_2 + x\_4 - 3x\_5} \newline
{x\_2} \newline
{-2x\_4 + 2x\_5} \newline
{x\_4} \newline
{x\_5}
\end{array}
\right)=
x\_2
\left(
\begin{array}{\*{20}{r}}
{2} \newline
{1} \newline
{0} \newline
{0} \newline
{0}
\end{array}
\right)+
x\_4
\left(
\begin{array}{\*{20}{r}}
{1} \newline
{0} \newline
{-2} \newline
{1} \newline
{0}
\end{array}
\right)+
x\_5
\left(
\begin{array}{\*{20}{r}}
{-3} \newline
{0} \newline
{2} \newline
{0} \newline
{1}
\end{array}
\right)
$$

其中$x\_2$、$x\_4$和$x\_5$可以取任意值，通过将null space写为如此形式，$\rm Null(A)$显而易见地可以写为：

$$
\left\\{
\left(
\begin{array}{\*{20}{r}}
{2} \newline
{1} \newline
{0} \newline
{0} \newline
{0}
\end{array}
\right),
\left(
\begin{array}{\*{20}{r}}
{1} \newline
{0} \newline
{-2} \newline
{1} \newline
{0}
\end{array}
\right),
\left(
\begin{array}{\*{20}{r}}
{-3} \newline
{0} \newline
{2} \newline
{0} \newline
{1}
\end{array}
\right)
\right\\}
$$

$\rm A$的null space是所有$5-{\rm by}-1$的列矩阵的三维子空间。总的来说，$\rm Null(A)$的维度等于$\rm rref(A)$的非主元列的数量。

### 5.2 Null Space的应用

&emsp;&emsp;Null space的一个应用是用于求underdetermined equation的通解。Underdetermined equation指的是方程数量小于未知数的方程组。

&emsp;&emsp;假设我们要求解$\rm Ax = b$，如果$\rm u$是矩阵$\rm A$的null space的一般形式，$\rm v$是任何满足$\rm Av = b$的向量，那么$\rm x = u + v$满足${\rm Ax} = {\rm A(u+v)} = {\rm Au} + {\rm Av} = 0 + b = b$。因此，$\rm Ax=b$的通解可以表示为：$\rm Null(A)$的通解向量，与满足该方程组的任意特解向量。

&emsp;&emsp;我们通过下面一个例子来考察如何求解方程组：

$$
\begin{eqnarray}
2x\_1 + 2x\_2 + x\_3 &=& 0 \newline
2x\_1 - 2x\_2 - x\_3 &=& 1
\end{eqnarray}
$$

用矩阵的形式表示为：

$$
\left(
\begin{array}{\*{20}{r}}
{2} & {2} & {1} \newline
{2} & {-2} & {-1}
\end{array}
\right)
\left(
\begin{array}{\*{20}{r}}
{x\_1} \newline
{x\_2} \newline
{x\_3}
\end{array}
\right)=
\left(
\begin{array}{\*{20}{r}}
{0} \newline
{1}
\end{array}
\right)
$$

我们将其转化为增广矩阵的形式，并化简为行最简。

$$
\left(
\begin{array}{\*{20}{r}}
{2} & {2} & {1} & {0} \newline
{2} & {-2} & {-1} & {1}
\end{array}
\right) \to
\left(
\begin{array}{\*{20}{r}}
{1} & {0} & {0} & {1/4} \newline
{0} & {1} & {1/2} & {-1/4}
\end{array}
\right)
$$

这个null space满足$\rm Au = 0$，因此我们有：$u\_1 = 0$和$u\_2 = -u\_3 / 2$，我们可以将其写成：

$$
\rm Null(A) = span
\left\\{
\left(
\begin{array}{\*{20}{r}}
{0} \newline
{-1} \newline
{2}
\end{array}
\right)
\right\\}
$$

我们以及得到了通解，下面来求特解。特解满足${\rm Av} = b$，因此有：$v\_1 = 1/4$和$v\_2 + v\_3 = -1/4$。因为存在3个未知数和2个方程，我们将其中一个未知数取任意值，然后表示另外两个变量。为了方便，我们将$v\_3$取$0$，于是$v\_1 = 1/4$、$v\_2 = -1/4$。我们将特解写为向量的形式：

$$
\frac{1}{4}
\left(
\begin{array}{\*{20}{r}}
{1} \newline
{-1} \newline
{0}
\end{array}
\right)
$$

我们将通解和特解写到一起有：

$$
\left(
\begin{array}{\*{20}{r}}
{x\_1} \newline
{x\_2} \newline
{x\_3}
\end{array}
\right) = a
\left(
\begin{array}{\*{20}{r}}
{0} \newline
{-1} \newline
{2}
\end{array}
\right)+
\frac{1}{4}
\left(
\begin{array}{\*{20}{r}}
{1} \newline
{-1} \newline
{0}
\end{array}
\right)
$$

该形式构成了$\rm Ax=b$的通解，其中$a$取任意值。

### 5.3 Column Space

&emsp;&emsp;矩阵的column space是横跨矩阵列的向量空间。当矩阵乘以一个列向量是，结果仍然在这个向量空间中，可以表示为：

$$
\left(
\begin{array}{\*{20}{r}}
{a} & {b} \newline
{c} & {d}
\end{array}
\right)
\left(
\begin{array}{\*{20}{r}}
{x} \newline
{y}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{r}}
{ax + by} \newline
{cx + dy}
\end{array}
\right)= x
\left(
\begin{array}{\*{20}{r}}
{a} \newline
{c}
\end{array}
\right) + y
\left(
\begin{array}{\*{20}{r}}
{b} \newline
{d}
\end{array}
\right)
$$

&emsp;&emsp;总的来说，$\rm Ax$是矩阵$\rm A$列的线性组合。给定一个$m-{\rm by}-n$的矩阵$\rm A$，$\rm A$的列空间的维度是多少？我们要如何找到基？由于$\rm A$有$m$行，因此$\rm A$的列空间是所有$m-{\rm by}-1$列矩阵的子空间。

&emsp;&emsp;我们可以按照如下方法来找到列空间的基：

假设我们有如下矩阵：

$$
{\rm A} =
\left(
\begin{array}{\*{20}{r}}
{-3} & {6} & {-1} & {1} & {-7} \newline
{1} & {-2} & {2} & {3} & {-1} \newline
{2} & {-4} & {5} & {8} & {-4} \newline
\end{array}
\right),
{\rm rref(A)} =
\left(
\begin{array}{\*{20}{r}}
{1} & {-2} & {0} & {-1} & {3} \newline
{0} & {0} & {1} & {2} & {-2} \newline
{0} & {0} & {0} & {0} & {0} \newline
\end{array}
\right)
$$

$\rm Ax=0$表示矩阵$\rm A$的线性相关，并且行操作并不会改变其线性关系(可以理解为行操作是在解方程)。从上面的行最简矩阵中显然可以看出，只有主元列是线性无关的，并且$\rm A$的column space的维度等于主元的数量。同时，基向量由行最简矩阵$\rm rref(A)$所在主元列的位置对应的原矩阵$\rm A$给出：

$$
\left\\{
\left(
\begin{array}{\*{20}{r}}
{-3} \newline
{1} \newline
{2}
\end{array}
\right) ,
\left(
\begin{array}{\*{20}{r}}
{-1} \newline
{2} \newline
{5}
\end{array}
\right),
\right\\}
$$

&emsp;&emsp;之前我们提到，null space的维度等于矩阵的非主元列的数量，因此null space的维度加上column space的维度等于矩阵的列数。假设我们有一个$m-{\rm by}-n$的矩阵，那么：

$$
{\rm dim(Col(A)) + dim(Null(A))} = n
$$

### 5.4 Row Space, Left Null Space, Rank

&emsp;&emsp;简单地来说，将column space转置之后就得到了row space：

$$
\rm Row(A) = Col(A^T)
$$

column space的大小是$m-{\rm by}-1$，而row space的大小是$n-{\rm by}-1$。

&emsp;&emsp;同样的，如果$\rm Ax = 0$表示null space，那么可以用$\rm x^T A = 0$来表示left null space：

$$
\rm LeftNull(A) = Null(A^T)
$$

null space的大小是$n-{\rm by}-1$，而left null space的大小是$m-{\rm by}-1$。

&emsp;&emsp;接下来我们来考察一下这几个向量空间之间的关系。

&emsp;&emsp;Null space包含所有满足$\rm Ax=0$的向量$\rm x$，换言之null space是所有与$\rm A$的行正交的向量的集合，即null space与row space正交。

&emsp;&emsp;前面提到column space通过$\rm rref(A)$寻找**主元列**来确定其维度和基，row space同样通过$\rm rref(A)$的**带有主元列的行**来确定其维度和基。而null space的维度是**非主元列**的数量，这两个子空间的并集(union)构成了所有$n-{\rm by}-1$矩阵的向量空间，同时我们说这两个子空间**正交互补(orthogonal complements)**。

&emsp;&emsp;进一步的，**主元列的数量**与**带有主元列的行**的数量是相等的，因此：

$$
\rm dim(Col(A)) = dim(Row(A))
$$

我们将这个维度叫做矩阵的**秩(Rank)**。这是一个很不寻常的结果，因为column space和row space是两个不同的向量空间。总之，我们有：

$$
{\rm rank(A)} \le {\rm min}(m, n)
$$

当等式成立的时候，我们说这个矩阵**满秩(full rank)**。当一个方阵满秩的时候，因为其null space的维度为0(即，不存在)，所以该方阵可逆。

## 六、正交投影

&emsp;&emsp;假设我们有一个关于所有$n-{\rm by}-1$矩阵的$n$维向量空间$V$，以及一个$p$维的子空间$W$。令$\\{ s\_1, s\_2, \dots ,s\_p\\}$为$W$的正交基，我们将其扩展，令$\\{ s\_1, s\_2, \dots ,s\_p, t\_1, t\_2, \dots ,t\_{n-p}\\}$为$V$的正交基。

&emsp;&emsp;对于任何$V$中的向量$\rm v$来说，其可以用正交基的形式来表示：

$$
{\rm v} = a\_1 {\rm s}\_1 + a\_2 {\rm s}\_2 + \dots + a\_p {\rm s}\_p + b\_1 {\rm t}\_1 + b\_2 {\rm t}\_2 + \dots + b\_{n-p} {\rm t}\_{n-p}
$$

其中$a$和$b$是标量系数。将向量$\rm v$投影到向量空间$W$可以定义为：

$$
{\rm v\_{proj}}\_{W} = a\_1 {\rm s\_1} + a\_2 {\rm s\_2} + \dots + a\_p {\rm s}\_p
$$

如果我们知道向量$\rm v$和向量空间$W$的正交基，我们可以用$\rm v^T s$来表示标量系数：

$$
{\rm v\_{proj}}\_{W} = ({\rm v^T}{\rm s}\_1){\rm s}\_1 + ({\rm v^T}{\rm s}\_2){\rm s}\_2 + \dots + ({\rm v^T}{\rm s}\_p){\rm s}\_p
$$

&emsp;&emsp;另外，我们需要介绍一个特殊的性质：在向量空间$W$中，${\rm v\_{proj}}\_{W}$是最接近$\rm v$的向量。简要证明如下。

令$\rm w$表示向量空间$W$中任意一个向量：

$$
{\rm w} = c\_1 {\rm s\_1} + c\_2 {\rm s\_2} + \dots + c\_p {\rm s}\_p
$$

$\rm v$和$\rm w$之间的距离可以由范数$\left \Vert {\rm v - w} \right \Vert$给出，于是有：

$$
\begin{eqnarray}
{\left \Vert {\rm v - w} \right \Vert}^2 &=& (a\_1 - c\_1)^2 + \dots + (a\_p - c\_p)^2 + b\_1^2 + \dots + b\_{n-p}^2 \newline
&\ge& b\_1^2 + \dots + b\_{n-p}^2 \newline
&=& {\left \Vert {\rm v - {\rm v\_{proj}}\_{W}} \right \Vert}^2
\end{eqnarray}
$$

&emsp;&emsp;这个重要的性质将在下一周的最小二乘法中讨论。

## 七、最小二乘法

### 7.1 基础概念

&emsp;&emsp;假设我们现在有一个数据集需要拟合，它有一个维度的label，和一个维度的output，即，它是一个二维数据集。我们试图用一条直线来拟合这个数据集，我们将label用$x$来表示，这是确切的值；我们用$y$来表示output，它是含有噪音的值(相对于我们的拟合来说)。那么，每一个数据都可以表示为$(x\_k, y\_k)$，拟合的直线则是$y={\beta}\_0 + {\beta}\_1 x$，于是有：

$$
\begin{eqnarray}
y\_1 &=& {\beta}\_0 + {\beta}\_1 x\_1 \newline
y\_2 &=& {\beta}\_0 + {\beta}\_1 x\_2 \newline
&\vdots& \newline
y\_n &=& {\beta}\_0 + {\beta}\_1 x\_n
\end{eqnarray}
$$

我们将其改写为$\rm Ax=b$的形式：

$$
\left(
\begin{array}{\*{20}{c}}
{1} & {x\_1} \newline
{1} & {x\_2} \newline
{\vdots} & {\vdots}  \newline
{1} & {x\_n}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{{\beta}\_{0}} \newline
{{\beta}\_{1}} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{y\_1} \newline
{y\_2} \newline
{\vdots}  \newline
{y\_n}
\end{array}
\right)
$$

&emsp;&emsp;因为该方程组是一个overdetermined system，因此它没有解。但我们可以通过最小二乘法来寻找它的最优的解。

&emsp;&emsp;我们可以如下描述这一过程。假设我们有$\rm Ax=b$，但因为$\rm b$不在$\rm A$的column space中，因此方程无解。但是我们可以将$\rm b$投影到$\rm {b\_{proj}}\_{Col(A)}$来解决$\rm Ax = {b\_{proj}}\_{Col(A)}$。该方法被称为**最小二乘法(least-squares)**。下面来看一下最小二乘法的一般流程。

假设我们有$\rm Ax=b$，我们将$\rm b$投影到$\rm {b\_{proj}}\_{Col(A)}$：

$$
\rm b = {b\_{proj}}\_{Col(A)} + (b - {b\_{proj}}\_{Col(A)})
$$

其中$\rm {b\_{proj}}\_{Col(A)}$是$\rm b$在$\rm A$column space上的投影；$\rm (b - {b\_{proj}}\_{Col(A)})$是与$\rm A$的column space正交的项，它同时正交于$\rm Row(A^T)$，亦位于$\rm Null(A^T)$。将overdetermined matrix equation两边同时乘以$\rm A^T$，得到一个可解的等式，这个等式被称为$\rm Ax=b$的**正规化方程(normal equations)**：

$$
\rm A^T A x = A^T b
$$

当$\rm A$的列线性无关的时候(关于线性无关，我们将在后面讨论)，存在唯一解。将正规方程的两边同时乘以$\rm A(A^T A)^{-1}$，我们得到：

$$
\rm Ax = A(A^T A)^{-1}A^T b = {b\_{proj}}\_{Col(A)}
$$

其中，投影矩阵$\rm P = A(A^T A)^{-1}A^T$满足$\rm P^2 = P$。如果$\rm A$本身就是一个可逆方正，那么$\rm P = I$，并且$\rm b$本身已经位于$A$的column space中。

### 7.2 投影矩阵P

&emsp;&emsp;关于投影矩阵$\rm P = A(A^T A)^{-1}A^T$，我们额外讨论一下它是怎么得出的。

结合我们之前说的，由于$\rm b\_{proj}$是$\rm b$在$\rm Col(A)$上的投影，误差$\rm b - b\_{proj}$应该与$\rm Col(A)$正交。这意味着对于$\rm Col(A)$中的任意列向量${\rm a}\_i$都有：

$$
{\rm a}\_{i}^{\rm T}(\rm b - b\_{proj}) = 0
$$

因为我们此时不在求解$\rm Ax = b$，而是求解$\rm Ax = b\_{proj}$，将其以矩阵形式表达则是：

$$
\rm A^T (b - Ax) = 0
$$

我们将其化简得到：

$$
\rm A^T b = A^T Ax
$$

由于$\rm A^T A$是可逆的(因为我们假设了$\rm A$的列线性无关)，我们有：

$$
\rm x = (A^T A)^{-1} A^T b
$$

现在我们回到$\rm b\_{proj}$：

$$
\rm b\_{proj} = Ax = A(A^T A)^{-1} A^T b
$$

于是我们得到了投影矩阵$\rm P = A(A^T A)^{-1}A^T$。

### 7.3 数值化的例子

&emsp;&emsp;假设我们现在有三个点，我们试图进行拟合，这三个点是：$(1, 1)$、$(2, 3)$和$(3, 2)$。我们将拟合的执行设为$y = {\beta}\_0 + {\beta}\_1 x$，这个方程组可以表示为：

$$
\left(
\begin{array}{\*{20}{c}}
{1} & {1} \newline
{1} & {2} \newline
{1} & {3}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{{\beta}\_{0}} \newline
{{\beta}\_{1}} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{1} \newline
{3} \newline
{2}
\end{array}
\right)
$$

我们用最小二乘法将其表示为：

$$
\left(
\begin{array}{\*{20}{c}}
{1} & {1} & {1} \newline
{1} & {2} & {3}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{1} & {1} \newline
{1} & {2} \newline
{1} & {3}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{{\beta}\_{0}} \newline
{{\beta}\_{1}} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{1} & {1} & {1} \newline
{1} & {2} & {3}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{1} \newline
{3} \newline
{2}
\end{array}
\right)
$$

即：

$$
\left(
\begin{array}{\*{20}{c}}
{3} & {6} \newline
{6} & {14}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{{\beta}\_{0}} \newline
{{\beta}\_{1}} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{6} \newline
{13}
\end{array}
\right)
$$

可以解得：${\beta}\_{0} = 1$、${\beta}\_{1} = \frac{1}{2}$。

### 7.4 A的线性无关

&emsp;&emsp;我们还需要提一下为什么需要假设$\rm A$的列向量是线性无关的。

1. 线性相关性和秩：如果$\rm A$的列向量是线性相关的，$\rm A^T A$就是奇异的(不满秩)，此时无法直接求逆。
2. 解的性质：如果$\rm A$的列向量线性相关，最小二乘问题就不再有唯一解。

&emsp;&emsp;因此，如果是线性相关的情况，我们可以使用广义逆和最小范数解来求最小二乘法。其中，广义逆$A^{+}$满足如下条件：

$$
\rm {A}^{+} = ({A}^{T}{A})^{+} {A}^{T}
$$

利用广义逆，我们可以找到一个最小二乘解：

$$
\rm x\_{min-norm} = {A}^{+}b
$$

&emsp;&emsp;具体来说，我们可以用奇异值分解来求广义逆，假设$\rm A$的奇异值分解为：

$$
\rm A = U \Sigma V^T
$$

那么:

$$
\rm A^{+} = V {\Sigma}^{+} U^T
$$