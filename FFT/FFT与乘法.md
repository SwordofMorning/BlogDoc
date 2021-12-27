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