# Linear Algebra 04 Eigenvalues and Eigenvectors

## 一、行列式

&emsp;&emsp;行列式的基本定义已经在《Linear Algebra 01 Matrix》中的第六章“逆矩阵”中简单讨论。这里不再赘述。

### 1.1 基本性质

&emsp;&emsp;下面我们简要说明一下行列式具有的性质：

1. 行列式中一行(列)全为零，则此行列式的值为0；
2. 在某一行(列)有公因子$k$，则可以将其提前：$\left(\begin{array}{\*{20}{c}} {a} & {b} \newline {kc} & {kd} \newline \end{array} \right) = k \left(\begin{array}{\*{20}{c}} {a} & {b} \newline {c} & {d} \newline \end{array} \right)$；
3. 某一行(列)的每个元素是两数之和，可以拆分为两个相加的行列式：$\left(\begin{array}{\*{20}{c}} {a} & {b} \newline {c + e} & {d + f} \newline \end{array} \right) = \left(\begin{array}{\*{20}{c}} {a} & {b} \newline {c} & {d} \newline \end{array} \right) + \left(\begin{array}{\*{20}{c}} {a} & {b} \newline {e} & {f} \newline \end{array} \right)$；
4. 两行(列)互换，改变行列式的正负号；
5. 两行(列)成比例，行列式值为0；
6. 将一行(列)的$k$倍加**到**另一行(列)，值不变；
7. 行列式“转置”，值不变；

### 1.2 拉普拉斯展开

&emsp;&emsp;设$\rm B$是一个$n-{\rm by}-n$的矩阵。$\rm B$的第$i$行$j$列的**余子式**${\rm M}\_{ij}$指$\rm B$中去掉$i$行$j$列的$n-1$阶子矩阵的行列式。${\rm M}\_{ij}$的**代数余子式**表示为${\rm C}\_{ij} = (-i)^{i+j}{\rm M}\_{ij}$。

&emsp;&emsp;行列式$\left| {\rm B} \right|$，沿$i$行或$j$列展开如下：

$$
\begin{eqnarray}
    \left| {\rm B} \right| &=&
        {\rm b}\_{i1}{\rm C}\_{i1} + {\rm b}\_{i2}{\rm C}\_{i2} + \dots + {\rm b}\_{in}{\rm C}\_{in} \newline &=&
        {\rm b}\_{1j}{\rm C}\_{1j} + {\rm b}\_{2j}{\rm C}\_{2j} + \dots + {\rm b}\_{nj}{\rm C}\_{nj}
\end{eqnarray}
$$

&emsp;&emsp;我们来看一个数值化的例子，考虑如下矩阵：

$$
{\rm B}= 
\left(
\begin{array}{\*{20}{c}}
{1} & {2} & {3} \newline
{4} & {5} & {6} \newline
{7} & {8} & {9}
\end{array}
\right)
$$

我们可以沿着第1行展开：

$$
\begin{eqnarray}
    \left| {\rm B} \right| &=&
        1 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {5} & {6} \newline
                {8} & {9}
            \end{array}
        \right|
        -2 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {4} & {6} \newline
                {7} & {9}
            \end{array}
        \right|
        +3 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {4} & {5} \newline
                {7} & {8}
            \end{array}
        \right| \newline &=&
        1 \cdot (-3) -2 \cdot (-6) +3 \cdot (-3) \newline &=&
        0
\end{eqnarray}
$$

我们也可以沿着第2列展开：

$$
\begin{eqnarray}
    \left| {\rm B} \right| &=&
        -2 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {4} & {6} \newline
                {7} & {9}
            \end{array}
        \right|
        +5 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {1} & {3} \newline
                {7} & {9}
            \end{array}
        \right|
        -8 \cdot
        \left| 
            \begin{array}{\*{20}{c}}
                {1} & {3} \newline
                {4} & {6}
            \end{array}
        \right| \newline &=&
        -2 \cdot (-6) +5 \cdot (-12) -8 \cdot (-6) \newline &=&
        0
\end{eqnarray}
$$

### 1.3 莱布尼兹公式

&emsp;&emsp;参考《Linear Algebra 01 Matrix》中的第六章“逆矩阵”中简单讨论。

## 二、特征值

### 2.1 概念

&emsp;&emsp;让$\rm A$为一个方阵，$\rm x$是一个列向量，$\lambda$是标量，奇异值问题由下给出：

$$
{\rm Ax} = \lambda {\rm m}
$$

对于上述方程，我们将其改写为齐次方程的形式：

$$
({\rm A} - \lambda{\rm I}){\rm x} = 0
$$

其中${\rm A} - \lambda{\rm I}$就是$\rm A$的对角线减去$\lambda$。为了存在非零特征向量，矩阵${\rm A} - \lambda{\rm I}$必须是奇异的，即：

$$
{\rm det}({\rm A} - {\lambda}{\rm I}) = 0
$$

这个等式被称为矩阵$\rm A$的**特征方程(characteristic equation)**，由莱布尼兹方程可以知道，特征方程是一个$n-{\rm by}-n$的矩阵的关于$\lambda$的$n$阶多项式。对于每一个找到的特征值$\lambda i$和对应的特征向量${\rm x}\_i$，可以通过解向量$\rm x$的方程$({\rm A} - {\lambda}\_i {\rm I})x = 0$得到。

&emsp;&emsp;我们通过一个$2-{\rm by}-2$的例子来说明这个问题：

$$
0 = {\rm det}({\rm A} - \lambda {\rm I}) = \left|
    \begin{array}{\*{20}{c}}
        {a - \lambda} & {b} \newline
        {c} & {d - \lambda}
    \end{array}
\right| =
(a - \lambda)(d - \lambda) - bc =
{\lambda}^{2} - (a+d){\lambda} + (ad-bc)
$$

这个特征方程可以重写为：

$$
{\lambda}^{2} - {\rm Tr(A)}\lambda + {\rm det(A)} = 0
$$

其中${\rm Tr(A)}$称为矩阵的**迹(trace)**，它是矩阵的主对角线元素之和。

&emsp;&emsp;由于$2-{\rm by}-2$的特征方程是二次方程，因此它具有：(1)两个不同的实根；(2)个不同的复共轭根；(3)一个退化实根。更一般地，特征值可以是实数或复数，并且$n-{\rm by}-n$矩阵可以具有少于$n$个不同的特征值。

### 2.2 例子

&emsp;&emsp;假设我们现在有矩阵$\rm A$，我们要求它的特征值。矩阵$\rm A$定义如下：

$$
\left(
    \begin{array}{\*{20}{c}}
        {0} & {1} \newline
        {1} & {0}
    \end{array}
\right)
$$

我们通过求它关于$\rm x$的特征方程${\rm Ax} = \lambda {\rm x}$来得到$\lambda$，我们将其改写为：$({\rm A} - {\lambda}{\rm I}){\rm x} = 0$，于是有：

$$
{\rm det}({\rm A} - {\lambda}{\rm I}) = 0 = \left|
    \begin{array}{\*{20}{r}}
        {- \lambda} & {1} \newline
        {1} & {- \lambda}
    \end{array}
\right| =
{\lambda}^2 - 1
$$

得到${\lambda}\_1 = 1, {\lambda}\_2 = -1$。第一个特征向量通过$({\rm A} - {\lambda}\_{1}{\rm I}){\rm x}$得到：

$$
\left(
    \begin{array}{\*{20}{r}}
        {-1} & {1} \newline
        {1} & {-1}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{r}}
        {x\_1} \newline
        {x\_2}
    \end{array}
\right) = 0
$$

得到$x\_1 = x\_2$。同理，第二个特征向量通过$({\rm A} - {\lambda}\_{2}{\rm I}){\rm x}$得到：

$$
\left(
    \begin{array}{\*{20}{r}}
        {1} & {1} \newline
        {1} & {1}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{r}}
        {x\_1} \newline
        {x\_2}
    \end{array}
\right) = 0
$$

得到$x\_1 = -x\_2$。我们将结果写为：

$$
{\lambda}\_{1} = 1, {x}\_{1} = 
\left(
    \begin{array}{\*{20}{r}}
        {1} \newline
        {1}
    \end{array}
\right); \quad
{\lambda}\_{2} = -1, {x}\_{2} = 
\left(
    \begin{array}{\*{20}{r}}
        {1} \newline
        {-1}
    \end{array}
\right)
$$

其中$x\_1$和$x\_2$仍选一个作为常量，另一个作为变量即可。

&emsp;&emsp;这里需要注意的是，对于任意n阶方阵都有：${\lambda}\_{1} + {\lambda}\_{2} = {\rm Tr(A)}$，并且${\lambda}\_{1}{\lambda}\_{2}={\rm det(A)}$。

## 三、矩阵对角化

### 3.1 概念

&emsp;&emsp;我们从一个$2-{\rm by}-2$的矩阵$\rm A$来考察，其特征值如下给出：

$$
{\lambda}\_{1}, {x}\_{1} = 
\left(
    \begin{array}{\*{20}{r}}
        {{x}\_{11}} \newline
        {{x}\_{21}}
    \end{array}
\right); \quad
{\lambda}\_{2}, {x}\_{2} = 
\left(
    \begin{array}{\*{20}{r}}
        {{x}\_{12}} \newline
        {{x}\_{22}}
    \end{array}
\right)
$$

同时我们考虑对矩阵做如下的因式分解：

$$
{\rm A} \left(
    \begin{array}{\*{20}{r}}
        {{x}\_{11}} & {{x}\_{12}} \newline
        {{x}\_{21}} & {{x}\_{22}}
    \end{array}
\right) =
\left(
    \begin{array}{\*{20}{r}}
        {{\lambda}\_{1}{x}\_{11}} & {{\lambda}\_{2}{x}\_{12}} \newline
        {{\lambda}\_{1}{x}\_{21}} & {{\lambda}\_{2}{x}\_{22}}
    \end{array}
\right) =
\left(
    \begin{array}{\*{20}{r}}
        {{x}\_{11}} & {{x}\_{12}} \newline
        {{x}\_{21}} & {{x}\_{22}}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{r}}
        {{\lambda}\_{1}} & {0} \newline
        {0} & {{\lambda}\_{2}}
    \end{array}
\right)
$$

我们将$\rm S$定义为矩阵$\rm A$的特征向量矩阵，把矩阵$\rm \Lambda$定义为特征值的对角矩阵。那么对于一个n阶、并且有n个线性无关的特征向量的方阵，我们有：

$$
\rm AS = S{\Lambda}
$$

其中$\rm S$是可逆矩阵，我们有：

$$
\rm A=S{\Lambda}S^{-1}, \quad {\Lambda}={S}^{-1}AS
$$

### 3.2 例子

&emsp;&emsp;我们尝试对以下矩阵进行对角化：

$$
{\rm A} \left(
    \begin{array}{\*{20}{c}}
        {a} & {b} \newline
        {b} & {a}
    \end{array}
\right)
$$

&emsp;&emsp;$\rm A$的特征值由以下给出：

$$
{\rm det}({\rm A} - {\lambda}{\rm I}) = 0 =  \left|
    \begin{array}{\*{20}{c}}
        {a - {\lambda}} & {b} \newline
        {b} & {a - {\lambda}}
    \end{array}
\right| = (a - {\lambda})^2 - b^2 = 0
$$

于是${\lambda}\_{1} = a+b$、${\lambda}\_{2} = a-b$。对于${\lambda}\_{1}$有：

$$
\left(
    \begin{array}{\*{20}{c}}
        {-b} & {b} \newline
        {b} & {-b}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{c}}
        {{x}\_{11}} \newline
        {{x}\_{21}}
    \end{array}
\right) =
\left(
    \begin{array}{\*{20}{c}}
        {0} \newline
        {0}
    \end{array}
\right)
$$

对于${\lambda}\_{2}$有：

$$
\left(
    \begin{array}{\*{20}{c}}
        {b} & {b} \newline
        {b} & {b}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{c}}
        {{x}\_{12}} \newline
        {{x}\_{22}}
    \end{array}
\right) =
\left(
    \begin{array}{\*{20}{c}}
        {0} \newline
        {0}
    \end{array}
\right)
$$

于是：

$$
{\rm x\_1} =
\frac{1}{\sqrt{2}}
\left(
    \begin{array}{\*{20}{c}}
        {1} \newline
        {1}
    \end{array}
\right), \quad
{\rm x\_2} =
\frac{1}{\sqrt{2}}
\left(
    \begin{array}{\*{20}{c}}
        {1} \newline
        {-1}
    \end{array}
\right)
$$

因为特征向量$\rm S$是正交的，因此$\rm S^{-1}= S^{T}$，我们有：

$$
\rm S = \frac{1}{\sqrt{2}}
\left(
    \begin{array}{\*{20}{c}}
        {1} & {1} \newline
        {1} & {-1}
    \end{array}
\right), \quad
S^{-1} = S^T = S
$$

矩阵对角化的结果是：

$$
\left(
    \begin{array}{\*{20}{c}}
        {a+b} & {0} \newline
        {0} & {a-b}
    \end{array}
\right)=
\frac{1}{2}
\left(
    \begin{array}{\*{20}{r}}
        {1} & {1} \newline
        {1} & {-1}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{c}}
        {a} & {b} \newline
        {b} & {a}
    \end{array}
\right)
\left(
    \begin{array}{\*{20}{r}}
        {1} & {1} \newline
        {1} & {-1}
    \end{array}
\right)
$$

## 四、矩阵的幂

&emsp;&emsp;矩阵对角化有助于计算矩阵的幂。假设矩阵$\rm A$可对角化，于是：

$$
\rm A^2 = (S{\Lambda}S^{-1})(S{\Lambda}S^{-1}) = S{\Lambda}^{2}S^{-1}
$$

对于$p$次幂则有：

$$
\rm A^{p} = S{\Lambda}^{p}S^{-1}
$$