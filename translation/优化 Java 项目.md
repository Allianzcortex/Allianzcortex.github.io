---
layout: post
title: Improve Java Project Performace 20 times ！
date: 2019-01-27 13:29:10
categories: Java
comments: true
---

最近在完成 Business Development 这门课的第一门 Assignment，老师已经把课程要求发在了 [github](https://github.com/DanielPenny/MCDA5510_Assignments/blob/master/Assignment%201.pdf) 上，
简单总结一下就是需要读取一个文件夹下所有的 csv 文件并将文件内容写入到新的同一个 csv 文件里。

根据要求我不会过多讨论关于代码本身，只是讨论一下思路。

除掉用日志统计执行时间和 valid rows 这些琐碎要求，这个项目可以被划分为三个部分：

1. 读取一个文件夹下所有的文件绝对路径
2. 读取一个 CSV 文件下的内容
3. 向 CSV 文件里写入内容


性能提升自己主要做的是两方面：

1. 用 Apache 的 CSVPrinter 取掉本身的 writer

如果我们用任意一个文本编辑器(vscode/sublime/vim)打开 csv 文件，都可以发现它和 .txt 文件的区别只是在于
用 `,` 来作为列分隔对象，所以开始时我用的也是这种思路来进行写：

{% highlight Java %}
BufferedWriter writer = null;
try {
        //writer = new BufferedWriter(new FileWriter("result.csv"));
        writer = new BufferedWriter(new OutputStreamWriter(
                    new FileOutputStream("result.csv"), "utf-8"));
        } catch (IOException ex) {
            ex.printStackTrace();
        }
StringBuilder sb = new StringBuilder();
for (String item : input) {
    sb.append(item);
    sb.append(",");
    }
    sb.append("\n");
    writer.write(sb.toString());
{% endhighlight %}

但是就如我们所说，csv 是一种非常常用的文件格式，所以一定会有 library 对此进行了优化，所以
换用 apache common csv library 里的 CSVPrinter 来专门进行处理：

{% highlight Java %}
import org.apache.commons.csv.CSVPrinter;

CSVPrinter writer = null;
try {
            //initialize FileWriter object
            FileWriter fileWriter = new FileWriter(config.ResulFile);

            CSVFormat csvFileFormat = CSVFormat.DEFAULT.withRecordSeparator("\n");
            writer = new CSVPrinter(fileWriter, csvFileFormat);
 } catch (IOException ex) {
            ex.printStackTrace();
        }

printer.printRecord(input);
validRows += 1;

{% endhighlight %}


2. 第二点优化的部分主要是针对 Assignment 所说的 bonus point，这里不能泄露具体的项目要求，但
简单来说就是有诸如 `prefix2019/01/27suffix` 的字符串，要转化为符合 `YYYY/MM/DD` 的 `2019/01/27`格式。

一开始我的做法是 split string 得到 year/month/date 的数值后再添加 leading zero。要满足：
"1"->"01","12"->"12" 这样的转换，那么很自然我的思路就是：

```
month = String.format("%02d", Integer.parseInt(month));
```

这种做法也确实是有效果的，但问题关键就是耗费时间太长。几百个文件一共包含 280000 行内容，如果
按照这种做法最后需要 80000ms 的时间。我的优化结果其实很像 ACM/ICPC 里的一种优化技巧：

因为一共最多也只有 12 个月，一个月最多也只有 31 天，只要列出对照关系就能利用 HashMap 在 O(1) 
时间内找出解决方法。

![playtable.PNG](/images/playtable.PNG)

效率的提升是 obvious 的，时间下降到了 4000ms。从 80000 到 4000，程序不可思议地提高了 20 倍 !

---

但是还有没有办法来解决这个问题呢，其实还是有的。如果你在 Google 里搜索：**java format date string to another format**, 排名第一的链接就为我们提供了方法：

```
SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat format2 = new SimpleDateFormat("dd-MM-yyyy");
Date date = format1.parse("2013-02-21");
System.out.println(format2.format(date));
```

但是这个程序的本质是完成 string->string 的转换，上述方法的流程则是 string->date->date->string ，显得
多余了很多，所以这只是理论上的一种可能，我并没有采用
