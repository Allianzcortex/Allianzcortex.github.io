---
title: Python one-line 实现多进程和多线程(修正版)
date: 2014-06-22 10:49:24
categories: Python
tags: [Python]
---
用 `multiprocessing` 和 `multiprocessing.dummy` 来实现多进程/实现多进程和多线程，增加了 ThreadPoolExecutor 以及其他内容

<!-- more -->

#### 直接使用 one-line 

关于 multiprocessing 和 Thread 之间的 pros 和 cons 就不多做描述了，因为关键是我们要让我们的代码来并行对吧:-D

关于使用就直接看这篇文章 [parallelism-in-one-line](http://chriskiehl.com/article/parallelism-in-one-line/) 好啦

来提供一个所写的例子：

{% highlight Python %}
# -*- coding:utf-8 -*-

"""
对某个目录下的文件求 md5 值
"""

import os
import hashlib
from multiprocessing import Pool as ProcessPool
from multiprocessing.dummy import Pool as ThreadPool
from datetime import datetime


def traverse_dir(dir_='/home/'):
    for origin_dir, current_dir, filename in os.walk(dir_):
        for file_ in filename:
            yield origin_dir + file_


def create_hash(filename):
    hashlib.md5(filename)
    temp = reduce(lambda x, y: x * y, range(1, 300))

if __name__ == '__main__':

    file_list = list(traverse_dir())
    # import random
    # random.shuffle(file_list)
    print '共有 {} 个文件'.format(len(file_list))
    time1 = datetime.now()
    for filename in file_list:
        create_hash(filename)
    print '普通执行状况: {}'.format((datetime.now() - time1).total_seconds())

    pool = ProcessPool(4)
    time2 = datetime.now()
    pool.map(create_hash, file_list)
    print '多进程运行状况: {}'.format((datetime.now() - time2).total_seconds())

    pool = ThreadPool(4)
    time3 = datetime.now()
    pool.map(create_hash, file_list)
    print '多线程运行状况: {}'.format((datetime.now() - time3).total_seconds())

{% endhighlight %}


有这样几个注意事项：

- 如果对所产生的文件列表进行 `shuflle` 操作让文件变得无序的话，所有消耗时间都会变长。说明线程在操作文件时是 `I/O Bound` 的行为。

- 第 22 行计算从 1-300 的阶乘，非常典型的消耗 CPU 行为。在这种情况下时间运行状况为：

    ```
    共有 403345 个文件
    普通执行状况: 16.230872
    多进程运行状况: 4.874608
    多线程运行状况: 21.812273

    ```
   可以看出多进程操作有明显的优势

- 如果注释掉第 22 行，运行状况为
    ```
    共有 403365 个文件
    普通执行状况: 0.182251
    多进程运行状况: 0.39652
    多线程运行状况: 0.234787
    ```
  可以看出多线程要比多进程的运行效果好，但仍然不如普通的执行情况。一个解释是切换目录造成的 I/O 阻塞是小于线程之间切换的 context switch 。在用 requests 写爬虫的时候检测到的 `multiprocessing.dummy` 运行效果要比单线程快的多。

- 为了安全，在 map() 后还可以再加上 `pool.close()  pool.join()`。`close()` 的作用是 `Prevents any more tasks from being submitted to the pool. Once all the tasks have been completed the worker processes will exit.`,`join` 的作用是 `Wait for the worker processes to exit`

##### Lock

Lock 的作用是对一些敏感的函数或者变量，确保只有一个进程/线程来运行。同时因为 Lock 是不可 pickable 的，所以不能作为 map() 的参数传进去。直接使用全局变量来解。

一个例子如下：

{% highlight Python %}
import multiprocessing.Lock

l = Lock()

def func1():
    # some key function
    l.acquire()
    # do-something
    l.release()

def func2():
    # or use next method
    with l:
        # do-something,it will release automatic

{% endhighlight %}

with lock 实现了 context manager，可以类比于 Java 的 `Synchronized` 关键字。在测试时候发现如果所有要执行的函数都被置于 lock 下，那么多进程的执行时间甚至比
顺序执行还要差。

##### 关于 apply_async

在 multiprocessing 的 pool 里除了 map/map_async 外还提供了 apply/apply_async。主要区别包括：

- map/map_async 可以接受一个包含大量参数的 list，并把这个 list 的每个元素发给要执行的函数。apply/apply_async 则只能接受类似于 tuple 的一个参数，如 `(1,)`

- map/apply 都是阻塞型的，也就是返回时间取决于执行最长的那个时间，在所有任务执行完后一起返回。而 map_async/apply_async 则是在开始执行任务时就返回一个 AsyncResult 对象，之后用 `.get()` 方法来得到结果。来做一个说明：

- map_async/apply_async 相比 map/apply 多了一个参数:callback。callback 是一个只接受一个参数的函数，用来对执行的结果进行 ` 写入文件/读入数据库` 等操作。

- 最喜欢使用的两个就是 map 和 apply_async，其中 map 的输出和输入的顺序一致，apply_async 输出和输入顺序无关。进行一个简单的比较如下：

{% highlight Python %}
import multiprocessing
from datetime import datetime
from functools import reduce

l = multiprocessing.Lock()

def cal(f):
    # with l:
    #     #print f
    #     for _ in range(f):
    #         temp = reduce(lambda x, y: x * y, range(1, 400))
    #     #temp = reduce(lambda x, y: x * y, range(1, f))
    #     return 2**f
    print ('{} 出现'.format(f))
    for _ in range(f):
            temp = reduce(lambda x, y: x * y, range(1, 40000))
        # temp = reduce(lambda x, y: x * y, range(1, f))
    return '计算出 {} 的乘积为 {}'.format(f,2**f)

if __name__=='__main__':

    pool = multiprocessing.Pool(4)
    date3 = datetime.now()
    for c in [pool.apply_async(cal,(x,)) for x in range(1,10)]:
        print (c.get())
    print ('总共花费时间为: {}'.format((datetime.now()-date3).total_seconds()))
    pool.close()
    pool.join()

    pool = multiprocessing.Pool(4)
    date1 = datetime.now()
    #for x in [pool.map_async(cal, range(1, 30))]:
    for x in pool.map(cal,range(1,10)):
        print (x)
    print ('总共花费时间为: {}'.format((datetime.now() - date1).total_seconds()))
    pool.close()
    pool.join()

{% endhighlight %}

对 pool.apply_async ，显示结果如下。可以很明显看出一旦结果执行完就返回。

```
1 出现
2 出现
3 出现
4 出现
计算出 1 的乘积为 2
5 出现
计算出 2 的乘积为 4
6 出现
计算出 3 的乘积为 8
7 出现
计算出 4 的乘积为 16
8 出现
计算出 5 的乘积为 32
9 出现
计算出 6 的乘积为 64
计算出 7 的乘积为 128
计算出 8 的乘积为 256
计算出 9 的乘积为 512
总共花费时间为：5.700147

```

对 pool.map，显示结果如下。可以看出它在等待所有的结果都运行完，存在明显的 block 。

```
1 出现
2 出现
3 出现
4 出现
5 出现
6 出现
7 出现
8 出现
9 出现
// 此处会出现明显的停顿
计算出 1 的乘积为 2
计算出 2 的乘积为 4
计算出 3 的乘积为 8
计算出 4 的乘积为 16
计算出 5 的乘积为 32
计算出 6 的乘积为 64
计算出 7 的乘积为 128
计算出 8 的乘积为 256
计算出 9 的乘积为 512
总共花费时间为: 5.706731

```

关于性能，在做的大量测试下所花费的时间都是类似的，在这种情况下性能不应该成为考量的瓶颈。apply_async 更适合于希望能立刻得到执行结果的场合：-D

#### 一个更加复杂的例子

上面的方法在大多数情况下已经足够开发用了。但如果我们想要对多进程/线程操作有更好的掌控，如共享状态(share state)，就需要了解的更深。
曾经在学习的时候写过一个用 `mp.Process` 来运行，并用 `mp.Queue` 来作为队列的例子，参见如下。有时间的话再加上注释吧：

{% highlight Python %}
#!/usr/bin/env python
# -*- coding:utf-8 -*-

import multiprocessing as mp
import Queue
import time
import re

import requests


def run(task_queue, result_queue, visited_set):
    name = mp.current_process().name
    while True:
        try:
            # return an item if one is immediately available
            new_task = task_queue.get(False)
            url=new_task
            '''
            if not next_task:
                print '{} exiting'.format(next_task)
                task_queue.task_done()
                break
            '''
        except Queue.Empty:
            #print 'error happened'

            # task_queue.task_done()
            break
        if visited_set.has_key(url):
            print '{}has been added'.format(url)
            task_queue.task_done()
            continue

        title = crawl(url)
        print '{}:{}'.format(name,title)
        visited_set[url] = 1
        task_queue.task_done()
        result_queue.put(title)
    return


def crawl(url):
    #time.sleep(5.0/1000)
    r=requests.get(url)
    title=re.findall(r'<title>(.*?).</title>',r.content)
    return title


if __name__ == '__main__':
    t1=time.time()

    tasks = mp.JoinableQueue()
    results = mp.Queue()
    manager = mp.Manager()
    # completeFlag 
    vset = manager.dict()

    num_consumers = mp.cpu_count() * 2
    print 'Creating {} consumers'.format(num_consumers)
    num_jobs = 10

    url_list=['http://www.qunar.com','http://www.douban.com',
    'http://www.github.com','http://www.ctrip.com','http://www.v2ex.com']

    for u in url_list:
        tasks.put(u, False)
    tasks.put(url_list[2], False)
    tasks.put(url_list[3], False)
    processes = [mp.Process(target=run, args=(tasks, results, vset))
                 for i in xrange(num_consumers)]

    for p in processes:
        p.start()

    # wait until all the items in taskqueue are processed
    tasks.join()

    for p in processes:
        p.join()


    while True:
        try:
            print results.get(False),
        except Queue.Empty:
            print '停止'
            break

    print 'cost {}'.format(time.time()-t1)

{% endhighlight %}


#### Python3 里的 Thread/Process PoolExecutor

Python3 里为进程和线程提供了进一步的抽象。使用方法有两种：

##### 使用 map

一个典型的函数如下：

{% highlight Python %}
with ProcessPoolExecutor(max_workers=4) as executor:
        executor.map(create_hash, file_list)
{% endhighlight %}

在对上面的代码稍作改动之后在 Python3 里运行，在最好的情况里结果如下：

```
普通执行状况: 12.71012
多进程运行状况: 5.799454
多线程运行状况: 18.085609
ThreadPoolExecutor 运行状况: 18.403806
ProcessPoolExecutor 运行状况: 5.764657
```
其他大部分的情况 ThreadPoolExecutor 和 ProcessPoolExecutor 都比 multiprocessing 的效果差。原因可以参考 [processpoolexecutor-from-concurrent-futures-way-slower-than-multiprocessing-pool](http://stackoverflow.com/questions/18671528/processpoolexecutor-from-concurrent-futures-way-slower-than-multiprocessing-pool)也就是说 PoolExecutor 里最好的适用情况是用 submit() 来监测即时更新的结果，而非套用 mp 。这就引到了第二种使用，使用 `submit()`:

##### 使用 submit

正如上面所说，对 PoolExecutor 用 map 的意义不大。下面就主要对 submit　进行讨论。
submit 这里很明显可以看到 Java 的影子。future 特性最好的是一旦完成就返回，而不必等到所有阻塞返回。和 apply_async 相比更抽象。
对官网的例子略作改进，一个使用如下：

{% highlight Python %}
from concurrent.futures import ThreadPoolExecutor,as_completed

import requests

URLS = ['http://www.foxnews.com/',
        'http://www.cnn.com/',
        'http://europe.wsj.com/',
        'http://www.bbc.co.uk/',
        'http://some-made-up-domain.com/']

def load_url(url):
    return requests.get(url).content().decode('utf-8')

if __name__ == '__main__':
    with ThreadPoolExecutor(max_workers=4) as executor:
        future_to_url = {executor.submit(load_url,url):url for url in URLS}
        for future in as_completed(future_to_url):
            url = future_to_url.get(future)
            try:
                data = future.result()
            except Exception as ex:
                print ('raise exception')
            else:
                print ('{url} content is {content}'.format(url=url,content=data))

{% endhighlight %}