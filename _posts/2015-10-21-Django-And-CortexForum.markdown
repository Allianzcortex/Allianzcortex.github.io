---
layout: post
title: Learning Django And cortexForum
date: 2015-10-21 20:39:49
categories: Django
comments: true
tags: [Django,Python]
---
Studying Django resources and `cortexForum`
<!-- more -->

[这篇文章对应的中文版](/../translation/2015-10-21-Django-And-CortexForum.html)



##### Studying Resources

At first you can review [official tutorial](https://docs.djangoproject.com/en/2.1/intro/tutorial01/) and [tango with Django](http://www.tangowithdjango.com/book17/)

Advanced books include ：

- [《Two Scopes of Django》](https://www.twoscoopspress.com/products/two-scoops-of-django-1-11) : author is the community developer，there are many industrial best practices.

- [《Test Driven Web Development》](https://www.amazon.ca/Test-Driven-Development-Python-Selenium-JavaScript/dp/1491958707): Development Django based on **TDD(Test-Driven Development)** ，I'm impressed by the use of selenium to detect the 404 page.

---

### cortexForum

> Tell me and I forget, teach me and I may remember, involve me and I learn.

I try to write a forum program [cortexForum](https://github.com/Allianzcortex/cortexForum) to deepen my understanding,and during the progress,I try to do those aspects:

* In the code, the document module used and the corresponding specific usage are marked for easy searching.

* The section with SO in the annotation indicates that it is very common, and there are related issues on stackoverflow (such as the lookup field in query_set()).

* Parts that have multiple workarounds are written in comments (such as `objects.filer().update and instance.save()`)

* Use gitbook format as a wiki for a general overview of forum design

---

Django's models model has a Manager object, which is very convenient to implement OOP (implementing highlevel and not just the behavior of specific instances). Take the unit of Topic as an example, define the `title` and `content` of the post, and then define `two foreign keys`. One is node, which defines the node where the post is published; the other is author, which defines the author of the post. For a post, I want to be able to get information on all topics by the name of a node (which can be understood as `slug` here) or an author's name (username), so you need to define:

{% highlight Python %}
def get_all_topic_by_node_slug(self, node_slug):
        query = self.get_queryset().filter(node__slug=node_slug). \
            select_related('node', 'author', 'last_replied_by'). \
            order_by('-last_replied_time', '-reply_count', '-created_at')
        return query

{% endhighlight %}

With the redefinition of queryset() , you can get the subject information with `Node.objects.get_all_topic_by_node_slug('slug-example')`. And if you don't do this, you need to redefine it multiple times in each view's function, and once the model changes, it's hard to fix it.

The form does not define a higher level of abstraction for us, but does not prevent us from doing OOP. Take authen's registrationForm as an example. We made `clean_username`, `clean_mail` in the forms, and overridden the default clean method. When the `is_valid()` verification is performed, an error message is directly raised.

---

As for the **Front End**, I fully adopt the architecture of bootstrap.

Regarding **handwritten HTML** or `Crispyforms/Django-bootstrap3 `, this kind of thing is a matter of opinion. I think it is better to use pure handwritten HTML, because this solution is separated from the front and back, and can be used the next time you learn other frameworks. By the way, you only need to pass the API to the front end.take an example:

{% highlight HTML %}
<label for="id_{{ form.username.name }}" class="col-md-3 control-label">{{ form.username.label }}</label>
                        <div class="col-md-9">
                            <input type="text" class="form-control" id="id_{{ form.username.name }}" required name="{{ form.username.name }}" autofocus>
                            <p class="help-block">Please input your username</p>

{% endhighlight %}

It is more customizable than `{ form.as_p }` or `{ crispy form } `. The idea of crispy-forms is to set the layout and the corresponding label in the forms. To update the front-end display, you need to modify the code in the backend rather than CSS files,it is against the trendency.

---

The MySQL problem is still quite a lot. In the beginning, English posting is normal. Then following [mysql-utf-8](hthttps://blog.ionelmc.ro/2014/12/28/terrible-choices-mysql/tps://blog.ionelmc.ro/2014/12/28/terrible- The choices-mysql/) method to uses `utf-8` encoding, only the administrator can post normally, while other users will remind the second column not exists when posting.  Finally analyzes that it is possibly because the id corresponding to user and forumUser is not even, so manually add a `request.User ` and all will be fine.

Next time I will prefer to use `PostgreSql` and `nosql` to solve the problem ,and using abstractUser to expand User model.

---
