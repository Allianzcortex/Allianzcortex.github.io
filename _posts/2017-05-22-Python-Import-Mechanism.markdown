---
layout: post
title: Python 中的引用机制
date: 2015-03-11 13:29:10
categories: Python
comments: true
---

解决 `No module named` 和 `Attempted relative import` 这两个问题
<!-- more -->

## 两个引用时最常见的问题

### No module named XXXz

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

{% endhighlight %}

### Attempted relative import in non  package

这个问题要分两类来进行讨论：

① 在引用的时候确实发生了循环引用，A 要引用 B，B 要引用 C，而 C 同时要引用 B 里的一个函数。这时通常的解决办法是修改 C 文件的引用顺序，把 `import` 语句放到需要使用引用对象的语句前(参考 《Python 核心编程》 的说法)。最近在开发 [FBRank](https://github.com/Allianzcortex/FBRank) 的时候确实遇到了这个问题，项目结构是这样的：

{% highlight Python %}
└── utils
    ├── exceptions.py
    ├── __init__.py

# utils.py
 from .exceptions import NotSupprotedYetException

def check_before(attr='name'):
    ...
    raise NotSupprotedYetException
    ...

# exceptions.py
from .utils import github_url, connect_url

class NotSupprotedYetException(FBRankException):
    """still not supprt
    """

{% endhighlight %}

之后在执行程序的时候出现了这样的错误：

```
File "/home/hzcortex/FBRank/FBRank/parse/League.py", line 13, in <module>
    from FBRank.utils.exceptions import IllegalArgumentException, NotSupprotedYetException
  File "/home/hzcortex/FBRank/FBRank/utils/exceptions.py", line 2, in <module>
    from .utils import github_url, connect_url
  File "/home/hzcortex/FBRank/FBRank/utils/utils.py", line 5, in <module>
    from .exceptions import NotSupprotedYetException
ImportError: cannot import name 'NotSupprotedYetException'

```
自上而下看调用的顺序，在 /exceptions.py 里从 .utils.py 调用了 `github_url, connect_url` 这两个变量，而在调用 .utils.py 时又从 /exceptions.py 调用了 NotSupprotedYetException，这样就互相循环，永远都无法解决引入。解决办法就是只在需要使用的函数时再加载：


{% highlight Python %}
# utils.py

def check_before(attr='name'):
    from .exceptions import NotSupprotedYetException
    # ......

{% endhighlight %}

因为 Python 的引用机制并不会重新引入之前已经引入的包(需要的话要用 `imp.reaload()`)，所以不用担心这种引入会对性能产生影响

② 如果确实没有循环引用，那么通常是如下的情况：

拿之前写的一个从 Kafka 向 ES 导数据的程序来举例子。整个程序的结构如下(好像紫色对比度比较高...)：

![RLTES-Project](/images/RLTES-2.png)

在主程序 `RealtimeLogToES.py` 里有如下的引用：

![RLTES-import](/images/RLTES-1.png)

如果在这种情况下进入到 RLTES 目录里直接执行 `python RealtimeLogToES.py`，那么就会报上面的循环引用的错。

解决方法再有以下两种：

① 将 `from .config import` 改为和下面一样的绝对引用，`from RLTES.config import`

② 不修改代码，退回到上一层目录,`cd ..`，之后执行 `python -m RLTES.RealtimeLogToES`

Python 在进行相对引入的时候，判断的根据是当前文件的 __name__ 属性。而当你执行一个文件的时候，该文件原有的 __name__ 属性被替代为了固定的 '__main__',所以相对引入就无法工作，而绝对引入是没有问题的。在命令行里加入-m 后，告诉 Python 解释器应该将这个文件作为一个脚本来运行。

##### 为什么会发生这种问题

要真正理解 Python 的 import 机制是如何查找变量的。

##### 到底怎么引用

PEP8 里建议是一直用绝对引用，但就像那个 `annoying double underscore` 一样，不喜欢绝对引用的也大有人在。

团队里面保持一致即可。就个人开发来说，还是更喜欢单层采用用 .import，其他用绝对引用。

在 **《Two Scopes Of Django》** 一书里明确说明了禁止使用如 `from A import a` 这样的 **implicit import** 语句，但考虑到很多时候写脚本并不会具体到一个大的工程，而是在服务器上建立一个目录去完成一个特定的功能，如果这么写能方便调试和部署，那么也没有大的问题。

##### `__init__.py` 的作用

`__init__.py` 最重要的作用就是标记含有该 `__init__.py` 目录的文件夹为一个 package ，从而完成对应的引入。

大部分情况下 `__init__.py` 里什么内容也不用写，如果一定要写的话基本有以下三个作用：

- 写 `__author__` 等有关信息

- 写一个 `__all__` 的配置，精确定义在 `from x import *` 时候会引入的内容

- 如果说前两个都无关紧要的话，那么最后一个就比较多了，可以简化引入方式，用来控制 API 的稳定性。

  还是拿写的 [FBRank](github.com/Allianzcortex/FBRank) 来举例子。虽然你看在 README 里写的是只支持命令行工具，但其实它也提供了在代码里引入的能力。举个例子：

  {% highlight Python %}
  # 想要引入某个异常，需要具体到对应的文件
  In [1]: from FBRank.utils.exceptions import IllegalArgumentException

  # 但想要引入某个类，只要具体到对应的 package 就可以了
  In [2]: from FBRank.object import Club

  # 具体原因是在 FBRank/object 下的 __init__.py 里有如下代码
  from .League import League
  from .Club import Club
  from .Player import Player
  {% endhighlight %}


