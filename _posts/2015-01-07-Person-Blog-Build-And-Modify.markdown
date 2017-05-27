---
layout: post
title: 如何利用 Jekyll 来搭建个人博客
date: 2015-01-07 13:12:57
categories: Blog
comments: true
---
利用 Jekyll 来搭建个人博客

<!-- more -->

### 博客现状

博客最早是由 `Jekyll` 搭建的，中间更换过两个主题—>之后换成 `Octopress`，但对中文字体的渲染支持不是特别良好->再之后更换为 `hexo`，主题也变成 `Next`—>最后又回到 `Jekyll`，更换成了 `WhiteGlass` 主题。这种粗墨渲染式的风格非常有感觉，应该不会再更换主题风格了：- D


### 搭建过程
这里以[官方教程](https://pages.github.com/) 为例进行说明。

1. 首先需要有一个github的账号并创建一个名为 username.github.io 的 repository 。其中 username 就是你注册github使用的名称，进行替换即可。

2. 其次将该仓库 clone 至本地。github-pages 将每一个页面的初始配置文件都默认命名为为 index.html。所以创建一个名为index.html的文件。里面的文件随意填写，内容就是你首页的内容。并同步到终端。

3. 这时就能在网页：**username.github.io** 上看到你所想看到的页面了。

---

但一个静态页面肯定无法满足我们的需求。还好，我们有Jekyll来搭建更为丰富、更加可定制化的网站。请参见
[blogging with jekyll](https://help.github.com/articles/using-jekyll-with-pages/)

* 因为之后自己又安装了Windows平台下的jekyll，根据 [jekyll-windows](http://jekyll-windows.juthilo.com/5-running-jekyll/)来一步步实现就可以(简而言之就是 jekyll 官方文档推荐了一个非官方的 windows 实现......)

* 根据自己踩坑的过程，新的 jekyll 和 ruby gem 刚好差了一层依赖关系。换句话说想要部署新版的 github-pages，就必须用 ruby 2.x 版本，即不能用 `sudo apt-get install ruby` 的方式来安装，而是推荐从官方下载源代码后用 `./configure && make && sudo make install` 三部曲来编译。

* 首先需要安装Ruby.OSx下已默认安装好

* 安装bundler来进行包管理。`gem install bundler`

* 接下来根据github官方教程是安装gem，使用

  `source 'https://rubygems.org'`

   `gem 'github-pages'`

  来安装。但大部分情况下只会发生连接超时或者下载不下来的情况。所以请先

  `gem sources --remove https://rubygems.org/` 

  移除默认的选项。

*  这时候输入`jekyll server` 会显示网页地址
   >http://127.0.0.1:4000

   在浏览器中打开，就能看到在本地生成的默认网页。

---

下面是关于网页的配置情况。这里我希望能够将整个jekyll的网页结构讲清楚，方便大家进行fork和修改

首先是查看[jekyll文档](http://jekyllrb.com/docs/home/)

jekyll的结构图如下：

![结构图](http://7xk19m.com1.z0.glb.clouddn.com/屏幕快照 2015-06-30 下午8.51.56.png)

这里先不要急着往下看，一个一个来讲解它的作用。

* 首先是**_config.yml**，它定义了你的博客整体所需要的构件。包括：博客名称、是否采用markdown语法、是否需要评论。它的注释将它的每一项作用表达的很清楚。

* **_includes**,多数情况下我们不需要处理它。

* 其次是**layouts**，它定义了你文章的表现形式。**default.html**是定义了首页的内容，你看，如果你想要在首页栏上添加一个新的标题，只需插入如下语句：

  ` <li{% if page.url == '/Y_o_m/' %} class="active"{% endif %}><a href="{{site.baseurl}}/Y_o_m/">Y_o_m</a></li>`

  以后在每一个打开的页面上都可以看见你的最上方黑色一栏里多出了**Y_o_m**。

  而还有两个分别是**post.html**,**page.html**。OK，打开后会看到它们都是以**default.html**作为模板。在我的博客里这两个.html的区别就是**page.html**多了一个评论功能。

  比如说我的Y_o_m主题的index.html文件我只希望它显示文件列表，所以就用post.html;而我想要2015-06文章里提供评论功能，就用page.html；

  可以在每篇文站里的**layout**里配置

* **_posts**.它的作用就是存放你每次写的文章.注意名称必须为**YEAR-MONTH-DAY-title.md**.
  并且在文件里必须用`---`+`---`来确定date、title、layout。并且为方便分类，categories也是常备的。

* **_sites**,很多时候你会发现它是最复杂的。因为你所有最后用到的.html、.png都出现在里面。不过~，我们不用管它。就交给jekyll来做吧。

好了，相信有了上面的一些东西，就可以做出最基本的一个博客了。

---

最后再补充说明一些东西：

[variables](http://jekyllrb.com/docs/variables/)是我们要做出优美的jekyll博客必不可少的元素。具体内容可以看w3cschool的教程。

说一些值得注意的因素吧：

* 在设置paginator的时候要注意设置路径,

  `paginate_path: "blog/page:num"`

* 呃，不知道应该怎么说，jekyll发展到现在竟然还不支持在categories下生成页码。
 
  所以就只好展开所有的categories:

  ` for post in site.categories.book `

  当然，这取决于你准备怎样设置你的博客类型。我喜欢横向一目了然，但纵向的抽屉型也很漂亮。

  祝开心。

---

关于一些配置修改


这篇文章主要的目的是记录自己在修改jekyll博客主题过程的整体思路。如果大家有需要类似的 theme 的话，也可以以此来作为参考。

---

* **博客思路**：

    在default模板里顶部采用 **留白+图片+导航栏** 的模式，具体板式采用最常见的两列式：左列作为文章内容，右列分配Archives/Categories/Tags。其中在主页只推送和技术有关的文章，用 `for post in site.tags.tech` 来实现，其他放在导航栏的其他栏目里分别展示

* **导航栏实现**：
    
    导航栏默认采用 bootstrap 的 navbar-inverse 样式，每个导航栏目都有对应的同名文件夹，在文件夹里对应有index.html，显示打开后的网页。根据需要选择page/post模板，以及显示的文章列表是简略型/详细型。其中About里要显示的是纯粹的静态网页，所以选择的文件为index.md。

* **侧边栏实现**：

    * Archives显示了在不同时间创建的文章，用 captue 提取出对应的日期后根据年份/月份来生成目录。

    * Categories显示了在不同目录下创建的文章。用
    `for post in site.categories.CATEGORIES` 来生成文章列表，之后为每个链接创建不同的id，在idnex.html(主页面)里进行对应的链接。Categories是用列表实现的，jekyll对树形表支持的不是太好。同时考虑对某些 categories 增加对应的  `<span class="badge">` 来显文章数量。但现在为止之只能手动进行添加。

    * tags显示在不同标签下对应的文章。遍历所有标签从而生成index页面。如果一篇文章有多个标签的话，将它加入第一个标签所在的列表

---

* **如何修改：**

    * 用F12在chrome中打开控制栏后，可以看到该页面所对应的所有板式。但直接修改在 _site 里的html文件是不可行的，jekyll会重新直接生成。可以在_layout和_include文件夹里进行修改。

    * 要修改对应的版式，可以修改 page 和 post 里的栅格版式。bootstrap所采取的这种样式非常便于修改:比如我们可以看到我们是在用:`<div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1 ">`来定义page页面的主体内容，用 `<div class=" col-lg-8 col-lg-offset-1 col-md-8 col-md-offset-1 col-sm-12 col-xs-12 post-container">`来定义右侧导航栏。只需要修改对应列的大小和偏移量，就可以修改版式。

    * 但导航栏我并没有采用 `collapse` 的响应式布局，因为直接用 col-sm 来配置在移动端的响应更好。

    * 但非常奇怪的一点是我所自定义的 css 没有覆盖 bootstrap.min.css,但到目前为止也没有找到问题所在。因为并不是专业的前端工程师，所以就直接用修改 bootstrap.min.css 这样非常 tricky 的方式来解决。

    * 要修改文章字体大小的话，如果不了解前端的编译及压缩，可以直接在 `css/bootstrap.min.css` 里修改 `font-size` 所对应的值，原值为 15px。

    * 字体选择我优先选用的是微软雅黑

---

* **其他配置：**

    * 采用多说评论，在 Board 和每篇文章列表里进行加载。

    * 一部分文章图片存储在 img 里，另一部分存储在 **七牛云存储** 里，用外链加载。

---


