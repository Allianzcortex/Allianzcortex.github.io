---
layout: post
title: A Problem about urlencode,space and 20%
date: 2016-12-15 17:59:20
categories: urlencode
comments: true
---
So when url is encoded/decoded, when to use + and when to use %20?
<!-- more -->


[这篇文章对应的中文版](/../translation/2016-12-15-urldecode-20-space.html)

#### Background

In short, this is the case. The mobile application logs of company is collected by Nginx.
Encode with `urlencode`. tricky method is to us `tail -F | grep ***` to find the target line and then parse it with pratical tools, but recently we have to deal with the logs, so there must be one way to do it automatically. gland to find [method](http://stackoverflow.com/questions/28431359/how-to-decode-a-url-encoded-string-in-python) on **StackOverFlow**, so directly import `urllib. Unquote` to the code .


#### Development

But soon something wrong happened, if the time format given is `2016-12-15 12:02:22`, the result after processing is formatted as
`2016-12-15+12:02:22`. It’s impossible to sort by the time of the recent occurrence, even the most basic search functions will be a big problem,let alone further processing.

#### What Happened

There is still [discussion](http://stackoverflow.com/questions/1634271/url-encoding-the-space-character-or-20) about this problem on SO，and quote the wikipedia：


> When data that has been entered into HTML forms is submitted, the form field names and values are encoded and sent to the server in an HTTP request message using method GET or POST, or, historically, via email.[2] The encoding used by default is based on an early version of the general URI percent-encoding rules,[3] with a number of modifications such as newline normalization and replacing spaces with + instead of %20. The media type of data encoded this way is application/x-www-form-urlencoded, and it is currently defined (still in a very outdated manner) in the HTML and XForms specifications. In addition, the CGI specification contains rules for how web servers decode data of this type and make it available to applications.
When HTML form data is sent in an HTTP GET request, it is included in the query component of the request URI using the same syntax described above. When sent in an HTTP POST request or via email, the data is placed in the body of the message, and application/x-www-form-urlencoded is included in the message's Content-Type header.

发生的原因是 URL 编码是分裂的，老式的 application/x-www-form-urlencoded 空格被表示为 + ，而 + 被表示为 "%2B"。比如在 Google 里搜索"Python urlencode+20"，query url 为 `https://www.google.com/search?q=Python+urlencode%2B20`

在现代的 url 的 HTTP URLs 中，空格被编码为"%20"，而 + 不被编码。

在给的日志中空格仍然是按照 "+" 来传递的，而 unquote() 是按照现代方式解码的，所以造成结果的差异。解决办法就是在解码前用 `raw_data.replace('+','%20')`来把空格给转回去(因为日志包含内容里没有 + 号，所以这么做不会影响日志的表达性)。

关于 urlencode 编码中各种对应关系，可以参考 [这个列表](http://www.degraeve.com/reference/urlencoding.php)
