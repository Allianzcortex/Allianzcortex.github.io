---
layout: post
title: Run ScalaTest And JUnit On TravisCI And Some Scala99 Solutions
date: 2017-05-21 16:29:10
categories: Scala
comments: true
---

After integrating `ScalaTest` with `JUnit`, execute `sbt test` prompt `no tests are executed`.How to solve it ?

<!-- more -->
[这篇文章对应的中文版](/../translation/2017-05-21-Scala-Test-Junit-Sbt-Problem.html)

### BackGround

I’ve recently tried to write a                            [collection](https://github.com/Allianzcortex/Scala-LeetCode) that solves LeetCode with Scala. ScalaTest is generally recommended for unit testing in Scala, and most Scala users have a Java background , so ScalaTest can also be integrated with JUnit, see 
[link](http://www.scalatest.org/getting_started_with_junit_4_in_scala) for a further understanding

### What Is The Problem?

At first writing test code like this ：

{% highlight Scala %}
import org.scalatest.{BeforeAndAfterEach, FunSpec, FunSuite}

class FileUtilTest extends FunSpec with BeforeAndAfterEach {
    it("should be equal") {
        assert(xx.max(1,2) == 2)
    }
}

{% endhighlight %}

 **build.sbt** is as follows：

{% highlight Scala %}
libraryDependencies += "org.scalatest" % "scalatest_2.12" % "3.0.1" % "test"
libraryDependencies += "junit" % "junit" % "4.8.1" % "test"

{% endhighlight %}

Above is the most standard code for `Scala-Test`

There is no problem in running test cases with [Intellij IDEA](https://www.jetbrains.com/idea/) and `sbt test` at the same time.

If you want to import Junit,then it will be：

{% highlight Scala %}
import org.junit.Assert._
import org.scalatest.junit.{AssertionsForJUnit}
import com.leetcode.util.{FileUtil => xx}
import org.junit.Test

class FileUtilTest extends  AssertionsForJUnit {
    @Test def test_max()={
     assertTrue(xx.max(1,2)==2)
   }

}
{% endhighlight %}

Currently we can use Intellij IDEA to run unit tests, but if you use `sbt test` to run it in console, it will hint `no tests are executed`. If you want to have a continuous development,then manybe you know some famous tools such as [TravisCI](https://travis-ci.org/) which cooperates well with github.I write a `.travis.yml` [file](https://github.com/Infra-Intern/Scala-LeetCode/blob/master/.travis.yml).Now ScalaTest and JUnit can't work on Linux Platform.

### Solutions

Based on this question [run-junit-tests-with-sbt](http://stackoverflow.com/questions/28174243/run-junit-tests-with-sbt) you need to add the following code on original `build.sbt`：

{% highlight Scala %}
crossPaths := false
libraryDependencies += "com.novocode" % "junit-interface" % "0.11" % Test
testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v")
{% endhighlight %}

The reason for this problem is that Scala and Java finally compiled two different sets of bytecodes. Although in most cases it is compatible,but you also need to mind the corner case.

BTW,Looked at it, the test cases in Spark are all using the pure ScalaTest framework, without using JUnit.

---

Exercises for 《Scala For Impatient》 and some notes for Scala 99

Scala's syntax is as complex as C++...

The author of [《Scala CookBook》](http://scalacookbook.com/) evaluates the nature of Java's syntax as `Verbose yet obvious`. It is because of the obvious characteristics that it can lead in the industrial development,play a dominant role in `Web development/Android/big data field`. It is also because of the verbose characteristics and boilerplate code that people can feel really tired when writing in Java,especailly compared with Python.

Scala based on the JVM platform is a nice improvement of Java. Scala's official website promotes **OO meets FP**, which combines the benefits of object-oriented and functional programming. As many people have said, there is no need to fully understand Scala's grammar and use it later.

Scala is mainly divided into two aspects when learning:

- A series of Immutable and Mutable objects such as **Array/List/Seq** , corresponding to **take/filter/map/flatMap/reduce/head/tail/init** method, etc.

- new OO related content such as **class/case** **class/object/trait**
 
 Reaching `A3/L2` level will meet the daily needs.

Recently I have done some of the problems in [Scala99](http://aperiodic.net/phil/scala/s-99/), trying to do some excerpts, some of which have different methods from the original ones.

- Question 17:

** Requirements**: Divide a List into two parts

- `ls.splitAt(n)` and `directly return (ls.take(n), ls.drop(n))` methods are available on the website

- My own implementation:

{% highlight Scala %}

def splitToTwoPart[A](n: Int, ls: List[A]) = {
    val s = ls.zipWithIndex.partition(elem => elem._2 + 1 <= n)
    (s._1.map(x => x._1), s._2.map(x => x._1))
}

{% endhighlight %}


And I implement a small demo about **class** and **traits**:

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

  def removeRecord(deleteName: String, deleteMoney: Int)

  def getAllCost
}

class User(userName: String, userAge: Int) extends People {
  var name = userName
  var age = userAge
  var activity = new ArrayBuffer[Record]

  def addRecord(newEvent: String, newMoney: Int) = {
    this.activity += Record(newEvent, newMoney)
  }

  def removeRecord(deleteName: String, deleteMoney: Int) = {
    val targetRecord = Record(deleteName, deleteMoney)
    /*if this.activity.exists(_ == targetRecord) this.activity -= targetRecord*/
  }

  def getAllCost() = {
    this.activity.foreach(x=>println(x.money))
    println("money " + this.activity.map(_.money).reduceLeft(_+_))
    this.activity.map(_.money).reduceLeft(_+_)
    // reduce((x,y)=>x.money+y.money)) is wrong,there will be confilicts between Record and Int
  }

  def getActivity(): List[Record] = {
    this.activity.toList
  }

  override def toString = s"$name $age"

}

object testApplication extends App {
  val u = new User("Tom", 18)
  u.addRecord("Buy Clothes", 10)
  println(u)
  println("User activity is  " + u.getActivity())
  println(u.activity.toList)
  println(u.getActivity())
  println(u.getAllCost())
}
{% endhighlight %}
