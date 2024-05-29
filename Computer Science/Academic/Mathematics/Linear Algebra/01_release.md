# Linear Algebra 01 Matrix

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
{a\_{m1}}&{a\_{m2}}&{\cdots}&{a\_{mn}} \newline
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

&emsp;&emsp;如果我们用$\rm A$来表示一个$m-{\rm by}-p$的矩阵，其元素用$a\_{ij}$来表示；用$\rm B$来表示一个$p-{\rm by}-n$的矩阵，其元素用$b\_{ij}$来表示。那么，$C=AB$就是一个$m-{\rm by}-p$的矩阵，其中的元素$c\_{ij}$可以表示为：

$$
C\_{ij} = \mathop{\sum} \limits\_{k=1}^{n} {a\_{ik} \cdot b\_{kj}}
$$