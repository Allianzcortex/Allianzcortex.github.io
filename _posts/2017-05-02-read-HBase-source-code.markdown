---
layout: post
title: 阅读 HBase 源代码
date: 2017-05-01 13:29:10
categories: Hbase
comments: true
---

开始阅读 HBase 源代码

<!-- more -->

![HBase-source-code.png](/images/HBase-source-code.png)

HBase 的特点：

- 实现比 redis 持久化存储效果更好的 key-value 键值对

- 实现需要有历史版本的增量存储

阅读代码主要包括以下几个方面：

- 在实际编写程序时，通过有关 API 及 IDEA 跳转到源代码的功能，查看具体功能实现

- 在 debug 应用时，了解整个 Hbase 执行应用的业务逻辑

- 通读整个源代码，了解各块的实现

---

在这里首先看第一部分，执行一个小的应用，看它是怎么执行下来的

读取配置文件 reloadConfig()，重新记载配置文件

checkDefaultVersion():检查配置文件的版本和应用所读取的版本是否相等。可以用一个配置文件来跳过这项配置

set(String name,String value) // 这里用 Guava 的 Preconditions.checkArgument() 来判断配置是否为 null
同时还有 updateSource()

关于 HConnection connection = HConnectionManager.create

```
IDEA 为分析项目的整体结构提供了非常强大的功能
几个常用的如下：

光标选中某个类：在 Navigate->call  call Hierarchy 查看该
callers 查看该方法被哪个方法调用，callee 查看该方法调用了哪些方法

选中某个方法，类，查看该类被哪些类引用，生成用例图， ctrl+alt+H

```

方便开发
