---
layout: page
title: "Projects"
permalink: /projects/
---

Some projects I wrote：

- [FBRank](https://github.com/Allianzcortex/FBRank)    <img src="https://camo.githubusercontent.com/679ca6ebb312875e15236daf218fc068060083b8/68747470733a2f2f62616467652e667572792e696f2f70792f464252616e6b2e737667" alt="PyPI version" data-canonical-src="https://badge.fury.io/py/FBRank.svg" style="max-width:100%;"> ![continuous-development](https://travis-ci.org/Allianzcortex/FBRank.svg?branch=master)

<!-- <iframe src="https://ghbtns.com/github-btn.html?user=Allianzcortex&repo=FBRank&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe> -->

A Python command line tool published in `pypi` that was created to view league rankings, up to date news
and scores for various soccer leagues

![FBRank](/images/FBRank.png)

---

- [Scala-Problem](https://github.com/Infra-Intern/Scala-Problem) [![Build Status](https://travis-ci.org/Infra-Intern/Scala-Problem.svg?branch=master)](https://travis-ci.org/Infra-Intern/Scala-Problem)

Implemented some OJ Solutions in Scala including Scala99

- Wrote full test cased with Junit and ScalaTest while testing them in both `Intellij IDEA` and `Travis CI`

---

- [golean](https://github.com/Allianzcortex/golean)

A Golang tool that can be used to join screenshots of teleplay while also specifying the caption height

below is the generated picture:

![golean](/images/golean.jpg)

---

- [code collection](https://github.com/Allianzcortex/code_collection) ![build](https://api.travis-ci.org/Allianzcortex/code_collection.svg?branch=master)

A bunch of code `misc/projects/demos`

- Demos of different programming languages

- Using a [makefile](https://github.com/Allianzcortex/code_collection/blob/master/makefile) to run unit tests for `single directory`


---

- [LaraForum](https://github.com/Allianzcortex/LaraForum) [![Build Status](https://travis-ci.com/Allianzcortex/LaraForum.svg?token=eY1dQPtFsNYcmsgAHTB5&branch=master)](https://travis-ci.com/Allianzcortex/LaraForum)



A Forum based on `Spring Boot/Spring MVC/Spring Data JPA/MySQL/Angular/Restful`

- Implemented authentication by `JWT(Json Web Token)` and authorization by `AspectJ(AOP Programming)` without intrusion to function code
- Integrated Travis with `Unit/Integration Test` written in `JUnit` and `Mockito` to achieve Continuous Integration

<!-- <iframe src="https://ghbtns.com/github-btn.html?user=Allianzcortex&repo=cortexForum&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe> -->

---

- [MusicRecommenderSystem](https://github.com/Allianzcortex/MusicRecommenderSystem)

A recommender website that provides recommendation music you may like

- Used [requests](https://2.python-requests.org/en/master/) to write the `multi-threaded crawler` that extracted album/song information used as train dataset
- Implemnted the `Item-CF` algorithm used to calculate the item similarities and provide the recommended results
- Built the system based on `MVC architecture(Bootstrap/Jquery/Django)` and deployed it with `Nginx/Gunicorn`
- Performed `data visualization` based on user feedback(e.g. fresh rate) via Google `Highcharts` library

---

- [AccountBook](https://github.com/Allianzcortex/AcountBook)

A family asset management software based on [QT](https://www.qt.io/)

---

Projects I participated：

- Provided 2 PRs for  [zhih-oauth](https://github.com/7sDream/zhihu-oauth) written by `@7SDream` 
  [PR1](https://github.com/7sDream/zhihu-oauth/commit/6ac68940b1661c07c6d2758695eb00510733976c) [PR2](https://github.com/7sDream/zhihu-oauth/commit/bb68a4774a188be07e2f004493429166dcef6294)

- provided a revised version [myLM](https://github.com/Allianzcortex/myLM) for [LibraryManagement](https://github.com/yumendy/LibraryManagement) written by `@yumendy`.
Used  `form` to replace `request.POST.get()` with `form.cleaned_data.get()`, which made it easier to separate the front and back ends. Increased the judgment of error conditions, while migrating the database from `SQLite` to `MySQL`

---

Projects in the pending：

<!-- - [Seaeels](https://github.com/Allianzcortex/Seaeels) 一个爬虫框架。不知道什么时候能继续写完啊......不过 `crawlProxy` 文件夹里实现了从
`xici 秘密花园 peuland ip84` 里爬代理 IP 的几个方法。 -->

<!-- <iframe src="https://ghbtns.com/github-btn.html?user=Allianzcortex&repo=Seaeels&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe> -->

- [bweever](https://github.com/Allianzcortex/bweever)

Based on some features of `Python`, we can implement the following codes:

{% highlight python %}
class AlgorithmImplementation(object):

    @staticmethod
    def _get_doc():
        doc_en = """some English illustration"""
        doc_fn = """some French illustration"""
        help_doc = {'en': doc_en, 'fn': doc_fn}
        return help_doc

    def __doc__(self):
        return AlgorithmImplementation._get_doc().get('en')

    def __call__(self):
         """ now execute the real sort """ 
{% endhighlight %}

using  `__call__` to call the real function , using __doc__ to call the default documentation,like :

{% highlight python %}
def help_cn(problem):
    return problem._get_doc().get('en')

def help_en(problem):
    return problem._get_doc().get('cn')
{% endhighlight %}

Then we will be able to type the input in shell：

```
>>> from bweever import SomeAlgorithm,help_en,help_fn
>>> help_en(SomeAlgorithm) # check explanation of Algorithm with French
>>> help_fn(SomeAlgorithm) # check explanation of Algorithm with English
>>> SomeAlgorithm(input)   # execute the real algorithm function
```

<!-- 
<iframe src="https://ghbtns.com/github-btn.html?user=Allianzcortex&repo=bweever&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe> -->

<!-- 业余时间维护了一个 [infra-intern](https://github.com/Infra-Intern) 的组织账号，来记录学习 infra 相关知识时做的笔记。
其中里面一个相对有趣的项目是 [Scala-Leetcode](https://github.com/Infra-Intern/Scala-LeetCode)
<iframe src="https://ghbtns.com/github-btn.html?user=Infra-Intern&repo=Scala-LeetCode&type=star&count=true" frameborder="0" scrolling="0" width="170px" height="20px"></iframe>

其他的一些项目包括 [消息队列](https://github.com/Infra-Intern/MQ-DOC)、[RPC 框架]()、[分布式文件存储](https://github.com/Infra-Intern/LearnHDFS)、[分布式计算](https://github.com/Infra-Intern/LearnSpark)、[分布式缓存](https://github.com/Infra-Intern/LearnCodis)、[Netty 聊天系统](https://github.com/Infra-Intern/NettyCommunicationSystem)
 -->
