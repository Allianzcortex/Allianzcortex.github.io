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

Line 22 calculates the factorial from 1-300, which is very typical of CPU consumption. In this case the time health is:

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

Result of `pool.apply_async`. Each task returns result the moment it is finished.

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
Result of `pool.map`. It is waiting for all results to be finished.

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

Regarding performance, the time spent remain contant while doing a lot of testing So performance should not be a bottleneck. `Apply_async` is more suitable for occasions where you want immediate results.

#### A Complicated Example

The above method is sufficient for development in most cases. But if we want to have better control over multi-process/thread operations such as sharing state among different threads. we need to understand more.

I used to write an example of running with `mp.Process` and using `mp.Queue` as a queue, as shown below. 

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
            print 'stop'
            break

    print 'cost {}'.format(time.time()-t1)

{% endhighlight %}


####  Thread/Process And PoolExecutor In Python3

Python3 provides a high-level abstraction。There are two ways to use:

### Using Map

A standard example is：

{% highlight Python %}
with ProcessPoolExecutor(max_workers=4) as executor:
        executor.map(create_hash, file_list)
{% endhighlight %}

put it in the above example.The result is:

```
normal case: 12.71012
multi-process case: 5.799454
multi-thread: 18.085609
ThreadPoolExecutor case: 18.403806
ProcessPoolExecutor case: 5.764657
```

In most cases,`ThreadPoolExecutor` and `ProcessPoolExecutor`, are less effective than `multiprocessing`. The reason can be referred to [processpoolexecutor-from-concurrent-futures-way-slower-than-multiprocessing-pool](http://stackoverflow.com/questions/18671528/processpoolexecutor-from-concurrent-futures-way-slower-than-multiprocessing -pool) That is to say, the best application in PoolExecutor is to use submit() to monitor the results of instant updates instead of applying mp.

##### Using submit

As mentioned above, the use of map for PoolExecutor is of little significance. The main discussion of submit is as follows.

It is obvious that you can see the shadow of Java. The best feature of the future feature is to return once it's done, without having to wait for all blocking to return. It is more abstract than apply_async.

The example of the official website is slightly improved. It can be used as follows:

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