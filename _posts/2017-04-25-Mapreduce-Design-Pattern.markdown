---
layout: post
title: 关于 MapReduce 设计模式
date: 2017-04-25 17:03:40
categories: MapReduce
comments: true
---

#### 实现统计 UV

类似于 SQL 中的 count(distinct *)

我所实现的第一种：

map:emit(null,key)

reduce:TreeSet 存储元素，cleanup():写入，得到 length

优势：跑一次 MapReduce Job 即可得到最终结果
劣势：只能有一个 reduce
待优化：在 combiner 阶段可以写一个处理类来减少 shuffle 的数量

书中的第二种：
map:emit(key,null)
reduce:迭代任意一个 Iterrator 时只需要 O(1) 操作

优势：利用 MR 框架自带的去重特性，在处理大量数据时有优势
劣势：需要跑两次 MR 来得到最终的统计结果

---

#### 实现数据库 left/inner/right join

这里可以参考 Quora 的这个问题：https://www.quora.com/How-does-Hive-implement-joins-in-Map-Reduce

存在 Map-side 和 Reduce-side 两种情况来区分讨论

MultiInput 用 ArrayList 存储

劣势：在一个表中有上千万数据时可能会 OOM

---

#### 