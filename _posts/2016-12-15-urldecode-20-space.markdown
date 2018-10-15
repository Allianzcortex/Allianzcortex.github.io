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

---

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

The reason for this is that the URL encoding is divided into two parts: the old-fashioned **application/x-www-form-url encoded spaces** are represented as + and + is represented as **%2B**. For example, search for "Python urlencode+20" in Google, and the query url is `https://www.google.com/search?q=Python+urlencode%2B20`

As for the HTTP URLs of modern urls, spaces are encoded as **%20** and + is not encoded.

In the given log, the space is still passed as "+", and unquote() is decoded in a modern way, so the result is different. The solution is to use the `raw_data.replace('+', '%20')` to convert the space back before decoding (because the log contains no + in the content, so this will not affect the expressiveness of the log).

For various correspondences in urlencode encoding, you can refer to this [Link](http://www.degraeve.com/reference/urlencoding.php).
