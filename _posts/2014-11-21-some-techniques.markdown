---
layout: post
title: Mumbler About Techonology(Continually updated)
date: 2014-11-21 19:40:01
categories: techniques
comments: true
---

Mumblers about technology...too short to write a novel

<!-- more -->

[这篇文章对应的中文版](/../translation/2014-11-21-some-techniques.html)

About crypto,mainly I want to discuss the `Bitcoin arbitrage`,`Bitcoin storage, instability of external exchanges(such as binance)`,`relationship between concept、code and white paper`

My bitcoin address is :**1KAYM9K6M6Cp7RJwwr4K1m59ETPxB6o8n4**

Below is tredency of `EOS`:

![EOS.png](/images/EOS.jpg)

---

Recently I'm writing java dedipher code,the initial part is written in Java：

{% highlight java %}
 private static byte[] decrypt(byte[] data, byte[] key) throws Exception {
        SecureRandom sr = new SecureRandom();
        DESKeySpec dks = new DESKeySpec(key);
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
        SecretKey securekey = keyFactory.generateSecret(dks);
        Cipher cipher = Cipher.getInstance("DES");
        cipher.init(2, securekey, sr);
        return cipher.doFinal(data);
    }
{% endhighlight %}

I need to translate it into Python.Thanks for [decrypt](https://www.tools4noobs.com/online_tools/decrypt/) ，It can be implemented in 2 lines:

{% highlight Python %}
def decrypt_des(input_):
    """
    :param input_: ciphered text
    :return: DES deciphered text
    """
    des = DES.new("naidnefi", DES.MODE_ECB)
    return "".join(x for x in des.decrypt(b64decode(input_)) if 31 < ord(x) < 127)
{% endhighlight %}

But the result contains much '\x5'，you can review [ascii](http://donsnotes.com/tech/charsets/ascii.html) to get the exact meaning,solution is based on this link [remove-special-characters-from-the-string](https://stackoverflow.com/questions/14256593/remove-special-characters-from-the-string)

---

Today I helped the algorithm team debug...weired... It was very troublesome to deal with Chinese with Python2, especially when using regular rules to adjust. After debugging a lot of unicode characters, It can finally run... The phenomenon is it can run in the test server , but cannot run in  the online server. Finally, I found this                                                [ucs-2-or-ucs-4](https://stackoverflow.com/questions/1446347/how-to-find-out-if-python-is-compiled-with-ucs-2-or-ucs-4). So the reason is that test server is compiled with ucs4, while online server is compiled with ucs2.

---

subscribe the blog via **IFTTT** successfully,it can send the new blog into your email 
![rss.png](/images/rss.png)

---

Helping others to search for a foursquare data set. The starting link address is at [dateset](http://www.public.asu.edu/~hgao16/dataset.html), but the link is invalid. If you search with Google, you can find a reddit post in the corner of the page [foursquare_data_set](https://www.reddit .com/r/datasets/comments/1nywu2/foursquare_data_set/), which provides downloadable zip file,about 150M+.

---

The most common function in StringUtils of Java is to make the first letter lowercase, which is usually implemented as this:.

There is an elegant answer in SO: 

{% highlight Java %}
char c[] = string.toCharArray();
c[0] = Character.toLowerCase(c[0]);
string = new String(c);
{% endhighlight %}

A tradeoff between performance and readability.

---

Curator is a open source tool by Linkedin for zookeeper encapsulation that provides a variety of handy features, including updating configuration files and selecting leader nodes. There is an implementation on Spark.Corresponding code link is : `spark/core/src/main/scala/org/apache/spark/deploy/master/ZooKeeperPersistenceEngine.scala`

---

Some records.

**ETL** means **Extract->Transform->Load** 

HDFS Data always comes from：

- Import from existing RDBMS database for business analysis.An example of the first tool is [Sqoop]() from Apache.

- Connect and sample from existing HDFS data to generate new composite data

- Some other ways, including writing from HDF Sink in Flume, or using `hadoop fs -put` to import local files into HDFS

The second tool in most cases uses Hive to meet the requirements. Hive is a tool from FaceBook that converts HQL (SQL-like syntax) into MapReduce implementations for data analysts to manipulate. It actually is the symbol of the distributed SQL.There are many projetcts that are trying to do the distributed SQL query,such as [Spark](https://spark.apache.org/) with scala and [TiDB](https://www.pingcap.com/en/) with golang.But the basic steps are same,converting the AST(Abstarct Syntax Tree) into LogicalPlanner and execute it in multiple nodes.

Tthe scheduling system is also attractive. In principle, you just neet to write the execution script, set up the timing task directly with crontab. But on the one hand, we have to manage multiple scripts as the volume of business increases. On the other hand, we want to add progress reminders, logs view, failure retry, email alerts, and manage multiple interdependent tasks. In this case, **Ozzie/Azkaban/Airflow** and other projects are always best choices.

---

How to implement the `join/left join/right join` in MapReduce ? you can review this question [How-does-Hive-implement-joins-in-Map-Reduce](https://www.quora.com/How-does-Hive-implement-joins-in-Map-Reduce).There are two cases:`Map-side` and `Reduce-side`.Usually you can use ArrayList to store MultiInput,but the obvious flaw is that the system will crash or hang when data are intensive.

---

Trying to use GitLab CI today.It is not much different from Github's travis-CI(distinguished by stages:build/deploy) in terms of personal experience. But the  problem happens below:

![build-failure.png](/images/build-failure.png)
Based on [link](https://docs.gitlab.com/runner/install/linux-repository.html),you need to install **runner** and **Gitlab** at the same server.

Record my `.gitlab-ci.yml` script:

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

`mvn '-Dtest=com.xxx.example.*Test' test` is used to run all unit test in one package.

---

Discovering that after IDEA is configured, you can't use Socks5 to download SBT dependencies...After a few hours of trial,I give up to find the reason but to add `-Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=8080` in the SBT.Anyway it works......

---

When debugging the Spark Streaming program in the Spark source code on your laptop, you need to change the corresponding **VM Options** to `-Dspark.master=local[2]`, otherwise
there will be an error like  **netword connection refused** 

---

One of the most important features of a distributed system is that **CAP** cannot be met at the same time. The first link Google found was [Quora's answer] (https://www.quora.com/Can-someone-provide-an-intuitive-proof-explanation-of-CAP-theorem), which mentioned a Very good [InfoQ article] (https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed), let me try to re-explain it. **C** refers to **Consistency**, **A** refers to **Availability**, and **P** refers to **Partition Tolerance**. Always we have to ensure that multiple nodes are running(preventing [SPOF](https://en.wikipedia.org/wiki/Single_point_of_failure), so **P** is definitely to be satisfied. For **C** and **A**, you can only choose one, for example:

> A cluster has two machines, A and B (here simplified for the sake of example, in production environments it is usually required to be odd bigger than 1).
Whenever A/B has data written, it will be synchronized on B/A at the same time.
But suddenly the network connection has failed and communication between A and B is not possible. At this time, for A, there are two options:

1. In order to maintain consistency, external requests should not be accepted to ensure that data does not change, and availability cannot be met.

2. In order to maintain availability and continue to accept requests, the data on the two machines will be inconsistent, and consistency will not be met.

At this time, most of the choices are to maintain external availability. The two machines continue to provide services to the outside world. When the communication can continue, the data is synchronized(you need a replication tool to achieve it,such as binlog of MySQL) .Thereby maintaining the eventual consistency.

![CAP.jpg](/images/CAP.jpg)

---

There are several concepts when measuring the availability of a system, one is **X 9**. described as follows:

> 3 9: (1-99.9%) * 365 * 24 = 8.76 hours:
Indicates that the most likely business interruption time of the software system during continuous operation for one year is 8.76 hours.
4 9:(1-99.99%)*365*24=0.876 hours=52.6 minutes:
Indicates that the most likely business interruption time of the software system during continuous operation for 1 year is 52.6 minutes.
5 9: (1-99.999%) * 365 * 24 * 60 = 5.26 minutes:
Indicates that the most likely business interruption time of the software system during continuous operation for one year is 5.26 minutes.

---

I recently wrote a MapReduce program that parses out a bunch of variables to produce a string. Although I know there is a `join` method in the `Guava` library, and `hasNext()` is used to avoid the implementation of the delimiter at the end , but it is not proper to import a jar package for such a small function.I try to implement one:

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

---

If the log file is too large, it should be processed. If it is me, I would write a Python/Golang script.But today I was taught a new skill.You can just edit **/etc/logrotate.conf** file under Linux. compressing,Removing,time settings, various features...

---

I’ve been reading [JStorm](http://120.25.204.125/) source code recently, and there’s a block of code like this...kill the process 5 times...make sure the process be killed definitely(???

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

---

The two concepts of `concurrency` and `parallelism` are often confused.Having a summary about it: concurrency is for the design of the program. (**concurrency as a property of a program or system**), a well-designed concurrent program allows the program to perform different tasks in overlapping time periods. Parallelism refers to the parallelism as the **run-time behaviour of the multiple tasks at the same time**. So if a concurrent program runs on a single cpu machine, it is still concurrent, but not parallel.

This Chinese article that explains the best is in [here] (https://laike9m.com/blog/huan-zai-yi-huo-bing-fa-he-bing-xing), English novel is a talk about Go language [slide](https://talks.golang.org/2012/concurrency.slide)

---

There is a 600M+ CSV file, because I need to experiment with conversion reads, so just splitting it by size. But after that, the file is garbled and can't be presented in a proper way.  `head -10` read out is fine. I also suspect that I didn't add a suffix, but the text file is not binary file...finally I realized that I shouldn't divide it by size... I should use `split -l` to divide by line so it is conveniet for subquent merge.


![无话可说](/images/青蛙.jpg)

---

Using `numpy.asarray() and numpy.fromarray()` to convert between the image and the matrix. Adding random number interference in the middle will make the font distorted, but this is more suitable for the recognition of handwriting. If it is a print for the photo, the appropriate method is to rotate a certain angle with rotate(). But there will be some black space, so just use crop() to intercept it.

---

Although [requests](http://docs.python-requests.org/en/master/) have been used all the time, I realize it today: [requests-code-read-content-auto-encode](http://sh3ll.me/2014/06/18/python-requests-encoding/). The principle of `chardet` recognition encoding was also mentioned in the 《Fluent Python》 before, based on the frequency of occurrence of the character prefix.

{% highlight Python %}
In [7]: chardet.detect('No longer plagued by coding problems 2333ShakaLaka!!!'.encode('GBK'))
Out[7]: {'confidence': 0.99, 'encoding': 'GB2312'}
{% endhighlight %}

---

There is a `user option` under the supervisor project configuration to choose which user to start the command with. But you must use the root account to start the supervisor.

---

Previously, this file was created with a Windows text editor instead of notepad++,newline is represented with '\r\n';and newLine in Linux is represented with '\n'. In other words, `Unix uses 0xA for a newline character. Windows uses a combination of two characters: 0xD 0xA. 0xD is the carriage return character. ^M happens to be the way vim displays 0xD.` (Refer to [this] (http://stackoverflow.com/questions/5843495/what-does-m-character-mean-in-vim)). The solution in the context of Py2 is to read it and then use` strip()` to process it once.

---

Kafka's UI is installed, and the final selection is Yahoo's [Kafka Manager](https://github.com/yahoo/kafka-manager). But it uses JDK8 ... detecting the amount of message per unit time. The final interface is okay, that is, the strong Bootstrap style:

![KafkaUI](/images/KafkaUI.png)

---

- If you want to delete log files,`rm -rf  && touch` is not a good choise.Using  `> ToDelete.log` instead

---

- Recently we use a plugin [elasticsearch-sql] (https://github.com/NLPchina/elasticsearch-sql) so querying the ES in the same way as sql is possible. But if you do not specify the number of limit when using `select` query, the default is always 200

---

- There was a [question](https://www.zhihu.com/question/38331955).Recently I'm just learning Scala,So I tried to solve it:

{% highlight Scala %}
var boyfriendList = Array.fill(12)(0)

def calculate(total:Int=0,freq:Int=0):Int = total match {
    // Using Pattern Matching
    case 12 => {
        println(s"Total number is $freq ")
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

---

The group is discussing a problem about catching crawlers. Some people mentioned that they can simulate a search engine and searched for it...it is really reasonable, see this article [Google Crawler] (https://support.google.com/ Webmasters/answer/1061943?hl=en) , configure `UA` to `Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)`

---

In Python 2.6, an output statement `print '{}'.format(1)` will report an error, indicating `ValueError: zero length field name in format`.You must indicate the order, `print '{0}'.format(1)` . Ah... even 2.7 and 2.6 can't be fully compatible

---

There is  a very interesting question today. The logging is in the form of **pageName&{key1:value1,key2:value2}**. Usually, spliting("&")[1] is used to get the JSON string and then using `get_json_object` to check it. However, if there is more than one "&" in the value provided (such as the url containing the parameter), then the separator will produce a string with only `""`.So I wrote a [UDF:User Defined Function](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF) to make the program robust.

{% highlight Java %}
/**
 * 
 * input:String
 * output:JSON-like Object
 */

import org.apache.hadoop.hive.ql.exec.UDF;

public class dealJSONWithUrl extends UDF {
    // handling cases where url contains & can't be split with split("&")
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

---

There are always some very tricky issues with crontab... Today my case is to use `redis-cli` to operate some instructions . When using the data, you can't use `redis-cli` directly in the shell script, but you must use the Absolute path. there was also  a Python program which always didn't work properly. The final reason is because `os.chdir('..')` is used in script file. You need to use  `cd` to enter into the target directory at first. There are  a lot of people who have stepped on this pit...such as [unable-to-execute-a-python-script-via-crontab-but-can-execute-it-manually-what-gives](https://www.digitalocean.com/community/questions/unable-to-execute-a-python-script-via-crontab-but-can -execute-it-manually-what-gives)...The ability to specify `Directory` in supervisor is so wonderful by contrast

---

For a while, the Sogou input method will inexplicably collapse, and suddenly it is impossible to input Chinese. I am uncapable of analyzing the source code,so just write a script like`alias sogou='pkill sogou-qimpanel && fcitx && sogou-qimpanel&'` restart when there is a crash

---

Using `row_number() over` to query group，and identifying it by row_id 

---

In the past I always  use `ssh-copy-id` to configure password-free login, generally set an alias in bash, such as `ssh-75='ssh root@10.10.8.75'`.today I learned a new skill today,you can directly match a config file in `~/.ssh.`. Take a look at [create-ssh-config-file-on-linux-unit](https://www.cyberciti.biz/faq/create-ssh-config-file-on-linux-unix/)

---

The favorite command line tool on ubuntu is `guake`, using `F12` to call it with a single click, and using `tmux` to split screen.They are perfect couples. sometimes guake will suddenly become blank It's fine to kill the process at this time, and some of the programs that were run before will still run. Of course, Programs like `shadowsocks` will remind you that the port is occupied, but `openvpn` will not tell you there is already an instance running.Reopening one will make you be kicked on the server...

---

using a function of pip today.Downloading all the dependencies of the project and did not install it: `pip install --download /path module_name`,after uploading the file into a non-network-connect server, execute `pip insall --no-index -f /path module_name` to install

---

It is also a problem with Hive time..... When the unix_timestamp is converted, if the time format is like `2016-06-27 11:00`, because there is no second, it is actually impossible to convert. But it  will not report an error when it is queried, so it will never have a satisfactory result. one solution is to query after using concat() to connect to `':', '00'` which will not affect the time.

---

Java's [jedis](https://github.com/xetorthio/jedis) can only use `select` to select the library after getResource() gets the instance, but Python's [redis client](https://redislabs.com/lp/python-redis/) can be specified in the constructor.

---

For Hive,if there are different time formats on different tables,you should convert like this:`from_unixtime(unix_timestamp('20160521','yyyyMMdd'),'yyyy-MM-dd')`

---

Writing a script that simulates logging into the Academic Affairs Office. After downloading the verification code and entering it into the command line... There is no flag that clearly shows the login result. Finally, I found that I can use the `Content-Type` of the return header to judge. if suffix is `gb2312` , logging is successful;if suffix is `GBK`,if failed. I wanted to analyze the class list again, but found that the result of the post request is a js function...so difficult to be parsed.And its login logic is not complete. After filling in a verification code, you can try to log in multiple times. According to initial rules, if you still have a six-digit password, you can definitely break the password after running up to 1000000 times,
![lesson-course-list](/images/lesson-course-list.jpg)
![brute-force](/images/brute-force.jpg)

---

Installing Ubuntu image on VMWare encountered the problem that the desktop could not display the sidebar and top bar. Finally, it was solved by ccsm (`sudo apt-get install ccsm`, execute the software, and select Unity, execute, shutdown and restart)

---

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

Previously, when using Intellij IDEA and Pycharm, the theme from [Intellij theme](http://www.ideacolorthemes.org/home/) has been used. Although the color matching is very good, it still has a gap with Sublime Text. I modified the color of the Line Comment, changing it to RGB (138, 130, 107).The color of the comment is light gray, and it is easier to distinguish it from the text. Sending an email to the original author,the email is sent back in seconds.

![Email And Send](/images/contact.JPG)

---

Jkeyll even does not support the categories/tags collection under Pagination

> Pagination does not support tags or categories.Pagination pages through every post in the posts variable regardless of variables defined in the YAML Front Matter of each. It does not currently allow paging over groups of posts linked by a common tag or category. It cannot include any collection of documents because it is restricted to posts.








