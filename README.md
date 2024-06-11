# 博客文档

[![en](https://img.shields.io/badge/Lang-En-blue.svg)](./README.en.md)

博客地址：<a href = "https://swordofmorning.com/">SwordofMorning</a>

## 一、简要说明

&emsp;这是用于存放我个人博客原文的项目，结构如下所示，主要分为：计算机科学、其他、哲学、政治经济学四个部分。

```sh
.
├───.vscode
├───Computer Science
│   ├───Academic
│   │   ├───Architecture                # 架构
│   │   ├───Concurrent Programming      # 并行计算
│   │   ├───Design Pattern              # 设计模式
│   │   ├───Git                         # Git
│   │   ├───Lang                        # 编程语言相关
│   │   ├───Linux                       # Linux环境下的开发
│   │   ├───Machine Learning            # 机器学习
│   │   ├───Mathematics                 # 数学
│   │   └───Vision                      # 计算机视觉
│   └───Engineering
│       ├───Android                     # 安卓应用开发
│       └───Chip                        # 嵌入式开发，按照芯片分类
├───Other
│   ├───CangKu                          # 其他平台发布的博客
│   ├───Config                          # 个人常用的各类配置文件
│   ├───DCS                             # DCS:World笔记
│   └───Patent                          # 软著与专利
├───Philosophy                          # 哲学，已经很有没有维护了
└───Political Economy
    ├───Political Economy Essay         # 政治经济学随笔，个人感悟为主
    └───Political Economy Introduction  # 政治经济学导论，读书笔记
```

## 二、其他事项

&emsp;&emsp;我的博客经过一次迁移，最初并未以Markdown的形式发布在Github。如果你看到的`.md`文档里面实际是一堆HTML，则说明该文档是我21年之前写的，在将其从Wordpress迁移出来的时候由Markdown变成了HTML。您可以前往我的博客网站查看，如果遇到公式未能加载的情况，请刷新一次网页。

&emsp;&emsp;我的部分博客可能会写两份文档，其中一份的后缀名为`release`。通常，该版本是为了在我的博客上发布使用，对latex公式做了一定的修改。比如，`**lr**`会被修改为`\*\*lr\*\*`；`A_{ij}`会被修改为`A\_{ij}`。这是因为我博客的编辑器同时使用了markdown和MathJax(latex)解析，因此需要用`\`标注markdown中的特殊符号。