---
layout: post
title: Improve Java Project Performace 20 times ！
date: 2019-01-27 13:29:10
categories: Java
comments: true
---

<!-- more -->
Recently, I completed the first Assignment of Business Development. The teacher has already publish the course requirements to his [github](https://github.com/DanielPenny/MCDA5510_Assignments/blob/master/Assignment%201.pdf).
To sum it up, **you need to read all the CSV files in a folder and write the contents of the file to the new same CSV file.**

I will not discuss the code itself much as required, mainly talk about the idea.

In addition to the trivial requirements of using log to record execution time and valid rows, this project can be divided into three parts:

1. Read the absolute path of all files in a folder
2. Read the contents of a CSV file
3. Write to the CSV file

Performance improvement itself mainly can be done from two ways:

---

#### First:Use Apache's CSVPrinter 

If we open the CSV file with any text editor (vscode/sublime/vim), we can see that its' difference from the .txt file is mainly  that it 
Use `,` to separate objects as columns, so I used this idea to write to the CSV file at the beginning:

{% highlight Java %}
BufferedWriter writer = null;
try {
    Writer = new BufferedWriter(new OutputStreamWriter(
        New FileOutputStream("result.csv"), "utf-8"));
    } catch (IOException ex) {
        ex.printStackTrace();
    }
StringBuilder sb = new StringBuilder();
For (String item : input) {
    Sb.append(item);
    Sb.append(",");
    }
    Sb.append("\n");
    Writer.write(sb.toString());
{% endhighlight %}

But as we said, CSV is a very common file format, so there must be a library optimized for this,  and CSVPrinter in the apache common CSV library is exactly what we need:

{% highlight Java %}
Import org.apache.commons.csv.CSVPrinter;

CSVPrinter writer = null;
try {
    //initialize FileWriter object
    FileWriter fileWriter = new FileWriter(config.ResulF
    CSVFormat csvFileFormat = CSVFormat.DEFAULT.withRecordSeparator("\n");
    Writer = new CSVPrinter(fileWriter, csvFileFormat);
} catch (IOException ex) {
    ex.printStackTrace();
        }

printer.printRecord(input);
validRows += 1;

{% endhighlight %}

---

#### Second:Change Time Processing Logic
The second optimization part is mainly for the bonus point mentioned in the Assignment. Simply put, there is a string such as `prefix2019/01/27suffix` which needs to be converted to `2019/01/27` format that conforms to `YYYY/MM/DD`.

In the beginning, my approach was to split string to get the value of year/month/date and then add leading zero to satisfy  conversion such as "1"->"01", "12"->"12" .So naturally my idea is:

```
Month = String.format("%02d", Integer.parseInt(month));
```

This practice also works but it takes too long. Hundreds of files contain a total of 280,000 lines, and  approach took nearly 800,000 ms. My optimization method is quite similar to an optimization technique in ACM/ICPC:

Because there is only a maximum of 12 months in a total, and only 31 days in a month, as long as the conversion relationship is listed, we can use HashMap to achieve O(1) time complexity.

![playtable.PNG](/images/playtable.PNG)

The increase in efficiency is obvious, and the time has dropped to 4000ms. From 80000 to 4000, the program has increased incredibly 20 times!

---

Last but not the least, there is still one way to solve it .If you search in Google: **java format date string to another format**, the number one link gives us the light:
```
SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat format2 = new SimpleDateFormat("dd-MM-yyyy");
Date date = format1.parse("2013-02-21");
System.out.println(format2.format(date));
```

But the essence of this requirement is to complete the conversion of string->string. The circle of the method above is string->date->date->string. too tedious, isn't it ?, so this is only a theoretical possibility, I have not adopted it.