---
title: One Line To Achieve MultiProcess and MultiThreads In Python
date: 2014-06-22 10:49:24
categories: Python
tags: [Python]
---
Using `multiprocessing` and `multiprocessing.dummy` to implement multi-process and multi-threading, adding ThreadPoolExecutor and other content.

<!-- more -->

[这篇文章对应的中文版](/../translation/2014-06-22-Python-Multiprocessing-Multithreading.html)


#### Just Add One-line

There is not much description about pros and cons between multiprocessing and Thread, because the key is that we want our code to be parallel:-D

Read this article [parallelism-in-one-line] (http://chriskiehl.com/article/parallelism-in-one-line/) to get a rough impression.

Providing an example written:

{% highlight Python %}
# -*- coding:utf-8 -*-

"""
calculate the md5 value for files under one directory
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
    print 'There are {} files'.format(len(file_list))
    time1 = datetime.now()
    for filename in file_list:
        create_hash(filename)
    print 'normal case: {}'.format((datetime.now() - time1).total_seconds())

    pool = ProcessPool(4)
    time2 = datetime.now()
    pool.map(create_hash, file_list)
    print 'multi-process case: {}'.format((datetime.now() - time2).total_seconds())

    pool = ThreadPool(4)
    time3 = datetime.now()
    pool.map(create_hash, file_list)
    print 'multi-thread: {}'.format((datetime.now() - time3).total_seconds())

{% endhighlight %}


There are something to mention：

- If the `shuflle` operation is performed on the generated file list to make the file unordered,then all the time will be longer. Explain that the thread is `I/O Bound` when it manipulates the file.

- Line 22 calculates the factorial from 1-300, which is very typical of CPU consumption. In this case the time health is:

    ```
    There are 403345 files
    normal case: 16.230872
    multi-process: 4.874608
    multi-thread: 21.812273

    ```
   There are obvious multi-process advantages on multi=progress. `4<16<21` it is not difficult to choose.

   If we comment the line 22,then situation will be:
    ```
    There are 403365 files
    normal case: 0.182251
    multi-process: 0.39652
    multi-thread: 0.234787

    ```
  

- For security, you can add `pool.close() pool.join()` after map() . The role of `close()` is `Prevents any more tasks from being submitted to the pool. Once all the tasks have been completed , the worker processes will exit.`, `join` is `Wait for the worker processes to exit`

##### Lock

The role of `Lock` is for some sensitive functions or variables, ensuring that only one process/thread is running. Also because Lock is not pickable, it cannot be passed as a parameter to map() . Use global variables directly to solve.

An example is as follows:

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

`With lock` implements the context manager, which can be compared to Java's `Synchronized` keyword. During the test, it was found that if all the functions to be executed were placed under lock, the execution time of multiple processes was even worse than the sequential execution.

##### About apply_async

In the multiprocessing pool, `apply/apply_async` is provided in addition to map/map_async. The main differences include:

- map/map_async can accept a list containing a large number of arguments and send each element of the list to the function to be executed. Apply/apply_async only accepts one parameter like tuple, such as `(1,)`

- map/apply is block-type, that is, the return time depends on the longest execution time and returns after all tasks have been executed. Map_async/apply_async returns an AsyncResult object when it starts executing the task, and then uses the `.get()` method to get the result.

- map_async/apply_async has one more parameter than map/apply: callback. Callback is a function that accepts only one parameter and is used to perform operations such as `write file/read into database` on the result of the execution.

- The two favorite ones are map and apply_async, where the output of map is the same as the order of the input, and the apply_async output is independent of the input order. 

Make a simple comparison as follows:

{% highlight Python %}
import multiprocessing
from datetime import datetime
from functools import reduce

l = multiprocessing.Lock()

def cal(f):
    # test lock 
    # with l:
    #     #print f
    #     for _ in range(f):
    #         temp = reduce(lambda x, y: x * y, range(1, 400))
    #     #temp = reduce(lambda x, y: x * y, range(1, f))
    #     return 2**f
    print ('{} occurs'.format(f))
    for _ in range(f):
            temp = reduce(lambda x, y: x * y, range(1, 40000))
        # temp = reduce(lambda x, y: x * y, range(1, f))
    return 'calculate {} result is {}'.format(f,2**f)

if __name__=='__main__':

    pool = multiprocessing.Pool(4)
    date3 = datetime.now()
    for c in [pool.apply_async(cal,(x,)) for x in range(1,10)]:
        print (c.get())
    print ('Total cost time is: {}'.format((datetime.now()-date3).total_seconds()))
    pool.close()
    pool.join()

    pool = multiprocessing.Pool(4)
    date1 = datetime.now()
    for x in pool.map(cal,range(1,10)):
        print (x)
    print ('Total cost time is: {}'.format((datetime.now() - date1).total_seconds()))
    pool.close()
    pool.join()

{% endhighlight %}

对 pool.apply_async ，显示结果如下。可以很明显看出一旦结果执行完就返回。

```
1 occurs
2 occurs
3 occurs
4 occurs
calculate 1 result is 2
5 occurs
calculate 2 result is 4
6 occurs
calculate 3 result is 8
7 occurs
calculate 4 result is 16
8 occurs
calculate 5 result is 32
9 occurs
calculate 6 result is 64
calculate 7 result is 128
calculate 8 result is 256
calculate 9 result is 512
Total cost time is：5.700147

```

对 pool.map，显示结果如下。可以看出它在等待所有的结果都运行完，存在明显的 block 。

```
1 occurs
2 occurs
3 occurs
4 occurs
5 occurs
6 occurs
7 occurs
8 occurs
9 occurs
// it will pause for a few seconds
calculate 1 result is 2
calculate 2 result is 4
calculate 3 result is 8
calculate 4 result is 16
calculate 5 result is 32
calculate 6 result is 64
calculate 7 result is 128
calculate 8 result is 256
calculate 9 result is 512
Total cost time is: 5.706731

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