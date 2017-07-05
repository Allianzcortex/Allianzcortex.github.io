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

2. 第二个问题其实就是数据可用性的问题

最后抽象出黑盒问题：

```
# -*- coding:utf-8 -*-
from __future__ import division

from random import randint


def gen_unique_list():
    i = 0
    res = set()
    while i < 100000:
        temp = [1] * 5
        while True:
            r1, r2, r3 = randint(0, 4), randint(0, 4), randint(0, 4)
            if(r1 != r2 and r1 != r3 and r2 != r3):
                temp[r1] = 0
                temp[r2] = 0
                temp[r3] = 0
                break
        if tuple(temp) not in res:
            res.add(tuple(temp))
        i += 1
    return res


def gen_probability():
    res = gen_unique_list()
    prob = 0
    for elem in res:
        # find last occurence
        print elem
        ind = 4 - list(reversed(elem)).index(0)
        red_cnt, green_cnt = 3, 2
        x = 1
        # for in in range(0,ind)  这句话就是另一种思路了，显然不应该，最后得出的和都大于 1 了
        for i in range(0, 5):
            if(elem[i] == 0):
                # means red
                x *= (red_cnt / (red_cnt + green_cnt))
                red_cnt -= 1
            else:
                # means green
                x *= (green_cnt / (red_cnt + green_cnt))
                green_cnt -= 1
        prob += x
        print x
    print prob


if __name__ == '__main__':
    gen_probability()


```

但实际上直接 C(5,3) 就足够了......自己想的太复杂

这还只是一份数据，那么如果有两份数据呢。是在第一份数据可用的前提下 * 第二份数据可用，那么这两个问题就应该是独立的。
因为前提是机器损坏已经发生了