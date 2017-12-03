---
title: 译—利用 MapReduce 来探寻好友关系
date: 2016-12-16 18:52:22
categories: Data
tags: [Data,MapReduce]
---
一篇译文，介绍 MapReduce 在实际中的应用
<!-- more -->

原文链接在 [finding-friends-with-mapreduce](http://stevekrenzel.com/finding-friends-with-mapreduce)，稍有改动。

MapReduce 程序通常包括两部分函数：一个 Map 函数与一个 Reduce 函数。Map 函数会接受一个输入值(value) 并返回一个键值对(key:value pairs)。比如说，如果我们定义了一个接受字符串作为输入并输出该字符长度作为输出的 Map 函数，那么 Map(steve) 将会返回 `5:steve` 并且 Map(savannah) 会返回 `8:savannah`。你也会注意到 Map 函数是无状态(stateless) 的并且只会要求输入值来确定输出值。这就使得我们可以并行运行多个 Map 函数从而取得巨大的性能优势。在进入到 Reduce 函数之前，MapReduce 框架会把所有的输出值(values)按照键(key)来进行分组。所以说如果 Map 函数输出的结果如下：

```
3 : the
3 : and
3 : you
4 : then
4 : what
4 : when
5 : steve
5 : where
8 : savannah
8 : research
```

那么他们会被排类为如下的形式：

```
3 : [the, and, you]
4 : [then, what, when]
5 : [steve, where]
8 : [savannah, research]

```

接下来每一行都会作为一个参数被传递进 reduce 函数中，reduce 函数接受一个 key 和一系列的 values。在这个例子中，我们想要探寻包含特定长度的单词的数量，所以 reduce 函数将会仅仅计算列表中的单词数量并且将它与 key 一起进行输出，产生如下的形式：

```
3 : 3
4 : 3
5 : 2
8 : 2

```

reduce 函数仍然可以并行工作。我们可以看到这里长度为 5 的单词只有 2 个，诸如此类...

上面所说的 wordcount 例子是 MapReduce 版的 Hello World，下面我们将要介绍一个真实世界中的使用（FaceBook 或许不是真的这样去做的，这里只是举一个例子）：

FackBook 上存在着朋友列表（注意，在 FaceBook 中好友关系是双向的，如果我是你的朋友，那么你也是我的朋友）。同时 FaceBook 拥有大量的磁盘存储空间与海量访问请求。FaceBook 决定提前计算这样他们就可以减少请求的访问时间。一个常见的处理操作是“你和 Joe 有 230 个共同好友”。当你访问某人的资料页时，你可以看到你们所共同拥有的好友。这个列表不会频繁改动所以如果每次访问页面都重新计算的话就太浪费了（当然你可以使用缓存来做，但这样的话我就不会讲述用 MapReduce 来解决这个问题了）。我们将要使用 MapReduce 在一天内 来计算并储存这些结果。

假设朋友是以 `Person->[List of Friends]` 的形式存储的，我们的朋友列表为：

```
A -> B C D
B -> A C D E
C -> A B D E
D -> A B C E
E -> B C D

```

mappper 会将每一行作为参数来处理。同样 mapper 函数会输出一个键值对，键（key）会是一对朋友（a friend along with the person），值（value）会是朋友列表（list of firends）。并且键（key）会是一对已经经过排序的值，这样在 reducer 函数里会形成相同的 pairs。这用语言很难解释，所以让我们直接去做吧。经过 mapper 函数，你会得到如下的输出结果：

```
For map(A -> B C D) :

(A B) -> B C D
(A C) -> B C D
(A D) -> B C D
For map(B -> A C D E) : (Note that A comes before B in the key)

(A B) -> A C D E
(B C) -> A C D E
(B D) -> A C D E
(B E) -> A C D E
For map(C -> A B D E) :

(A C) -> A B D E
(B C) -> A B D E
(C D) -> A B D E
(C E) -> A B D E
For map(D -> A B C E) :

(A D) -> A B C E
(B D) -> A B C E
(C D) -> A B C E
(D E) -> A B C E
And finally for map(E -> B C D):

(B E) -> B C D
(C E) -> B C D
(D E) -> B C D
```

在把它们送往 reduce 函数前，我们根据 key 来把它们进行分类并且得到

```
(A B) -> (A C D E) (B C D)
(A C) -> (A B D E) (B C D)
(A D) -> (A B C E) (B C D)
(B C) -> (A B D E) (A C D E)
(B D) -> (A B C E) (A C D E)
(B E) -> (A C D E) (B C D)
(C D) -> (A B C E) (A B D E)
(C E) -> (A B D E) (B C D)
(D E) -> (A B C E) (B C D)
```

reduce 函数将会取每一个键对应的值的交集并输出。比如 reduce((A B) -> (A C D E)(B C D)) 将会输出 (A B):(C  D) ，这意味着 A 和 B 有共同好友 C 和 D 。

最终的结果为：

```
(A B) -> (C D)
(A C) -> (B D)
(A D) -> (B C)
(B C) -> (A D E)
(B D) -> (A C E)
(B E) -> (C D)
(C D) -> (A B E)
(C E) -> (B D)
(D E) -> (B C)

```

这样当 D 访问 B 的资料页时，我们可以快速查询 (B D) 并且看到他们的共同好友 (A C E)。
