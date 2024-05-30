# Linear Algebra 01 Matrix

[toc]

## 一、矩阵定义

&emsp;&emsp;一个$m-{\rm by}-n$的矩阵是指一个具有$n$行、$m$列的，包含了数字或者其他数学对象的矩形。比如，一个$2-{\rm by}-2$的矩阵$\rm A$，它有着2行2列：

$$
{\rm A} = \left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{c}&{d}
\end{array}
\right)
$$

其中第1行有$a$和$b$两个元素，第二行有$c$和$d$两个元素。同时，我们可以构建一个$2-{\rm by}-3$的矩阵$\rm B$和一个$3-{\rm by}-2$的矩阵$\rm C$：

$$
{\rm B} = \left(
\begin{array}{\*{20}{l}}
{a}&{b}&{c} \newline
{d}&{e}&{f}
\end{array}
\right)
,
{\rm C} = \left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{b}&{e} \newline
{c}&{f}
\end{array}
\right)
$$

特别的，对于$1-{\rm by}-n$的矩阵和$n-{\rm by}-1$的矩阵，分别叫做行矩阵和列矩阵，也成为行向量和列向量。下面是$n = 3$的列向量：

$$
{\rm x} = \left(
\begin{array}{\*{20}{l}}
{a} \newline
{b} \newline
{c}
\end{array}
\right)
$$

下面是$n = 3$的行向量：

$$
{\rm y} = \left(
\begin{array}{\*{20}{l}}
{a}&{b}&{c}
\end{array}
\right)
$$

&emsp;&emsp;一个$m-{\rm by}-n$的矩阵的一般表达形式如下：

$$
{\rm A} = \left(
\begin{array}{\*{20}{l}}
{a\_{11}}&{a\_{12}}&{\cdots}&{a\_{1n}} \newline
{a\_{21}}&{a\_{22}}&{\cdots}&{a\_{2n}} \newline
{\vdots}&{\vdots}&{\ddots}&{\vdots} \newline
{a\_{m1}}&{a\_{m2}}&{\cdots}&{a\_{mn}}
\end{array}
\right)
$$

其中第$i$行$j$列的元素被表示为$a\_{ij}$。

## 二、矩阵的加法和乘法

&emsp;&emsp;矩阵的加法具有*点对点*的形式，下面是一个$2-{\rm by}-2$的例子：

$$
\left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{c}&{d}
\end{array}
\right)+
\left(
\begin{array}{\*{20}{l}}
{e}&{f} \newline
{g}&{h}
\end{array}
\right)=
\left(
\begin{array}{\*{20}{l}}
{a+e}&{b+f} \newline
{c+g}&{d+h}
\end{array}
\right)
$$

&emsp;&emsp;对于矩阵与标量乘法，仍然遵循*点对点*的形式：

$$
k \left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{c}&{d}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{l}}
{ka}&{kb} \newline
{kc}&{kd}
\end{array}
\right)
$$

&emsp;&emsp;对于矩阵与矩阵之间的乘法一般分为cross product和dot product，后者是*点对点*的，而前者则不是。我们通过一个$2-{\rm by}-2$矩阵的例子来说明：

$$
\left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{c}&{d}
\end{array}
\right) \times
\left(
\begin{array}{\*{20}{l}}
{e}&{f} \newline
{g}&{h}
\end{array}
\right)=
\left(
\begin{array}{\*{20}{l}}
{ae+bg} & {ef+bh} \newline
{ce+dg} & {cf+dh}
\end{array}
\right)
$$

我们发现：对于元素(1,1)来说，其结果是，矩阵的第1行$\cdot$矩阵的第1列，并求和；对于元素(1,2)来说，其结果是矩阵的第1行$\cdot$矩阵的第2列，并求和。因此我们不难发现，和标量的乘法不同，矩阵之间的叉乘**不是**可交换的(commutative)。我们交换上述两个矩阵：

$$
\left(
\begin{array}{\*{20}{l}}
{e}&{f} \newline
{g}&{h}
\end{array}
\right) \times
\left(
\begin{array}{\*{20}{l}}
{a}&{b} \newline
{c}&{d}
\end{array}
\right)=
\left(
\begin{array}{\*{20}{l}}
{ea+fc} & {eb+fd} \newline
{ga+hc} & {gb+hd}
\end{array}
\right)
$$

&emsp;&emsp;我们总结上面的乘法，并将其扩展到$m-{\rm by}-n$的一般情况。结果矩阵的第(i,j)元素的值，等于$\sum{(\text{矩阵的i行} \cdot \text{矩阵的j列})}$。不难发现，i行的元素个数应该和j列的元素个数相等，即，前一个矩阵的列应该和后一个矩阵的行相等。

&emsp;&emsp;如果我们用$\rm A$来表示一个$m-{\rm by}-p$的矩阵，其元素用$a\_{ij}$来表示；用$\rm B$来表示一个$p-{\rm by}-n$的矩阵，其元素用$b\_{ij}$来表示。那么，$\rm C=AB$就是一个$m-{\rm by}-p$的矩阵，其中的元素$c\_{ij}$可以表示为：

$$
C\_{ij} = \mathop{\sum} \limits\_{k=1}^{n} {a\_{ik} \cdot b\_{kj}}
$$

## 三、特殊矩阵

&emsp;&emsp;对于**零矩阵(zero matrix)**来说，它直接写作$0$，它充当标量中0的作用，因此其大小可以是任意的。**单位矩阵(identify matrix)**是一个方阵，它的主对角线上的值均为1，记作$\rm I$。单位矩阵充当标量中1的作用，如果$\rm A$是一个和$\rm I$同形的矩阵，那么有：

$$
\rm AI = A = IA
$$

一个$2-{\rm by}-2$的零矩阵和单位矩阵如下：

$$
0 = \left(
\begin{array}{\*{20}{l}}
{0}&{0} \newline
{0}&{0}
\end{array}
\right),{\rm I} = \left(
\begin{array}{\*{20}{l}}
{1}&{0} \newline
{0}&{1}
\end{array}
\right)
$$

&emsp;&emsp;**对角矩阵(diagonal matrix)**仅在对角线上有非零元素，一个$2-{\rm by}-2$的对角矩阵如下：

$$
{\rm D} = \left(
\begin{array}{\*{20}{l}}
{d\_{1}}&{0} \newline
{0}&{d\_{2}}
\end{array}
\right)
$$

通常，对角矩阵是一个方阵。但如果是一个满足$d\_{ij}=0, i \neq j$的矩形矩阵，也可以被认为是对角矩阵。

&emsp;&emsp;**带状矩阵(band or banded matrix)**，相当于对角矩阵的扩展版，它要求仅在对角带上存在非零元素，例如一个$3-{\rm by}-3$的带状矩阵：

$$
{\rm B} = \left(
\begin{array}{\*{20}{l}}
{d\_{1}}&{a\_{1}}&{0} \newline
{b\_{1}}&{d\_{2}}&{a\_{2}} \newline
{0}&{b\_{2}}&{d\_{3}}
\end{array}
\right)
$$

&emsp;&emsp;**上三角矩阵(upper)**或**下三角矩阵(lower triangular matrix )**，是一个方阵，仅在对角线和其上方、下方存在非零元素，例如一个$3-{\rm by}-3$的上三角和下三角矩阵：

$$
{\rm U} = \left(
\begin{array}{\*{20}{l}}
{a}&{d}&{f} \newline
{0}&{b}&{e} \newline
{0}&{0}&{c}
\end{array}
\right),{\rm L} = \left(
\begin{array}{\*{20}{l}}
{a}&{0}&{0} \newline
{d}&{b}&{0} \newline
{f}&{e}&{c}
\end{array}
\right)
$$

## 四、转置

&emsp;&emsp;对于矩阵$\rm A$，其**转置矩阵(transpose matrix)**写作$\rm A^{T}$，对于一个$m-{\rm by}-n$的矩阵$\rm A$有：

$$
{\rm A} = \left(
\begin{array}{\*{20}{l}}
{a\_{11}}&{a\_{12}}&{\cdots}&{a\_{1n}} \newline
{a\_{21}}&{a\_{22}}&{\cdots}&{a\_{2n}} \newline
{\vdots}&{\vdots}&{\ddots}&{\vdots} \newline
{a\_{m1}}&{a\_{m2}}&{\cdots}&{a\_{mn}}
\end{array}
\right)
,
{\rm A^{T}} = \left(
\begin{array}{\*{20}{l}}
{a\_{11}}&{a\_{21}}&{\cdots}&{a\_{m1}} \newline
{a\_{12}}&{a\_{22}}&{\cdots}&{a\_{m2}} \newline
{\vdots}&{\vdots}&{\ddots}&{\vdots} \newline
{a\_{1n}}&{a\_{2n}}&{\cdots}&{a\_{mn}}
\end{array}
\right)
$$

换言之，我们可以写作：

$$
a\_{ij}^{\rm T} = a\_{ji}
$$

&emsp;&emsp;显然，如果一个矩阵大小是$m-{\rm by}-n$的，那么其转置矩阵的大小则是$n-{\rm by}-m$的。我们以一个$3-{\rm by}-2$的矩阵为例：

$$
{\left(
\begin{array}{\*{20}{l}}
{a}&{d} \newline
{b}&{e} \newline
{c}&{f}
\end{array}
\right)}^{\rm T}=
\left(
\begin{array}{\*{20}{l}}
{a}&{b}&{c} \newline
{d}&{e}&{f}
\end{array}
\right)
$$

&emsp;&emsp;下面是两个容易证明的事实：

$$
\rm ({A}^{T})^{T} = {A}, (A+B)^{T} = A^{T}+B^{T}
$$

而和标量不同，矩阵乘积的转置等于矩阵转置的乘积：

$$
\rm (AB)^{T} = B^{T}A^{T}
$$

其证明如下：

对于矩阵$\rm A$和矩阵$\rm B$的叉乘而言，有：

$$
\begin{eqnarray}
\left\\{
\begin{array}{\*\*lr\*\*}
({\rm AB})\_{ij} = row({\rm A})\_{i} \cdot col({\rm B}\_{j}) \newline
({\rm AB})\_{ij}^{\rm T} = row({\rm A})\_{j} \cdot col({\rm B}\_{i})
\end{array}
\right. \newline 
\left\\{
\begin{array}{\*\*lr\*\*}
row({\rm A})\_{i} = col({\rm A}^{T})\_{i} \newline
col({\rm B})\_{j} = row({\rm B}^{T})\_{j}
\end{array}
\right.
\end{eqnarray}
$$

我们将下面的等式带入上面的等式中：

$$
\begin{eqnarray}
({\rm AB})\_{ij} &=& row({\rm A})\_{i} \cdot col({\rm B}\_{j}) \newline
&=& col({\rm A}^{T})\_{i} \cdot row({\rm B}^{T})\_{j} \newline
&=& row({\rm B}^{T})\_{j} \cdot col({\rm A}^{T})\_{i} \newline
&=& {\rm (B^{T} A^{T})}\_{ji}
\end{eqnarray}
$$

我们将其用矩阵描述则有：

$$
\begin{eqnarray}
({\rm AB}) &=& {\rm (B^{T} A^{T})}^{T} \newline
({\rm AB})^{\rm T} &=& {\rm (B^{T} A^{T})}
\end{eqnarray}
$$

证毕。

&emsp;&emsp;此外，转置矩阵中也存在一些特殊的矩阵。**对称矩阵(symmetric matrix)**指的是$\rm A^T = A$；而**斜对称矩阵(skew symmetric matrix)**指的是$\rm A^T = -A$。下面是一个$3-{\rm by}-3$的例子：

$$
\left(
\begin{array}{\*{20}{l}}
{a}&{b}&{c} \newline
{b}&{d}&{e} \newline
{c}&{e}&{f}
\end{array}
\right)
,
\left(
\begin{array}{\*{20}{l}}
{0}&{b}&{c} \newline
{-b}&{0}&{e} \newline
{-c}&{-e}&{0}
\end{array}
\right)
$$

这里需要注意的是，斜对称矩阵的对角线必须为0。

## 五、内积和外积

&emsp;&emsp;两个向量的**内积(inner product, dot product, scalar product)**从行向量和列向量的乘积中获得。这里我们默认向量都是列向量，因此下面是两个$3-{\rm by}-1$的列向量$\rm u$和$\rm v$相乘得到内积的例子：

$$
{\rm {u}^{T}{v}} = 
\left(
    \begin{array}{\*{20}{l}}
        {u\_1}&{u\_2}&{u\_3}
    \end{array}
\right) 
\left(
    \begin{array}{\*{20}{l}}
        {v\_1} \newline
        {v\_2} \newline
        {v\_3}
    \end{array}
\right) 
= {u\_1}{v\_1} + {u\_2}{v\_2} + {u\_3}{v\_3}
$$

如果两个非零向量的内积是零，那么我们说这两个向量是**正交的(orthogonal)**。向量的**范数(norm)**被定义为：

$$
{\left \Vert {\rm u} \right \Vert} = 
{\left( {\rm {u}^{T}{u}} \right)}^{1/2}=
{\left( {u\_1^2 + u\_2^2 + u\_3^2} \right)}^{1/2}
$$

如果向量的范数等于一，我们说这个向量已经**归一化(normalized)**。如果一组向量它们相互正交且是归一的，那么它们被称为**标准正交基(orthonormal basis)**。

&emsp;&emsp;向量的外积则是被定义为列向量与行向量的乘积，下面是同样是$\rm u$和$\rm v$的例子：

$$
{\rm {u}{v}^{T}} =
\left(
\begin{array}{\*{20}{l}}
{u\_1} \newline
{u\_2} \newline
{u\_3}
\end{array}
\right) 
\left(
\begin{array}{\*{20}{l}}
{v\_1}&{v\_2}&{v\_3}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{l}}
{{u}\_{1}{v}\_{1}} & {{u}\_{1}{v}\_{2}} & {{u}\_{1}{v}\_{3}} \newline
{{u}\_{2}{v}\_{1}} & {{u}\_{2}{v}\_{2}} & {{u}\_{2}{v}\_{3}} \newline
{{u}\_{3}{v}\_{1}} & {{u}\_{3}{v}\_{2}} & {{u}\_{3}{v}\_{3}}
\end{array}
\right) 
$$

&emsp;&emsp;矩阵$\rm B$的**迹(trace)**被记作$\rm Tr B$，是$\rm B$的对角元素之和。

## 六、逆矩阵

&emsp;&emsp;方阵可能存在**逆(inverse)矩阵**。如果矩阵$\rm A$存在逆阵，我们用$\rm A^{-1}$来表示这个逆阵。逆阵满足如下条件：

$$
\rm {A}{A}^{-1} = I = {A}^{-1}{A}
$$

&emsp;&emsp;首先，我们从一个$2-{\rm by}-2$的例子中来看如何计算矩阵的逆阵：

$$
\left(
\begin{array}{\*{20}{l}}
{a} & {b} \newline
{c} & {d}
\end{array}
\right)
\left(
\begin{array}{\*{20}{l}}
{x\_1} & {x\_2} \newline
{x\_3} & {x\_4}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{l}}
{1} & {0} \newline
{0} & {1}
\end{array}
\right)
$$

我们可以得到方程：

$$
\begin{eqnarray}
ax\_1 + by\_1 &=& 1 \tag{6-1} \newline
ax\_2 + by\_2 &=& 0 \tag{6-2} \newline
cx\_1 + dy\_1 &=& 0 \tag{6-3} \newline
cx\_2 + dy\_2 &=& 1 \tag{6-4}
\end{eqnarray}
$$

为了求解$y\_1$和$y\_2$，我们可以使用式(6-2)和式(6-3)的**齐次方程(homogenous equations)**来用$x$表示$y$；为了求解$x\_1$和$x\_2$，我们则可以将之前算出来的$y\_1$和$y\_2$带入式(6-1)和式(6-4)的**非齐次方程(inhomogeneous equations)**中。于是我们得到：

$$
\begin{eqnarray}
x\_1 &=& \frac{d}{ad-bc} \newline
x\_2 &=& \frac{-b}{ad-bc} \newline
y\_1 &=& \frac{-c}{ad-bc} \newline
y\_2 &=& \frac{a}{ad-bc}
\end{eqnarray}
$$

进一步：

$$
{\left(
\begin{array}{\*{20}{l}}
{a} & {b} \newline
{c} & {d}
\end{array}
\right)}^{-1} = 
\frac{1}{ad-bc}
\left(
\begin{array}{\*{20}{c}}
{d} & {-b} \newline
{-c} & {a}
\end{array}
\right)
$$

其中$ad-bc$被称为矩阵的**行列式(determinant)**，矩阵$\rm A$的行列式记作$\rm det(A)$或者$\left| {\rm A} \right|$。一个$n$阶方阵$\rm A$的行列式可以被定义为：

$$
{\rm det(A)} = 
    \mathop{\sum} \limits\_{\sigma \in S\_n} 
    {\rm sgn}(\sigma) 
    \mathop{\prod} \limits\_{i=1}^{n} 
    a\_{i,\sigma(i)}
$$

1. $S\_n$是集合上的置换全体。
2. $\mathop{\sum} \limits\_{\sigma \in S\_n}$表示对全体$S\_n$元素求和，即对于每个${\sigma \in S\_n}$而言，${\rm sgn}(\sigma) \mathop{\prod} \limits\_{i=1}^{n}$只在加法算式中出现一次；对于每一个满足$1 \le i,j \le n$的数对$(i,j)$，$a\_ij$是矩阵A的第i行第j列元素。
3. ${\rm sgn}(\sigma)$表示，置换${\sigma \in S\_n}$的符号差，具体地说：满足$1 \le i \le j \le n$但$\sigma(i) \gt \sigma(j)$的有序数对$(i,j)$被称为$\sigma$的一个逆序。如果$\sigma$的逆序数有偶数个，则${\rm sgn}(\sigma) = 1$；如果有及数个，则${\rm sgn}(\sigma) = -1$。

举例来说，对于3元置换$\sigma = (2,3,1)$，其逆序数为$sum(0, 0, 2) = 2$，因此三阶行列式中出现的$a\_{1,2}a\_{2,3}a\_{3,1}$其符号是正的，即${{\rm sgn}(\sigma)} = 1$；但对于3元置换$\sigma = (3,2,1)$而言，其逆序数为$sum(0, 1, 2) = 3$，因此三阶行列式中出现的$a\_{1,3}a\_{2,2}a\_{3,1}$其符号是负的，即${{\rm sgn}(\sigma)} = -1$。

&emsp;&emsp;和矩阵的转置类似，我们可以轻易地得到：

$$
\begin{eqnarray}
\rm {(AB)}^{-1} = {B}^{-1}{A}^{-1} \tag{6-5} \newline
\rm {(A^{T})}^{-1} = {(A^{-1})}^{-T} \tag{6-6}
\end{eqnarray}
$$

式(6-5)证明如下：

$$
\begin{eqnarray}
\rm AB &=& \rm C \newline
\rm {A}^{-1}AB &=& \rm {A}^{-1}C \newline
\rm IB &=& \rm {A}^{-1}C \newline
\rm B &=& \rm {A}^{-1}C \newline
\rm {B}^{-1}B &=& \rm {B}^{-1}{A}^{-1}C \newline
\rm I &=& \rm {B}^{-1}{A}^{-1}C \newline
\rm {C}^{-1} &=& \rm {B}^{-1}{A}^{-1}C{C}^{-1} \newline
\rm {C}^{-1} &=& \rm {B}^{-1}{A}^{-1} \newline
\rm {(AB)}^{-1} &=& \rm {B}^{-1}{A}^{-1}
\end{eqnarray}
$$

式(6-6)证明如下：

$$
\begin{eqnarray}
\rm {A}{A}^{-1} &=& \rm I \newline
\rm {({A}{A}^{-1})}^{T} &=& \rm I^{T} \newline
\rm {({A}^{-1})}^{T} {A}^{T} &=& \rm I \newline
\rm {({A}^{-1})}^{T} {A}^{T} {({A}^{T})}^{-1} &=& \rm {({A}^{T})}^{-1} \newline
\rm {({A}^{-1})}^{T} I &=& \rm {({A}^{T})}^{-1} \newline
\rm {({A}^{-1})}^{T} &=& \rm {({A}^{T})}^{-1}
\end{eqnarray}
$$

## 七、正交矩阵

&emsp;&emsp;具有实数项的方阵$\rm Q$满足：

$$
{\rm Q}^{-1} = {\rm Q}^{\rm T} \tag{7-1}
$$

这个矩阵被称为**正交矩阵(orthogonal matrix)**，其另一个定义写做：

$$
\rm {Q}{Q}^{T} = I, {Q}^{T}{Q} = I \tag{7-2}
$$

&emsp;&emsp;下面是一个$2-{\rm by}-2$的例子：

$$
{\rm Q} =
\left(
\begin{array}{\*{20}{c}}
{q\_{11}} & {q\_{12}} \newline
{q\_{21}} & {q\_{22}}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{\rm q\_1} & {\rm q\_2} \newline
\end{array}
\right)
$$

其中$\rm q\_1$和$\rm q\_2$是一个$2-{\rm by}-1$的列向量，于是有：

$$
\rm {Q}^{T}{Q} =
\left(
\begin{array}{\*{20}{c}}
{\rm q\_1^T} \newline
{\rm q\_1^T}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{\rm q\_1} & {\rm q\_2} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{\rm q\_1^T q\_1} & {\rm q\_1^T q\_2} \newline
{\rm q\_2^T q\_1} & {\rm q\_2^T q\_2}
\end{array}
\right)
$$

如果$\rm Q$是正交的，那么：

$$
\begin{eqnarray}
{\rm q\_1^T q\_1} = {\rm q\_2^T q\_2} = 1 \newline
{\rm q\_1^T q\_2} = {\rm q\_2^T q\_1} = 0
\end{eqnarray}
$$

也就是说，$\rm Q$的列互相为正交向量集；同理，也适用于其行向量。因此，正交矩阵的等效定义也可以是：一个具有实数项的方阵，其列(以及行)是一组正交向量。

&emsp;&emsp;正交矩阵的第三个定义如下。另$\rm Q$为一个$n-{\rm by}-n$的正交矩阵，另$\rm x$为一个$n-{\rm by}-1$的列向量。向量$\rm Qx$的长度(范数、模长)的平方可以写做：

$$
\rm {\left \Vert{Qx} \right \Vert}^{2} = {(Qx)}^{T}(Qx) = {x}^{T}{Q}^{T}{Q}{x} = {x}^{T}{I}{x} = {x}^{T}{x} = {\left \Vert{x} \right \Vert}^{2} \tag{7-3}
$$

我们发现$\rm Qx$的长度等于$\rm x$的长度，因此我们说正交矩阵是保留长度的矩阵。在下一节中，我们将看到正交矩阵的一个应用，它在二维空间中旋转一个向量。

## 八、旋转矩阵

&emsp;&emsp;假设我们现在有一个二维向量$(x,y)$，其与坐标轴的夹角为$\phi$，其长度为$r$；旋转$\theta$后的向量为$(x', y')$。我们用三角函数来表示这个新的向量：

$$
\begin{eqnarray}
x' = r {\rm cos}(\theta + \phi) = r ({\rm cos}{\theta}{\rm cos}{\phi} - {\rm sin}{\theta}{\rm sin}{\phi}) = x{\rm cos}{\theta} - y{\rm sin}{\theta} \newline
y' = r {\rm sin}(\theta + \phi) = r ({\rm sin}{\theta}{\rm cos}{\phi} + {\rm cos}{\theta}{\rm sin}{\phi}) = x{\rm sin}{\theta} + y{\rm cos}{\theta}
\end{eqnarray}
$$

将其用矩阵的形式表达则有：

$$
\left(
\begin{array}{\*{20}{c}}
{x'} \newline
{y'}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{{\rm cos}{\theta}} & {-{\rm sin}{\theta}} \newline
{{\rm sin}{\theta}} & {{\rm cos}{\theta}}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{x} \newline
{y}
\end{array}
\right)
$$

我们用$\rm R\_{\theta}$来表示上面这个$2-{\rm by}-2$的旋转矩阵。我们很容易发现其行列是正交的，并且其逆矩阵等于其转置。逆阵$\rm R\_{\theta}^{-1}$表示旋转了$- \theta$。

&emsp;&emsp;逆阵$\rm R\_{\theta}^{-1}$表示旋转了$- \theta$。我们将证明这一点：

三角函数具有：

$$
\begin{eqnarray}
{\rm sin}{(- \theta)} &=& -{\rm sin}{(\theta)} \newline
{\rm cos}{(- \theta)} &=& {\rm cos}{(\theta)}
\end{eqnarray}
$$

因此：

$$
{\rm R\_{- \theta}} =
\left(
\begin{array}{\*{20}{c}}
{{\rm cos}{(- \theta)}} & {-{\rm sin}{(- \theta)}} \newline
{{\rm sin}{(- \theta)}} & {{\rm cos}{(- \theta)}}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{{\rm cos}{\theta}} & {{\rm sin}{\theta}} \newline
{{- \rm sin}{\theta}} & {{\rm cos}{\theta}}
\end{array}
\right) =
{\rm R\_{\theta}^{-1}}
$$

证毕。

## 九、置换矩阵

&emsp;&emsp;正交矩阵的另一个例子是**置换矩阵(permutation matrices)**，下面是一个$2-{\rm by}-2$的例子，来看一下它是如何做置换的。

对于一个$2-{\rm by}-2$的矩阵来说，其列向量(或者行向量)可能的排序只有$(1,2)$或者$(2,1)$，如果按照前者排序，则该置换矩阵等于$\rm I$，如果按后者排序，可以写做：

$$
\left(
\begin{array}{\*{20}{c}}
{0} & {1} \newline
{1} & {0}
\end{array}
\right)
$$

下面是它和其他矩阵进行计算的例子：

$$
\left(
\begin{array}{\*{20}{c}}
{0} & {1} \newline
{1} & {0}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{a} & {b} \newline
{c} & {d}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{c} & {d} \newline
{a} & {b}
\end{array}
\right)
$$

当置换矩阵位于左边时，它交换了右侧矩阵的行。

$$
\left(
\begin{array}{\*{20}{c}}
{a} & {b} \newline
{c} & {d}
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{0} & {1} \newline
{1} & {0}
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{b} & {a} \newline
{d} & {c}
\end{array}
\right)
$$

当置换矩阵位于右边时，它交换了左侧矩阵的列。

&emsp;&emsp;对于一个$3-{\rm by}-3$的矩阵来说，其可能存在的排序组合有：$3! = 6$种，我们观察其中一种组合$(3,1,2)$是如何影响矩阵的：

$$
\left(
\begin{array}{\*{20}{c}}
{0} & {0} & {1} \newline
{1} & {0} & {0} \newline
{0} & {1} & {0} \newline
\end{array}
\right)
\left(
\begin{array}{\*{20}{c}}
{a} & {b} & {c} \newline
{d} & {e} & {f} \newline
{g} & {h} & {i} \newline
\end{array}
\right) =
\left(
\begin{array}{\*{20}{c}}
{g} & {h} & {i} \newline
{a} & {b} & {c} \newline
{d} & {e} & {f} \newline
\end{array}
\right)
$$

不难发现，置换矩阵将右侧的矩阵的行交换到了置换矩阵对应的位置上。

&emsp;&emsp;值得注意的是，置换矩阵只是通过对单位矩阵进行相应的置换得到的，上面的例子就是将$(1,2,3)$置换为$(3,1,2)$得到的。我们可以将一个行置换矩阵表示为：

$$
\rm PA = (PI)A
$$

$\rm P$是置换矩阵，$\rm PI$是具有置换行的单位矩阵。单位矩阵是正交的，因此通过对单位矩阵进行置换得到的置换矩阵也是正交的。因此，本节的开头才说置换矩阵是正交矩阵的另一个例子。