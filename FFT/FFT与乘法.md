[toc]

&emsp;本文旨在描述如何使用FFT进行快速乘法运算，[参考文献](https://cdn.swordofmorning.com/Thesis/ReferencePaper/FFT.pdf)。

## 1.离散傅里叶变换

&emsp;&emsp;令：
$$
{ \omega \text{ }=\text{ }e\mathop{{}}\nolimits^{{{{2 \pi i}/{n}}}}}
$$
为通常的n次单位根。

&emsp;&emsp;如果a = b，则令${ \delta \mathop{{}}\nolimits_{{ab}}\text{ }=\text{ }1}$，否则为0。得到：

$$
{\mathop{ \sum }\limits_{{c=0}}^{{n-1}}{ \omega \mathop{{}}\nolimits^{{c{ \left( {b-a} \right) }}}\text{ }=\text{ } \eta  \delta \mathop{{}}\nolimits_{{ab}}}}
$$

&emsp;&emsp;等式2的等效版本是如下两个矩阵：

$$
{M\text{ }=\text{ }\frac{{1}}{{\sqrt{{n}}}}{ \left[ {\begin{array}{*{20}{l}}
{1}&{1}&{1}&{ \cdots }\\
{1}&{ \omega \mathop{{}}\nolimits^{{-1}}}&{ \omega \mathop{{}}\nolimits^{{-2}}}&{ \cdots }\\
{1}&{ \omega \mathop{{}}\nolimits^{{-2}}}&{ \omega \mathop{{}}\nolimits^{{-4}}}&{ \cdots }\\
{ \cdots }&{ \cdots }&{ \cdots }&{ \ddots }
\end{array}} \right] }}
$$

$$
{M\mathop{{}}\nolimits^{{-1}}\text{ }=\text{ }\frac{{1}}{{\sqrt{{n}}}}{ \left[ {\begin{array}{*{20}{l}}
{1}&{1}&{1}&{ \cdots }\\
{1}&{ \omega \mathop{{}}\nolimits^{{1}}}&{ \omega \mathop{{}}\nolimits^{{2}}}&{ \cdots }\\
{1}&{ \omega \mathop{{}}\nolimits^{{2}}}&{ \omega \mathop{{}}\nolimits^{{4}}}&{ \cdots }\\
{ \cdots }&{ \cdots }&{ \cdots }&{ \ddots }
\end{array}} \right] }}
$$

&emsp;&emsp;*离散傅里叶变*换是线性变换，${ \Phi :\text{ }C\mathop{{}}\nolimits^{{n}} \to C\mathop{{}}\nolimits^{{n}}}$，其矩阵是M。所以，给定${z\text{ }=\text{ } \left( z\mathop{{}}\nolimits_{{1}}, \cdots ,z\mathop{{}}\nolimits_{{n}} \right) }$，于是得到：

