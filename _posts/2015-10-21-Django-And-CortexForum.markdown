---
layout: post
title: Django 学习及 cortexForum
date: 2015-10-21 20:39:49
categories: Django
comments: true
tags: [Django,Python]
---
关于 Django 的学习资料以及 cortexForum

<!-- more -->

##### 学习资料

主要看的是 Django 的官方 tutorial 和 [tango with Django](http://www.tangowithdjango.com/book17/)

进阶的书包括：

- 《Two Scopes of Django》:Django 作者是 Django 的社区开发者，汇聚了一大批的最佳实践

- 《Test Driven Web Development》:以 TDD(测试驱动开发) 方式所写的关于 Django 开发的一本书，非常漂亮啊

---

##### cortexForum

在文档的学习过程中所有遇到的问题和有必要的记录都在 Wiznote 里保存，方便进行复习balabala

最近在做毕设的过程中实在是看不下去论文了，便有了写一个有 Django 最佳实践的论坛的想法。在写 [cortexForum](https://github.com/Allianzcortex/cortexForum) 的过程中，自己尽量实现了以下几点：

* 在代码中将所用到的文档模块和对应的具体用法进行标志，方便查找

* 标注中有 SO 的部分说明它很常用，并且 stackoverflow 上有相关的问题(比如query_set() 里的 lookup field)

* 对于有多种解决方法的部分都在注释里写了出来(比如 `objects.filer().update 和 instance.save()`)

* 用 gitbook 的格式作为 wiki，对于 forum 的设计有这样一个总体的概述

---

* Django 的 models 模型里有一个 Manager 对象，非常方便实现 OOP(实现 HighLevel 而不仅仅是具体实例的行为)，以发帖的单位 Topic 为例，定义发帖的 title 和 content 之后，再定义两个外键，一个是 node,定义帖子发表的节点；一个是 author，定义帖子发表的作者。对于一个帖子来说，我希望能通过一个 node 的名称(这里可以理解为 slug )，或者一个作者的名称(username)，就能得到所有主题的信息，所以你就需要定义：

{% highlight Python %}
def get_all_topic_by_node_slug(self, node_slug):
        query = self.get_queryset().filter(node__slug=node_slug). \
            select_related('node', 'author', 'last_replied_by'). \
            order_by('-last_replied_time', '-reply_count', '-created_at')
        return query

{% endhighlight %}

通过 queryset() 的重定义，你可以用 `Node.objects.get_all_topic_by_node_slug('slug-example')` 来获取主题信息。而如果你不这样做的话，就需要在每个 views 的函数里来多次重新定义，并且一旦模型发生更改就很难再修正过来了，比 hard-coded 还复杂的重写。

而 form 里没有为我们定义更高层次的抽象，但并不妨碍我们进行 OOP，以 authen 的 registrationForm 为例，我们在 forms 里进行了 `clean_username`,`clean_mail`,重写了默认的 clean 方法，在进行 `is_valid()` 验证的时候就会直接提出错误信息。

---

在前端方面，自己完全采用 bootstrap 的架构。

关于手写 HTML 还是用 `Crispyforms/Django-bootstrap3 `，这种东西见仁见智，我觉得还是用纯粹的手写 HTML 比较好，因为这样的解决方式是前后端分离的，在下次学习其他框架的时候也能用到，你只需要传给前端需要用到的 API 就行。

比如

{% highlight HTML %}
<label for="id_{{ form.username.name }}" class="col-md-3 control-label">{{ form.username.label }}</label>
                        <div class="col-md-9">
                            <input type="text" class="form-control" id="id_{{ form.username.name }}" required name="{{ form.username.name }}" autofocus>
                            <p class="help-block">请输入你的用户名</p>

```<label for="id_{{ form.username.name }}" class="col-md-3 control-label">{{ form.username.label }}</label>
                        <div class="col-md-9">
                            <input type="text" class="form-control" id="id_{{ form.username.name }}" required name="{{ form.username.name }}" autofocus>
                            <p class="help-block">请输入你的用户名</p>
{% endhighlight %}

就要比 `{ form.as_p }` 或者 `{ crispy form } `更能实现定制化，crispy-forms 的思想是在 forms 里设置 layout 和对应的 label，想要更新前端显示需要在后端修改代码而不是 CSS 文件……

---

Mysql 问题还是挺多的。一开始的情况下，英文发帖是正常的。之后按照 [mysql-utf-8](hthttps://blog.ionelmc.ro/2014/12/28/terrible-choices-mysql/tps://blog.ionelmc.ro/2014/12/28/terrible-choices-mysql/) 里的方法采用 utf-8 编码之后就会发生只有管理员可以正常发帖，而其他用户在发帖时会提醒 second column not exists ,SO 上的解决方法都没有效果，最后分析下觉得有可能是因为 user 和 forumUser 对应的 id 不对其造成的，所以手动添加一个 request.User 后解决问题。

下次还是用 PG 吧……为什么第一次用 onetooneField 的时候就没有这种错误？要用 abstractUser 去扩展 User 模型去……

---
