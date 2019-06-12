
<!-- 这里主要说的是如何实现一个 follow 的表

followee 的定义参见：https://en.oxforddictionaries.com/definition/followee

具体思路分为两种：

1. 用关系型数据库 MySQL 设计来实现
2. 用 NoSQL 如 redis 设计来实现

有的人会担心 redis 的稳定性，因为通常 redis 的作用是缓存，分担查询压力，对于准确性要求并没有那么高。对于
这种，我们需要主要到关注行为和【钱的数额】这类数据不一样，前者是允许一定量的误差。
就算是用户点击了关注行为发现没有关注，过其中一个非常重要的特点是 -->