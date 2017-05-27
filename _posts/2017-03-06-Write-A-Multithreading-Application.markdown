---
layout: post
title: 一个 Java 多线程程序实例——JStorm 处理逻辑
date: 2017-03-06 14:23:38
categories: [multi-threading,Java]
tags: Java
---
在实时流 JStorm 中处理一个多线程的程序
<!-- more -->




---

Update：最近又遇到了这个问题。具体的原因就是最近在处理的程序用了一个自建的 redis pool。
它在 getInstance() 方法这里用了 synchronized 关键字来加锁。

但我们看一下 redis 是怎么实现这一点的。它继承了 Apache.commons.pool ，里面调用了
`super.getResource()` 方法，而它又调用了 pool 里面的 `borrowObject` 方法。
在 `borrowObject` 方法里，它已经实现了对多线程的考虑：

long starttime = System.currentTimeMillis();
1060        Latch<T> latch = new Latch<T>();
1061        byte whenExhaustedAction;
1062        long maxWait;
1063        synchronized (this) {
1064            // Get local copy of current config. Can't sync when used later as
1065            // it can result in a deadlock. Has the added advantage that config
1066            // is consistent for entire method execution
1067            whenExhaustedAction = _whenExhaustedAction;
1068            maxWait = _maxWait;
1069
// activate & validate the object
1203            try {
1204                _factory.activateObject(latch.getPair().value);
1205                if(_testOnBorrow &&
1206                        !_factory.validateObject(latch.getPair().value)) {
1207                    throw new Exception("ValidateObject failed");
1208                }
1209                synchronized(this) {
1210                    _numInternalProcessing--;
1211                    _numActive++;
1212                }
1213                return latch.getPair().value;
1214            }
1215            catch (Throwable e) {
                ......
}