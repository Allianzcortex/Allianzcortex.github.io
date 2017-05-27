---
layout: post
title: urlencode 的 space 问题，又是大坑
date: 2016-12-15 17:59:20
categories: urlencode
comments: true
---
所以在 url 编/解码的时候，什么时候用 + ，什么时候用 %20 啊.......
<!-- more -->

#### 背景

简而言之是这样的，我司(写上这个词瞬间感觉逼格高了好多.......)的移动端打码是用 Nginx 收集，
用 `urlencode` 编码。日常比较懒的话都是 tail -F | grep *** 后用在线工具解析的，但最近要对日志进行处理，就不能这么做了。喜闻乐见爆栈站上就有这个 [解析方法](http://stackoverflow.com/questions/28431359/how-to-decode-a-url-encoded-string-in-python)，那就直接 `urllib.unquote` ，然后传进去。

#### 发展

但很快就发现不对劲啊，，，，如果说给的时间格式是 `2016-12-15 12:02:22`，在处理写进去之后的结果为
`2016-12-15+12:02:22`。这么下去根本无法按照最近发生的时间来进行排序，连最基本的搜索功能都
做不了，就更不要说进一步的处理了。

#### What Happened

SO 上仍然有关于这个问题的 [讨论](http://stackoverflow.com/questions/1634271/url-encoding-the-space-character-or-20)，就直接摘录 wikipedia 了：


> When data that has been entered into HTML forms is submitted, the form field names and values are encoded and sent to the server in an HTTP request message using method GET or POST, or, historically, via email.[2] The encoding used by default is based on an early version of the general URI percent-encoding rules,[3] with a number of modifications such as newline normalization and replacing spaces with + instead of %20. The media type of data encoded this way is application/x-www-form-urlencoded, and it is currently defined (still in a very outdated manner) in the HTML and XForms specifications. In addition, the CGI specification contains rules for how web servers decode data of this type and make it available to applications.
When HTML form data is sent in an HTTP GET request, it is included in the query component of the request URI using the same syntax described above. When sent in an HTTP POST request or via email, the data is placed in the body of the message, and application/x-www-form-urlencoded is included in the message's Content-Type header.

发生的原因是 URL 编码是分裂的，老式的 application/x-www-form-urlencoded 空格被表示为 + ，而 + 被表示为 "%2B"。比如在 Google 里搜索"Python urlencode+20"，query url 为 `https://www.google.com/search?q=Python+urlencode%2B20`

在现代的 url 的 HTTP URLs 中，空格被编码为"%20"，而 + 不被编码。

在给的日志中空格仍然是按照 "+" 来传递的，而 unquote() 是按照现代方式解码的，所以造成结果的差异。解决办法就是在解码前用 `raw_data.replace('+','%20')`来把空格给转回去(因为日志包含内容里没有 + 号，所以这么做不会影响日志的表达性)。

关于 urlencode 编码中各种对应关系，可以参考 [这个列表](http://www.degraeve.com/reference/urlencoding.php)
