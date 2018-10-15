---
layout: post
title: 碎碎念...
date: 2014-11-21 19:40:01
categories: techniques
comments: true
---

Actually I'm trying to express some light knowledge about coding and interesting experience in my daily life.And this post will be divided into 2 parts: the 1st part will be written in english,and the corresponding Chinese translation can be found in [chinese](/Chinese_translation.html)

一些碎碎念...
![HBase-source-code.png](/images/HBase-source-code.png)
<!-- more -->

- 之前代码是这样的：
```
 private static byte[] decrypt(byte[] data, byte[] key) throws Exception {
        SecureRandom sr = new SecureRandom();
        DESKeySpec dks = new DESKeySpec(key);
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
        SecretKey securekey = keyFactory.generateSecret(dks);
        Cipher cipher = Cipher.getInstance("DES");
        cipher.init(2, securekey, sr);
        return cipher.doFinal(data);
    }
```

各种 debug，看 DES 解法对应的 mode，最后还是要感谢 https://www.tools4noobs.com/online_tools/decrypt/ ，其实两行就用 Python 写好了：

```
def decrypt_des(input_):
    """
    :param input_: 加密的密文
    :return: 经过 des 解密后的密文
    """
    des = DES.new("naidnefi", DES.MODE_ECB)
    return "".join(x for x in des.decrypt(b64decode(input_)) if 31 < ord(x) < 127)
```
最后解密出来一堆 '\x5'，可以看 http://donsnotes.com/tech/charsets/ascii.html 来得到具体的含义，解决方法参考：https://stackoverflow.com/questions/14256593/remove-special-characters-from-the-string

- 今天帮我司算法团队调一个 Bug，调的心好累......本来用 Python2 处理中文就很闹心，还要用正则来调。调试了一大堆 unicode 字符以后终于能跑了......结果在测试服务器能跑，在对方的线上服务器就不能跑，擦......最后搜到了这个 ！[链接](https://stackoverflow.com/questions/1446347/how-to-find-out-if-python-is-compiled-with-ucs-2-or-ucs-4)，一试，果然......测试的是用 ucs4 编译的，而线上的是用 ucs2 编译的。两个有什么区别......我不知道啊......现在到家都已经 12 点了，我要睡觉......明天再说

- 自从 Google Reader 解散之后就没有怎么再用过 RSS 了，但最近发现还是很有用啊，类似 Push 和 Pull。这个 [链接](http://wokuang-blog.logdown.com/posts/208334-use-gmail-to-read-rss-data) 里说直接用 IFTTT 连接 Feedly 和 Gmail 就可以，但连接时候发现 IFTTT 必须要付费升级到 Pro 版才行。所以参考 [简书的这篇文章](http://www.jianshu.com/p/26b5c66e8546)，连接 RSS 和 Gmail。不过 IFTTT 改版后界面需要在右上角的个人主页那里点击 `New Applet`。有些 rss 的地址不一定好找，那就用 feedly 订阅后再导出 opml 文件，找到里面的 xmlUrl 属性对应内容。最后的截图如下：

![rss.png](/images/rss.png)

- 帮搜了一个 foursquare 的数据集。开始的链接地址是在 http://www.public.asu.edu/~hgao16/dataset.html，但链接失效了，用 Google 搜的话在犄角旮旯里找到个 reddit 的帖子 https://www.reddit.com/r/datasets/comments/1nywu2/foursquare_data_set/，里面到在 https://archive.org/download/201309_foursquare_dataset_umn 提供了下载zip 格式的文件，150M+。

- Java 上 StringUtils 里最常见的一个就是把首字母变成小写，一般来实现的话就是

{% highlight Java %}
public static String firstCharToLower(String input){
    if(input == nulll)
    
}

{% endhighlight %}

但 SO 上还有这么一个回答，提供了另一种思路： 

{% highlight Java %}
char c[] = string.toCharArray();
c[0] = Character.toLowerCase(c[0]);
string = new String(c);
{% endhighlight %}

其实是以牺牲可读性来换取了性能的增加

- Curator 是 Linkedin 开源的一款对 zookeeper 封装的工具，里面提供了各种方便实现的功能，包括更新配置文件，选取 leader 节点等。今天在 Spark 上看见了这个实现，具体对应代码在：`spark/core/src/main/scala/org/apache/spark/deploy/master/ZooKeeperPersistenceEngine.scala`

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





- 最近又有需求，在 Ubuntu 环境下用 VirtualBox 重新安装了 Win8.1。具体

- 今天试着用了一下 GitLab CI，从个人体验来说和 Github 的 travis-CI 没有什么太大区别啦，按照 stages 和 build/deploy 来区分，但最后问题发生在下面：
![build-failure.png](/images/build-failure.png)

根据它的说法，你需要在安装 GitLab 的服务器上安装 Runner,参见 [这个](https://docs.gitlab.com/runner/install/linux-repository.html)。但之前安装 GitLab 的人都不在了，既没有运维的权限，同时也没有像创业公司那样必须用 CI 的迫切性(不存在一天上线七八次这种情况啊......)。所以真的是......

最后把写的 .gitlab-ci.yml 脚本立此存照一下：

```
before_script:
    - sudo yum install maven2

stages:
    - build

build_job:
    stage: build
    script:
      - mvn install
      - mvn '-Dtest=com.xxx.example.*Test' test
```

其中 `mvn '-Dtest=com.xxx.example.*Test' test` 用来运行所有匹配的测试用例

- 今天在讨论的时候知道阿里和百度都开始用 DL 来做 CRT 预估了，记得一段时间以前都在说深度学习都还是黑匣子，可解释性遭到 challenge 的话是不能在生产环境上用的，但转眼间都开始用了

- 大部分讨论操作系统的问题最后都变成了要不要用 SSD 的问题......哇咔咔

- 因为最近要从事的是现场办公，某司要访问开发环境的话，不能用 openvpn 或类似的工具，而是用启明星辰所提供的[天玥安全审计](http://www.venustech.com.cn/SafeProductInfo/11/25.Html)。哼哧哼哧配好了 ip 和 dns 后(其中还踩了 Ubuntu Desktop 版不能直接用编辑配置文件方式修改 ip 的坑)，登陆到 Web 端来访问。但发现登陆工具怎么都选择不了，看了 css 以后发现选择器没问题啊......花了一天的时间各种配，最后申了一份当时发给运维的文档看，FAQ 里第一个就是：

>问题1：如果我的操作系统是Linux或者是Mac的怎么办？
Linux和Mac系统的用户可以使用web界面操作，web地址为 ××××××，操作方法和windows客户端版是一样的，web存在兼容性问题，建议使用客户端版。

  我......

- 发现 IDEA 配置好以后不能用设 Socks5 的方式来翻墙下载 SBT 的依赖，但 manual configuration 应该是没问题的啊。最后在 SBT 的参数里加上 ` -Dhttps.proxyHost=127.0.0.1  -Dhttps.proxyPort=8080`，:-(，但为什么不能用 IDEA 自带的配置呢？.......

- 在调试 Spark 源码里面的 Spark Streaming 程序的时候，需要把对应的 **VM Options** 改为 `-Dspark.master=local[2]`，否则
就一直报 **netword connection refused** 的错误......

- 分布式系统里一个最重要的特性就是 **CAP** 不能同时满足。Google 搜出来的第一个链接就是 [Quora 的回答](https://www.quora.com/Can-someone-provide-an-intuitive-proof-explanation-of-CAP-theorem)，里面提到了一篇非常好的 [InfoQ 文章](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed)，我来试着理解一下。**C** 指的是 Consistency(一致性)，**A** 指的是 Availability(可用性)，**P** 指的是 Partition Tolerance(分区容忍性)。通常情况下我们必须要保证多节点运行，所以 **P** 是肯定要满足的。而对 **C** 和 **A**，就只能取舍一个，举例：

```
一个集群有两台机器，A 和 B(这里为了举例进行了简化，在生产环境中要求通常为大于 1 的奇数)。
每当 A/B 有数据写入，都会同时在 B/A 上同步过去。
但突然网络连接出现了故障，A 和 B 之间无法进行通信。这时候对 A 而言，有两种选择：

1. 为了保持一致性，就不应当再接受对外的请求来确保数据不发生变化，这时候可用性就无法得到满足。

2. 为了保持可用性，继续接受请求，那么两台机器上的数据就会不一致，这时候一致性就无法得到满足。

这时候大多数的选择都是保持对外的可用性，两台机器继续对外提供服务，当可以继续进行通信时再同步数据，
从而保持最终一致性(eventual consistency)。

```

![CAP.jpg](/images/CAP.jpg)

在衡量系统的 Availability 的时候有几个概念，一个就是 **X 个9**。说明如下：

```
3个9：(1-99.9%)*365*24=8.76小时：
表示该软件系统在连续运行1年时间里最多可能的业务中断时间是8.76小时。
4个9：(1-99.99%)*365*24=0.876小时=52.6分钟：
表示该软件系统在连续运行1年时间里最多可能的业务中断时间是52.6分钟。
5个9：(1-99.999%)*365*24*60=5.26分钟：
表示该软件系统在连续运行1年时间里最多可能的业务中断时间是5.26分钟。

```

- 最近在写一个 MR 的程序，解析出一堆变量要产生一个字符串。虽然知道 `Guava` 库里有 `join` 方法，并且用 `hasNext()` 来避免结尾加上分隔符的实现高到不知道哪里去了，但就为了这么一个函数引入一个 jar 包是不是不太好啊⊙﹏⊙b。试着自己写一个，实现的稍微 tricky：

{% highlight Java %}
public static String join(Character separator, String... input) {
        if (input == null || input.length < 1)
            throw new IllegalArgumentException("the input is illegal,check wheteris it's null or empty");
        String _separator = String.valueOf(separator);
        StringBuilder res = new StringBuilder();
        for (String elem : input)
            res.append(elem).append(_separator);
        res.deleteCharAt(res.length() - 1);
        return res.toString();
    }
{% endhighlight %}

- 日常日常超量的话要进行处理，如果是我的话估计就写个脚本了，但今天才被教做人...Linux 下的 **/etc/logrotate.conf** 直接进行编辑就好了，压缩，移除，时间设置，各种功能都有......

- 最近在看 JStorm 的源码,其中有一段代码是这样的......kill the process 5 times......make sure the process be killed definitely......作者是个有故事的人......

{% highlight Java %}
public static void ensure_process_killed(Integer pid) {
        // in this function, just kill the process 5 times
        // make sure the process be killed definitely
        for (int i = 0; i < 5; i++) {
            try {
                exec_command("kill -9 " + pid);
                LOG.info("kill -9 process " + pid);
                sleepMs(100);
            } catch (ExecuteException e) {
                LOG.info("Error when trying to kill " + pid + ". Process has been killed");
            } catch (Exception e) {
                LOG.info("Error when trying to kill " + pid + ".Exception ", e);
            }
        }
    }
{% endhighlight %}

- `concurrency(并发)` 和 `parallelism(并行)` 两个概念常常混淆。今天又遇到了这个问题，结果发现为知里 2014 年就有这个记录了......好尴......那么用一句话来总结，就是说并发是针对程序的设计来讲的(concurrency as a property of a program or system)，一个设计良好的并发程序使得程序可以做到在重叠的时间段内执行不同任务。而并行指的是在实际运行中在物理上有多个任务在运行(parallelism as the run-time behaviour of executing multiple tasks at the same time)。所以如果一个并发的程序在一个单 cpu 的机器上运行，那么它仍然是并发的，但却不是并行。

这个问题解释最好的中文文章在 [这里](https://laike9m.com/blog/huan-zai-yi-huo-bing-fa-he-bing-xing,61/)，英文资料就是 Go 语言的那篇 [slide](https://talks.golang.org/2012/concurrency.slide) 了

- 除了 MongoDB 外 ES 也有被人黑啊......为了开发方便就不取消 `curl delete` 了，但必须只有内网能访问......到底是怎么做到每笔交易都是可回溯验证但无法关联到具体账户的......根据这个 [blockchain 地址](https://blockchain.info/address/13zaxGVjj9MNc2jyvDRhLyYpkCh323MsMq) 看一下，收了 32 笔 0.2 BTC，总共 6.4 BTC，根据 2017.01.18-11:36 上午的汇率，等价 5696.64 $，也等价 39202.73 ¥......

- 有一个 600M+ 的 CSV 文件，因为要实验转化读取，所以就用 split 来按大小分割一下。但之后怎么处理都是乱码，以为是源文件的问题，但 `head -10` 读出来也没问题啊。也怀疑是自己没有加后缀，但文本文件又不是二进制啊......最后才意识到不应该按大小来分割的......按大小来分割是为了方便后续合并啊......要用 `split -l` 按行来分......

![无话可说](/images/青蛙.jpg)

- 所以到底发生了什么......为什么要用图片处理......今天遇到不少事情......比如说要用 `pillow` 来把一个字体显示到图像上。需要用到 ImageFont 的 TrueType ，下载 `simsun.ttc`，包含宋体和新宋体，但使用的时候会报 `OSError`的错误，无法识别 fileformat ，需要换成 Linux 下对应的字体。但如果用 `/usr/share/fonts/` 目录下的随便一个，又不会正常显示，只会出现 "?"。需要选择一个对中文支持友好的字体，可以在命令行里用 `fc-list :lang=zh-cn` 来找。用 `numpy.asarray() 和 numpy.fromarray()` 来做到在图像和矩阵之间相互转化，中间添加随机数干扰会让字体扭曲变形，但这个更适配于对手写体的识别。如果是对拍照的印刷体，合适的场景是用 rotate() 来旋转一定角度。但这样会出现一些黑色空间，用 crop()再截取一下就好了：-D

- 虽然一直在用 requests，但今天才意识到可以这样: [requests-code-read-content-auto-encode](http://sh3ll.me/2014/06/18/python-requests-encoding/)。关于 `chardet` 识别编码的原理之前在看《Fluent Python》的时候也提到过，根据字符前缀出现的频率来判定。

```
In [7]: chardet.detect('再也不被编码问题困扰了2333ShakaLaka!!!'.encode('GBK'))
Out[7]: {'confidence': 0.99, 'encoding': 'GB2312'}
```
- supervisor 项目配置下有一个 user 选项，可以选择以什么用户来启动命令。但是必须用 root 账号来启动 supervisor

- 今天遇到了一个挺崩溃的问题。简单来说就是这样：数据校验的脚本有这样一句sql 查询:`count_sql = "select count(*) from...` 但 `print count_sql` 的时候总是会把第一个 's' 字符和最后的一个单引号 `'` 丢掉。查来查去最后甚至怀疑到了 `XShell` 的显示问题，但在我电脑上显示也不对，那就还是代码的问题。最后不用 print 来 debug 了，决定把 count_sql 写入到文件里来看(一直在用 Linux，读写模式里没有加 'b'...)，然后发现显示的语句后面多了一个 `^M`。问题就出在这里，以前创建这个文件的时候用的是 txt 文本编辑器而不是 notepad++，换行符用的是 '\r\n'，而 Linux 下用的是 '\n'。换句话来说就是 `Unix uses 0xA for a newline character. Windows uses a combination of two characters: 0xD 0xA. 0xD is the carriage return character. ^M happens to be the way vim displays 0xD.`(参考 [这个](http://stackoverflow.com/questions/5843495/what-does-m-character-mean-in-vim))。在 Py2 的范畴内解决办法就是读取后再用 strip() 处理一次。当然换到 Py3 就没有这个问题了(虽然离 2020 还有 3 年，但还是赶紧换啊啊啊)。这种问题还是第一次遇见，记录一下：-D

- 装 Kafka 的 UI，最后选型用的是 Yahoo 的 Kafka Manager。但它要用的是 JDK8 ...能检测单位时间内的信息量。最后界面还好啦，就是浓厚的 Bootstrap 风格让人不忍直视：

![KafkaUI](/images/KafkaUI.png)

同时补充一下 Centos 下安装 JDK8 的使用方法:

```
① 在现有的环境下 java -version 显示 1.7.0,目录在 /usr/lib 下。参考 Ubuntu 上的安装经验，我们不希望它发生冲突，所以在 /opt 目录下安装。
② cd /opt,之后使用 
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz"
来安装,之后使用 tar -xzf jdk-8u101-linux-i586.tar.gz 来解压。
③ cd /opt/jdk1.8.0_101/ 来进入安装环境。java 提供了 alternatives 选项来允许在同一系统内存在多个 java 版本。执行 
alternatives --install /usr/bin/java java /opt/jdk1.8.0_101/bin/java 2 
来安装。执行 
alternatives --config java
来选择，只需要输入对应的编号即可（在 158 环境需要输入的是 3，对应的正是 /opt 对应的 JDK8）。执行 java -version 可以看到已经变为 1.8。
④ 接下来需要设置环境变量，直接执行下面三个命令：
export JAVA_HOME=/opt/jdk1.8.0_101
export JRE_HOME=/opt/jdk1.8.0_101/jre
export PATH=$PATH:/opt/jdk1.8.0_101/bin:/opt/jdk1.8.0_101/jre/bin

```

- 准备去看 `《Web Analytics 2.0》 `了，虽然与技术关联不大，但没事的时候翻一番～～

- 对于定时清空的日志文件，用命令 `> ToDelete.log`...

- NLPchina 提供了一个 [elasticsearch-sql](https://github.com/NLPchina/elasticsearch-sql) 的插件，能用类 sql 的方式来对 ES 进行查询。但用 `select` 查询的时候如果不指定 limit 的数量，默认始终是 200

- 想起以前看过的一个挺有意思的 [问题](https://www.zhihu.com/question/38331955)，刚好最近在学 Scala，试着写一个

{% highlight Scala %}
var boyfriendList = Array.fill(12)(0)

def calculate(total:Int=0,freq:Int=0):Int = total match {
    case 12 => {
        println(s"总次数为 $freq ")
        freq
    }
    case _ => {
        boyfriendList(nextInt(12)) = 1
        calculate(boyfriendList.sum,freq+1)
    }
}

object Application extends App {

    var boyfriendList = Array.fill(12)(0)
    var index = 1
    var count = 0
    while(index<=50){
        boyfriendList = Array.fill(12)(0)
        count += calculate()
        index += 1
    }
    println(sum.toFloat/50)  // 34.64
{% endhighlight %}

啊，Pattern Matching 这里还比较好，但 var 和 val 变量这里自己做的太 tricky 了 ......

- 今天群里在讨论爬虫被抓的一个问题，有人提到可以模拟搜索引擎，就搜了一下...还真有这种数据，看这个 [Google Crawler](https://support.google.com/webmasters/answer/1061943?hl=en) ，把 `UA` 配置成 `Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)`

- Python 2.6 里一个输出语句 `print '{}'.format(1)` 会报错，提示 `ValueError: zero length field name in format`，必须指明顺序，`print '{0}'.format(1)`。啊...连 2.7 和 2.6 都不能做到完全兼容，有毒...

- 今天遇到一个挺有意思的问题。日志打码用的是 pageName&{key1:value1,key2:value2} 的形式，通常情况下用 split("&")[1] 得到 JSON 字符串后用 get_json_object 来查就可以了。但如果所提供的 value 里面有多个 "&"(如含参的 url)，那么分隔开后就会产生只有一个 `"` 的字符串，读不出 JSON 格式。所以就写了一个 UDF 来解决(额，貌似 Hadoop.io.Text 效率比 Java 的 String 高......)

{% highlight Java %}
/**
 * 主要处理 url 中包含 & 从而不能用 split("&") 来分割的情形
 * input:String
 * output:JSON-like Object
 */

import org.apache.hadoop.hive.ql.exec.UDF;
public class dealJSONWithUrl extends UDF {

    public String evaluate(String input) {
        if (!input.contains("&"))
            return input;
        String[] temp = input.split("&");
        StringBuilder builder = new StringBuilder();
        for (int i = 1; i < temp.length; i++) {
            if (i != temp.length - 1)
                builder.append(temp[i]).append("&");
            else
                builder.append(temp[i]);
        }
        return builder.toString();
    }
}

{% endhighlight %}

- crontab 总会有一些非常 tricky 的问题...今天遇到的是运维老师写的一个`redis-cli` 清数据的时候在 shell 脚本里不能直接用 `redis-cli`，而是一定要用绝对路径（线上服务器的绝对路径是在 `/usr/local/lib`，测试服务器上是 `/usr/bin`，后者可以在 shell 里直接删...所以是这个原因吗？）。还想起之前一个 Python 程序总是不能正常运行，最后发现是因为自己用了 `os.chdir('..')`，要先 `cd` 到目录再跑。这个坑踩过的人还不少啊...[这个](https://www.digitalocean.com/community/questions/unable-to-execute-a-python-script-via-crontab-but-can-execute-it-manually-what-gives)...supervisor 里能指定 `Directory` 实在太幸福了...

- 有一段时间搜狗输入法会莫名其妙崩溃，突然就无法输入中文了。没有办法，写了个 `alias sogou='pkill sogou-qimpanel && fcitx && sogou-qimpanel&'` 的命令，一有崩溃就重启。

- 上面说的这个故障应该是搜狗输入法云端输入后台的故障，因为大概在某一个时间段内同时在 PC 和自己的笔记本上遇到这个 Bug，在此之前和在此之后都没有能复现这个问题...

- row_number() over 查询分组，用 row_id 来选择指定

- 之前用 `ssh-copy-id` 配置免密码登陆后一般都是在 bash 里面设置一个 alias，比如 `ssh-75='ssh root@10.10.8.75'` 这种，今天又学习了一点新的人生经验，可以在 ~/.ssh 里直接配一个 config 文件。看看 [create-ssh-config-file-on-linux-unit](https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/) 

- ubuntu 上最喜欢的命令行工具是 `guake`，`F12` 一键呼出，再配合上 `tmux` 分屏...可惜的是我不是纯 vim 党啊...有时候 guake 会突然变空白，这个时候杀掉进程就好了，但之前运行的一些程序会还运行。当然像 `shadowsocks` 这些程序会提醒你端口被占用，但 `openvpn` 是不会告诉你已经有一个实例运行了啊...再开一个就会造成你在服务器上动不动就被踢下去...

- 今天用到了 pip 的一个功能... 把所有项目的依赖下下来并且不安装: `pip install --download /path module_name`，scp 上传后用
`pip insall --no-index -f /path module_name` 来安装

- 又是 Hive 时间的问题.....在 unix_timestamp 转化时，如果时间格式如 `2016-06-27 11:00` 因为没有秒数，所以实际上是无法进行转化的。它查询时也不会报错，但也永远不会有合乎要求的结果。最后用 concat() 连接上不会影响时间的 `':','00'`再查。

- 需要用 JStorm 调用一个运维接口来发短信。但只有 Nimbus 服务器可以发短信，Supervisor 服务器没有对应的权限（host 地址设置问题）。这种分布式的问题总是由奇奇怪怪的原因产生...

- Java 的 jedis 只能在 getResource() 取得实例后再用 select 来选择分库，但 Python 的 redis client 是可以在构造函数里就指定的。

- 有时间要学学 docker 啊，真的要能统一开发环境和生产环境，那就很厉害了...

- 踩了 Hive SQL 的一个坑，不同表的时间格式不一样，转的时候要这么用：from_unixtime(unix_timestamp('20160521','yyyyMMdd'),'yyyy-MM-dd')

- Gunicorn 部署。一个空格引发的惨案，噗

- Anaconda 突然发现 .condarc 好像不起作用了，不从清华的源安装。看了看 `conda install -h`，用 `--channel https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/` 来指定以后就可以了。还有问题是提示没有权限，，，看了一下，文件上显示锁，chown + chmod ~~

- 几百行的 SQL 到底是怎么维护

---

- 等待毕设结果，有些焦虑......写了个模拟登陆教务处的脚本，下载完验证码后输入到命令行中......没有能明确显示登陆结果的标志，最后发现可以用返回 header 的 Content-Type 来判断，如果后缀是 `gb2312` 就登陆成功，而后缀是 `GBK` 就登录失败(好奇葩是不是......当时是谁写的这个网站⊙﹏⊙b)。本来想再分析一下课表的，但发现 post 请求的结果是一个 js 函数......竟然有这种 Web 开发方式......虽然也能解析但......还是算了......并且它的登陆逻辑是有问题的啊，填完一次验证码后就能多次尝试登陆，按照大多数人的习惯，如果还是六位数密码，那么最多跑 10**6 次就肯定能破出密码来~~~
![lesson-course-list](/images/lesson-course-list.jpg)
![brute-force](/images/brute-force.jpg)

- 花在写论文上的时间比在代码上的时间还多：-D

- 中期答辩前终于把简化版的结果做出来了...但中文字符前都会有一个 u'' Unicode 标识符，影响美观

- 为何要作死...用 `sudo shutdown now` 来关机,然后黑屏状态->强制关机->重启后发现怎么输入密码都不对.重装系统...

- 用 ubuntu 用多了会在某些时候觉得真的不方便啊,大概是 auto-remove 和 purge 之间的混乱关系,或者是自己编译 OpenSSL 和安装后的 OpenSSL 产生冲突...`Arch wiki`能和 `ask ubuntu` 提供一样的帮助,随时升级内核比不敢 `upgrade` 高到不知道哪里去了...但路径依赖...再在这上面折腾就太耗时间了...

- 被 STL 的 Vector 坑大了==>!!!!

- Sublime 的列操作，`ctrl + shift + L`

- Windows 下的命令行终端还是推荐 cmder，能使用 `cd/ls` 等常用命令，切换磁盘(以D盘为例)请直接用 `D:`，要使中文字符不产生缩进可以选择右侧的设置(ctrl+alt+p),勾选 monospace 为不使用状态，并且自带对 git 的支持。再也不用 `git bash` 了...

- 在 VMWare 上安装 Ubuntu 镜像遇到了桌面无法显示边栏和顶栏问题，最后用的是 ccsm 来解决(`sudo apt-get install ccsm`，执行软件，并选中 Unity，执行，关机重启)

<!-- 数万人的流离失所比不上一张孩童溺水的照片所引起的影响力大。心理学的理论再一次得到了令人心悸的验证。 -->

<!-- @tombkeeper 曾经在微博上发过这样一条状态： 很多人都想师从名家，但优秀的老师往往也很难容忍甘于平庸和疏于自律的学生。如果你没做好努力上几年的准备，也许一开始就不该选这样的老师  时时转发自省 -->

<!--
说好的出国已经成为泡影，整个的职业生涯规划都要因此改变。

《The House Of Cards》第一季第一季里Frank说"Never again will I allow me to be put into such a position"；

《TGW》里Alicia在独立办律所后向Cary大吼“You know what? go to hell"；

好多事情，只有亲身经历才能知道。高中时所犯的错误，以后绝不会再犯。

无限的沉迷于手机信息流的feed,no struggle for what you want，too care about others,and gain nearly nothing now,the body engineering.

The Promised Land.
-->

<!--Thanks for your advice  
All options are open to me
I will decide during the next 48 hours
-->

<!-- 本来在原著中是非常小的一段描写”石墩出动“，在电影中是非常壮观的一个场景。”Hogwarts is threatened.man the boundary,do the duty to our school"-->

<!--
每个人心里都有一个方向，由DNA所引发，一直到20岁都会持续变化，就是你所经历的事、遇到的人、走路的路，就是摩西所说的“promised land"。它的翻译“必见辽阔之地”一直被我认为是最好的翻译之一。在你经历过一天之后，你会清醒的知道它是否有助于你实现你的目标，即便你的潜意识里在否认。
-->

<!--
    * 2015.07.04 星期六

很少想到有一天压力竟然能这么大……

跑了5圈就已经受不了了。
-->


- 之前在用 Intellij IDEA 和 Pycharm 时候一直用的是 Sublime Text2 的配色，来自[Intellij theme](http://www.ideacolorthemes.org/home/)虽然配色很好，但还是和 ST 有差距。今天修改了一下 Line Comment 的颜色，改成 RGB(138,130,107)，评论颜色为淡灰色，更容易和正文区分开，给原作者发了封邮件，邮件秒回，发邮件这个真的是美帝人民的天赋技能...自己当时是怎么写出 is not very good 这种小学英语的...我的天...

![Email And Send](/images/contact.JPG)

- jkeyll竟然不支持Pagination下的categories/tags 集合，试了半天啊...

> Pagination does not support tags or categories.Pagination pages through every post in the posts variable regardless of variables defined in the YAML Front Matter of each. It does not currently allow paging over groups of posts linked by a common tag or category. It cannot include any collection of documents because it is restricted to posts.

- 计算机系统结构试验要求是用WInDLX平台来模拟，现在才知道不同平台汇编语言标准不统一...其他语言都是标准一样实现不一样的

- 计算机网络实验，用微软的 network monitor 来监控，用 display fliter 来过滤，但是为什么不用 fiddler 呀

- 手写 Parser 和 Token ...

- 写《通信原理》的结课论文，发现一本扫描版的书也给搜出来了，Google...OCR...ORZ...

---






