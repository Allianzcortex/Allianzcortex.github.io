---
layout: post
title: 一些有趣的逻辑问题
date: 2017-04-08 13:12:57
categories: logic
comments: true
---

逻辑问题......
<!-- more -->

1. 第一个问题是在已有的一个随机数基础上再生成一个随机数，确保生成 0 和 1 的概率是相等的

思路也很直接啦。

来写一个程序验证一下：

{% highlight Python %}
from __future__ import division, print_function # compatible with Py2
from random import randint


def rand(p=0.3):
    p = p * 10
    num = randint(1, 10)
    return 0 if (num <= p) else 1


def new_rand():
    _prev, _next = -1, -1
    while True:
        if(_prev == 0 and _next == 1):
            return 0
        if(_prev == 1 and _next == 0):
            return 1
        _prev = rand()
        _next = rand()


def check():
    sum_zero, sum_one = 0, 0
    for _ in xrange(10000):
        gen_num = new_rand()
        if(gen_num == 0):
            sum_zero += 1
        else:
            sum_one += 1
    print("rate is {}".format(sum_one / sum_zero))


if __name__ == '__main__':
    check()  # 3 sample results: 1.00320512821,1.01938610662,0.982160555005

{% endhighlight %}