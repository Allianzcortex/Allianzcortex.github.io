---
layout: post
title: Scala99 的一些题解与一个 Scala 类
date: 2017-05-21 13:29:10
categories: Scala
comments: true
---
Scala 99 的一些题解记录，以及一个 Scala 类的实例

<!-- more -->

Scala 的语法的复杂度堪比 C++ ......

《Scala CookBook》的作者评价 Java 这门语法的特性是 `Verbose yet obvious`，这是见过的最好对 Java 这门语言的描述了。正是因为 obvious 的特性，才能在工业级开发领域中遥遥领先，Web 开发/Android/数据领域都占据主要地位。也正是因为 verbose 的特性，让写 Java 写多的人很容易产生啰嗦的感觉，相比于 Python 的话对比感就更强烈了。

> 现在来看 Kotlin 的定位更像是 Better Java，字节码被翻译成 Java 类型，无缝调用 Java 的所有库，语法更简洁。

Scala 则是对 Java 很好的一个改进，同样基于 JVM 平台。Scala 的官网上宣传 OO meets FP，它同时融合了面向对象和函数式编程的优点。就像很多人说的，没有必要把 Scala 的语法完全了解以后再去用它。要用 Spark，要看 Kafka，直接看就好了：-D

Scala 学习的时候主要分为两方面吧：


- Array/List/Seq 等一系列 Immutable 与 Mutable 对象，对应的 take/filter/map/flatMap/reduce/head/tail/init 等可以提高开发效率的方法

- class/case class/object/trait 等新的 OO 相关内容

最近做了 Scala99 里面的一些题目，试着做一些摘抄，里面有些题目提出了和原来的一些不一样的方法


- 第 17 题：

** 要求 ** 把一个 List 分为两个部分

- 网站上提供了 ls.splitAt(n) 和直接返回 (ls.take(n),ls.drop(n)) 两种方法

- 自己的实现：

{% highlight Scala %}

def splitToTwoPart[A](n: Int, ls: List[A]) = {
    val s = ls.zipWithIndex.partition(elem => elem._2 + 1 <= n)
    (s._1.map(x => x._1), s._2.map(x => x._1))
}

{% endhighlight %}

关于类的部分：算是实现了一个小的 demo 吧

{% highlight Scala %}
import collection.mutable.ArrayBuffer

case class Record(var event: String, var money: Int) {
  def this() = this("sample", 1)
}


trait People {
  var name: String
  var age: Int
  var activity: ArrayBuffer[Record]

  def addRecord(newEvent: String, newMoney: Int)

  def removeRecord(deleteName: String, deleteMoney: Int) // 这也行，也就是说

  def getAllCost
}

class User(userName: String, userAge: Int) extends People {
  var name = userName
  var age = userAge
  var activity = new ArrayBuffer[Record]

  def addRecord(newEvent: String, newMoney: Int) = {
    this.activity += Record(newEvent, newMoney)
  }

  /*def addRecord={

  }*/

  def removeRecord(deleteName: String, deleteMoney: Int) = {
    val targetRecord = Record(deleteName, deleteMoney)
    /*if this.activity.exists(_ == targetRecord) this.activity -= targetRecord*/
  }

  def getAllCost() = {
    this.activity.foreach(x=>println(x.money))
    println("money " + this.activity.map(_.money).reduceLeft(_+_))
    this.activity.map(_.money).reduceLeft(_+_)
    //所以自己一开始的 reduce((x,y)=>x.money+y.money)) 思路是错的，你看，前两个得到的结果是 Record,但之后得到的是 Int
    // 再之后就会在 Record 和 Int 之间产生冲突
  }

  def getActivity(): List[Record] = {
    // 返回的 Array 必须是有类型的，而不能是 Array
    // List 也是一样的道理。并且 List 的可读性更好
    this.activity.toList
  }

  override def toString = s"$name $age"

}

object testApplication extends App {
  val u = new User("Tom", 18)
  u.addRecord("Buy Clothes", 10)
  println(u)
  println("用户的活动为 " + u.getActivity())
  println(u.activity.toList)
  println(u.getActivity())
  println(u.getAllCost())
}
{% endhighlight %}

---

在附录部分再总结一下 Scala 方法的集合：

