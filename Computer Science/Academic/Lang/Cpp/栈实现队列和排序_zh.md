# 用栈实现队列和排序

[toc]

&emsp;&emsp;在本文中，我们将讨论如何用栈来实现队列和排序。这都需要使用两个栈来实现。

## 一、队列

&emsp;&emsp;这里我们有一个堆栈“st1”，我们将使用临时堆栈“st2”来反转“st1”。 所以，我们可以给出方法一：

1. in queue: directly in `st1`.
2. out queue: reverse `st1` to `st2`, next pop the top, then reverse `st2` to `st1`.

&emsp;&emsp;这是常见的实现方法，为了减少操作步骤，我们可以有方法二：

1. in queue: directly in `st1`.
2. out queue: **if** `st2` not empty, pop from `st2`; **else if** `st2` empty, reverse `st1` to `st2`, then pop from `st2`.

示例代码如下：

```cpp
// use stack to implement queue.
template<typename elemType>
class stque {
private:
	std::stack<elemType> m_st1;
	std::stack<elemType> m_st2;

	void reverse()
	{
		while (!m_st1.empty())
		{
			m_st2.push(m_st1.top());
			m_st1.pop();
		}
	}

public:
	stque() { /* do nothing */ }

	void push(elemType ele)
	{
		m_st1.push(ele);
	}

	elemType pop()
	{
		if (m_st1.empty() && m_st2.empty()) 
		{
            throw std::out_of_range("Queue is empty.");
        }

		// if st2 empty, reverse st1 to st2 first, then pop.
		if (m_st2.empty())
		{
			this->reverse();
		}

		// if st2 not empty, directly pop.
		elemType retval = m_st2.top();
		m_st2.pop();
		return retval;
	}
};
```

## 二、排序

&emsp;&emsp;排序和队列的思路是一样的，方法如下。我们有需要被排序的栈的`st1`，和排序后的栈栈`st2`，即输出。我们使用`lt <`作为顺序原则。

<!-- 1. Firstly, We'll push all elements into `st1`.
2. Then move one element from `st1` to `st2`.
3. While `st1` is not empty, we compare the `st1.top` and `st2.top`, if `st1.top < st2.top`, then we just need to push `st2.top` into `st1`; else if `st1.top >= st2.top`, we need to push the `st2.top` into `st1`, then use -->

> 即每次从栈s中弹出一个元素a，并判断它与s2之间的栈顶元素b的大小，如果a小于等于b，则将其压入s2， 否则，将 s2 出栈，并入栈到 s 中，直到 s2 的栈顶元素恰好小于 a，将 a 放入栈 s2 中，重复上述步骤，直至 s 为空。

示例代码如下：

```cpp
// use stack to implement sort.
template<typename elemType>
class stsort {
public:
	// sort principle: <, for st2: small nums on top, big nums in bottom
	std::stack<elemType> sort(std::stack<elemType> st1)
	{
		std::stack<elemType> st2;

		st2.push(st1.top());
		st1.pop();

		while (!st1.empty())
		{
			elemType st1Top = st1.top();
			st1.pop();

		loop:
			elemType st2Top = st2.top();
			st2.pop();
			if (st1Top < st2Top)
			{
				st2.push(st2Top);
				st2.push(st1Top);
			}
			else
			{
				st1.push(st2Top);
				if (st2.empty())
				{
					st2.push(st1Top);
					continue;
				}
				goto loop;
			}
		}
		return st2;
	}
};
```