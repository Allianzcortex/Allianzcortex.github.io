---
layout: post
title: The Import Mechanism Of Python And Two Related Problems
date: 2017-05-22 13:29:10
categories: Python
comments: true
---

How to solve `No module named` and `Attempted relative import` ?

<!-- more -->

[这篇文章对应的中文版](/../translation/2017-05-22-Python-Import-Mechanism.html)

### No module named 

This problem ever happened when executed with the command line, but the application can be executed smoothly with the Pycharm run button. The error is also very simple to debug, just check the **show command line afterwards** in the edit configuration item of Pycharm, and then execute the `import sys; sys.path` command. Compare the options in the command line,you will find the former has Added a module for `/home/hzcortex/projects...`. In other words, Python does not add the directory where the script executes the command to sys.path.

---

The solution is to add the following code in the directory where error happened:

{% highlight Python %}
import sys
from os import path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

{% endhighlight %}

### Attempted relative import in non  package

There are two types of issues to discuss:

1 A circular reference does occur. A wants to reference B, B wants to reference C, and C also refers to a function in B. The normal solution at this point is to modify the reference order of the C files and put the `import` statement before the statement that needs to use the reference object (see 《Fluent Python》). I recently encountered this problem when developing [FBRank] (https://github.com/Allianzcortex/FBRank). The project structure is like :

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

Then there was such an error when executing the program:

```
File "/home/hzcortex/FBRank/FBRank/parse/League.py", line 13, in <module>
    from FBRank.utils.exceptions import IllegalArgumentException, NotSupprotedYetException
  File "/home/hzcortex/FBRank/FBRank/utils/exceptions.py", line 2, in <module>
    from .utils import github_url, connect_url
  File "/home/hzcortex/FBRank/FBRank/utils/utils.py", line 5, in <module>
    from .exceptions import NotSupprotedYetException
ImportError: cannot import name 'NotSupprotedYetException'

```

Looking at the order of the calls from top to bottom, the `github_url, connect_url` variables are called from .utils.py in /exceptions.py, and **NotSupprotedYetException** is called from /exceptions.py when calling .utils.py. This will cycle through each other and will never solve the **import issue**. The solution is to load it only when you need to use the function:

{% highlight Python %}
# utils.py

def check_before(attr='name'):
    from .exceptions import NotSupprotedYetException
    # ......

{% endhighlight %}

Because Python's reference mechanism does not reimport previously imported packages (use `imp.reaload()` if needed), so don't worry about performance problem.

2. If there is really no circular reference, problem maybe is mainly because:

Take an example of a program push data from Kafka to ES that was previously written. The structure of the whole program is as follows 

![RLTES-Project](/images/RLTES-2.png)

In the main program `RealtimeLogToES.py` there are the following references:

![RLTES-import](/images/RLTES-1.png)

Go to the RLTES directory and execute `python RealtimeLogToES.py` directly in this case, then the above circular reference error will be reported.

There are two solutions:

1 Change `from .config import` to the same absolute reference as below, `from RLTES.config import`

2 Do not modify the code, return to the previous directory, `cd ..`, and then execute `python -m RLTES.RealtimeLogToES`

When Python is relatively introduced, the basis for the judgment is the `__name__` attribute of the current file. When you execute a file, the original `__name__` attribute of the file is replaced by the fixed `'__main__'`, so the relative introduction does not work, while the absolute introduction is fine. After adding -m to the command line, tell the Python interpreter to run this file as a script.

### Why the problem happened

If there is sufficient time,I will try to explain it. Now you can read [PEP302](https://www.python.org/dev/peps/pep-0302/) to hava a straightforward impression.

### How We Do Properly

The recommendation in PEP8 is to always use absolute references, but just like the `annoying double underscore`, there are a lot of people who prefer to use relative import.

The key is to Keep the team consistent. As for personal development, I prefer to use `.import` for single layer and absolute reference for others.

In the book "Two Scopes Of Django" **, it is stipulated that the use of the **implicit import** statement such as `from A import a` is forbidden, but considering that many times the script will not be specific to a large project but to create a directory on the server to complete a specific function or solve a temporary problem(don't need to maintain), if this is convenient for debugging and deployment,it can also be a good choice,done is better than perfect after all.

### The role of `__init__.py`

The most important role of `__init__.py` is to mark the folder containing the `__init__.py` directory as a package to complete the corresponding import.

In most cases, there is no need to write anything in `__init__.py`. If you must write it, it basically has the following three functions:

- Write `__author__` and other related information

- Write a `__all__` configuration that exactly defines what will be introduced when `from x import *`

- If the first two are irrelevant, then the last one is much more important, and the importing method can be simplified to control the stability of the API.

Let me still take the example of [FBRank] (github.com/Allianzcortex/FBRank). Although you see that the command line tool is only supported in the README, it also provides the ability to import it in the code. for example:

If you need to assign the corresponding file if you need to  import an exception

{% highlight Python %}
 In [1]: from FBRank.utils.exceptions import IllegalArgumentException
{% endhighlight %}

But if you want to import a class, you only need to identify the corresponding package, which is very convenient for subsequent development.

{% highlight Python %}
In [2]: from FBRank.object import Club
{% endhighlight %}

The key it  the following code in `__init__.py` of FBRank/object folder.Import something from package is equal to import something from file under this package.

{% highlight Python %}
  from .League import League
  from .Club import Club
  from .Player import Player
{% endhighlight %}



