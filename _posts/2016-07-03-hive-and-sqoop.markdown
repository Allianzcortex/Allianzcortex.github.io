---
layout: post
title: 最近做的一些事——Hive+Sqoop 与 调度系统选型
date: 2016-07-03 19:46:30
categories: Hive
comments: true
---
用 `Hive` 与 `Sqoop` 实现 ETL，以及对 **Ozzie/Azkaban/Airflow/Zeus/Kettle** 的调研

<!-- more -->

#### What Happened

最近所做的一些事。还是挺有趣的。

ETL 过程，代指 **Extract->Transform->Load**，进行数据抽取处理的过程

HDFS 文件路径下面的数据来源一般有以下几种：

- 从已有的 RDBMS 数据库中导入，方便和业务进行分析

- 从已有的 HDFS 数据中进行连接和抽样，生成新的复合需求的数据

- 一些其他的路径，包括从 Flume 中用 HDFS Sink 写入，或者用 `hadoop fs -put` 来把本地的文件导入到 HDFS 中。

第一种工具包括 Apache 出品的 Sqoop 和阿里出品的 DataX(京东是根据 DataX 的原理自己搞了一套)。二者的对比可以查看这个 [链接](https://chu888chu888.gitbooks.io/hadoopstudy/content/Content/11/chapter11.html)。

第二种工具则在大多数情况下都是在用 Hive 来解决需求。Hive 是 FaceBook 出品的可以把 HQL(类 SQL 语法)转化为 MapReduce 执行的工具，方便数据分析师进行操作。

同时还调研了调度系统。从原理上来说只要写好执行脚本，直接用 crontab 设置好定时任务就好。但一方面随着业务量上升我们要管理多个脚本，另一方面还想要添加进度提醒、查看日志、失败重试、邮件预警、管理多个相互依赖任务等功能。在这种情况下调研了 **Ozzie/Azkaban/Airflow/Zeus/Kettle** 等项目。

#### 关于 sqoop

#### 关于 Hive

#### 调度系统

##### 关于 Airflow

要求团队里至少有一个人会 Python。严格来说这不算是什么多的要求，特别是在 ML/DL/AI 如火如荼的当下，上手 Python 可能也就是一两天的事情。但总归是多了一些成本。

附录 A 里补充了 Airflow 的安装和使用

##### 关于 Zeus

其实我司之前用的就是 Zeus：-D 但如果要重新开始选型的话，可以有更多的选择。

- 更新缓慢。最近一次和代码有关的提交是在 2013 年，源代码长时间没有进行更新，一个非常明显的 [Bug Fix PR](https://github.com/alibaba/zeus/pull/66) 有一个月没有合并到主分支里

- 部署和运维相对于其他调度工具偏难，参考它的 [安装文档](https://github.com/alibaba/zeus/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%AF%BC%E6%96%87%E6%A1%A3)



[zeus2](https://github.com/michael8335/zeus2) 但上一次更新是在 2014 年...

---

附录A


