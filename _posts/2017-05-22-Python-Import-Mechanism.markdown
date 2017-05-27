---
layout: post
title: Python 中的引用机制
date: 2015-03-11 13:29:10
categories: Python
comments: true
---

解决 `No module named` 和 `Attempted relative import` 这两个问题
<!-- more -->

##### 两个引用时最常见的问题

###### No module named XXX

在编译时遇到 `No Module Named XX` 。这个问题曾经遇到过，并且用命令行执行时会报错，但用 Pycharm 的运行按钮就可以顺利执行。最后发现错误的过程也很简>单，在编辑配置一项里勾选 "show command line afterwards"，然后执行　`import sys;sys.path` 命令，和在命令行里的选项进行对比，发现前者多了一个 `/home/hzcortex/projects...` 的模块。也就是说 Python 并没有把执行命令的这个脚本所在的目录加入 sys.path 中。

---

解决方法是在报错的文件目录下加入：
{% highlight Python %}
import sys
from os import path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

{% endhighlight %}

{% highlight Python %}
import sys
from os import path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

class Solution(object):
	def 
{% endhighlight %}

###### Attempted relative import in non  package


