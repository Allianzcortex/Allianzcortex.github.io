---
layout: post
title: ScalaTest 和 JUnit 集成，使用 Sbt 不执行测试的解决办法
date: 2017-05-21 16:29:10
categories: Scala
comments: true
---
ScalaTest 与 JUnit 集成后，执行 `sbt test` 提示 `no tests are executed` 的解决办法

<!-- more -->

最近在试着写一个用 Scala 解决 LeetCode 的 [集合](https://github.com/Allianzcortex/Scala-LeetCode)，Scala 里的单元测试一般推荐使用 ScalaTest，而大部分 Scala 使用者都有 Java 背景，所以 ScalaTest 也可以与 Junit 集成使用，参见 [链接](http://www.scalatest.org/getting_started_with_junit_4_in_scala)

#### 遇到了什么问题

首先定义如下的测试代码：

{% highlight Scala %}
import org.scalatest.{BeforeAndAfterEach, FunSpec, FunSuite}

class FileUtilTest extends FunSpec with BeforeAndAfterEach {
    it("should be equal") {
        assert(xx.max(1,2) == 2)
    }
}

{% endhighlight %}

然后定义如下的 **build.sbt** 文件：

{% highlight Scala %}
libraryDependencies += "org.scalatest" % "scalatest_2.12" % "3.0.1" % "test"
libraryDependencies += "junit" % "junit" % "4.8.1" % "test"

{% endhighlight %}

上面是 Scala-Test 最标准的代码

同时用 IDEA 和 `sbt test` 来跑测试用例都没有问题

那么如果想要引入 JUnit 的话则如下：
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

在这种情况下用 IDEA 可以跑测试用例，但用 `sbt test` 的话会提示 `no tests are executed`

参考：http://stackoverflow.com/questions/28174243/run-junit-tests-with-sbt 需要在原有 sbt 的基础上加上：

{% highlight Scala %}
crossPaths := false
libraryDependencies += "com.novocode" % "junit-interface" % "0.11" % Test
testOptions += Tests.Argument(TestFrameworks.JUnit, "-q", "-v")
{% endhighlight %}

出现这个问题的原因还是在于 Scala 和 Java 最后编译出来的是两套不同的字节码

---

看了一下，Spark 里面的测试用例都是用的纯 ScalaTest 框架，而没有用 JUnit ：-D