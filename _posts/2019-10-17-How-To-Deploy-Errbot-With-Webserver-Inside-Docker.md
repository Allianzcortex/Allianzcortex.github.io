---
layout: post
title: How to deploy Errbot with Webserver plugin activated(inside docker)
date: 2017-05-21 16:29:10
categories: Scala
comments: true
---

`Connecting the dots when you search through the document & issue & source code`. This passage will show how you can deploy the Errbot in production environemnt with Webserver activated.

<!-- more -->
[这篇文章对应的中文版](/../translation/2017-05-21-Scala-Test-Junit-Sbt-Problem.html)

The fix solution:

TL;DR. Solution:

1. Ensure that you can run the Webserver normally with interactive mode
2. Copy&Paste the following 6 files into data folder(if you already have it or run the
docker inside the same folder, then this step can be skipped)

```
core.db.bak
core.db.dat
core.db.dir
TextCmds.db.bak
TextCmds.db.dat
TextCmds.db.dir
```
3. Copy&Paste the `backup.py` from https://github.com/errbotio/errbot/blob/master/errbot/core_plugins/backup.py and put it inside the `data/` folder

4. change the command into `errbot -r && errbot`(no matter you deploy it by supervissor or other daemon tool)

---

