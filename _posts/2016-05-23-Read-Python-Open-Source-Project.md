---
title: Different Open Source Projects I Read
date: 2016-05-23 15:01:33
categories: Python
tags: [Python,OpenSource]
---

To write `fluent/elegant/idiomatic` code
<!-- more -->

[这篇文章对应的中文版](/../translation/2016-05-23-Read-Python-Open-Source-Project.html)

#### Prologue

The benefits of reading open source projects have been demonstrated by many people. Whether it is to increase the understanding of tools used in daily development, or to learn to divide the project structure and improve the quality of the code better, reading open source projects is essential.

There are some interesting findings during the progress.Take the famous [requests](https://github.com/requests/requests) which gained over 3.5K stars as an example. There is a file (core.py) in the first version v0.2.3 listed on github that used tab as a whitespace,it certainly doesn't satisfy the requirements of PEP8 (:D

---

#### What is Pythonic Code


Pythonic 代码，就是能够把代码逻辑 Pythonic 地实现，试着进行一些小的总结：

1. OOP,考虑代码复用和扩展，很多都是可以用一个基本类/ABC 来提供接口，其他子类自定义实现方法不要想着写一个大而全的类实现所有功能。

2. 自定义 BaseException，如 `class ProjectBasedException(Exception)`,然后用各种继承共有异常类的代码来处理具体异常，从而能够更有针对性地报出提示信息

3. 在 utils 里定义一些小的和公用的函数，将复用的代码抽象成 @decorators；在 settings 里定义会被使用的配置文件，如 url 等，避免硬编码（hard-coded）

4. 防御性编码（defensive programming），虽然可以用 _prefix 来做到某种程度的定义 private 属性，但对 API 传入的参数必须要做类型检测。用合理的数据结构或者其他工具（redis/celery）来限制资源的使用。发现这个时候正向逻辑的代码在整个代码的占比中会大幅下降)

5. meta-programming 实现 `User-defined behaviour` 行为。实际上所有优秀的 Python 代码都有这一部分

6. `docstring` 的标准注释以及自己编写单测，`logging` 保留日志

7. 在完成以上的基础上，一些细节，像用 `''.join[]` 来取代字符串拼接，用 `list-comprehension` 来取代循环等

---

#### 阅读列表集合

并不是所有的 Github 上高 star 项目都具有借鉴性，比如说某个 `1000+ star` 的项目的代码风格并不好，有大量的代码不符合 `DRY(Don't Repeat Yourself)` 的原则。还有许多项目直接 Hack 了 Python 本身，看到那么多以 __ 开头的变量和函数，很难理清背后的逻辑到底是什么（说的就是 Django.......）最后主要看了以下的一些代码：

---

##### @lepture 所写的 [june](https://github.com/pythoncn/june)

虽然项目在描述上已经被废弃（deprecated），但还是可以顺利运行。一个论坛项目，包含了常见的 Node/Topic/Reply 三级主题。

a. 对 OOP 贯彻的非常彻底，以下为例：

{% highlight Python %}
# 在 models 模型里定义了保存的方法
class Topic(db.Model):
    #...
    def save(self,user=None,node=None):
        if self.id:
            db.session.add(self)
            db.session.commit()
            return self

# 在 forms 表单里调用了 models 里的保存方法
class TopicForm(BaseForm):
    #...
    topic = Topic(**self.data)
    return Topic.save(user=user,node=node)

# 在 views 视图里调用了 forms 里的方法
@bp.route('/create/<int:id>',methods=['GET','POST'])
@require_user
def create(url_name):
    #...
    form = TopicForm()
    if form.validate_on_submit():
        topic = form.save(g.user,node)
        return redirect(url_for('.view',uid=topic.id))
    return render_template('topic/create.html', node=node, form=form)

# 这样就避免了在 views 里调用模型和 db.session.add(topic) 的麻烦
{% endhighlight %}

b. 在上面看到了有一个装饰器 `@require_user`,这是对用户进行的权限管理。实际上试着想一下，一名用户可能会有多个角色，如果对这些角色每个都定义一个装饰器，就会有太多的重复了。在这种情况下我们来看看作者是怎么做的：

{% highlight Python %}
# 定义了一个基本类

class require_role(object):
    roles = {
        'spam': 0,
        'new': 1,
        'user': 2,
        'staff': 3,
        'admin': 4,
    }

    def __init__(self, role):
        self.role = role

    def __call__(self, method):
        @functools.wraps(method)
        def wrapper(*args, **kwargs):
            if not g.user:
                url = url_for('account.signin')
                if '?' not in url:
                    url += '?next=' + request.url
                return redirect(url)
            if self.role is None:
                return method(*args, **kwargs)
            if g.user.id == 1:
                # this is superuser, have no limitation
                return method(*args, **kwargs)
            if g.user.role == 'new':
                flash(_('Please verify your email'), 'warn')
                return redirect(url_for('account.setting'))
            if g.user.role == 'spam':
                flash(_('You are a spammer'), 'error')
                return redirect('/')
            if self.roles[g.user.role] < self.roles[self.role]:
                return abort(403)
            return method(*args, **kwargs)
        return wrapper

# 之后定义不同的权限限制

require_login = require_role(None)
require_user = require_role('user')
require_staff = require_role('staff')
require_admin = require_role('admin')
{% endhighlight %}

---

##### @7sDream(七秒不觉梦) 所写的 [zhihu-oauth](https://github.com/7sDream/zhihu-oauth)

第二个项目是 @7sDream(七秒不觉梦) 所写的 [zhihu-oauth](https://github.com/7sDream/zhihu-oauth)。整体结构非常漂亮，meta-programming 也做的非常好。特别是考虑到作者和我是同龄人，真的是厉害厉害。顺便提了两个 PR:[pull-27](https://github.com/7sDream/zhihu-oauth/pull/27) 和 [pull-28](https://github.com/7sDream/zhihu-oauth/pull/28) ~

整体项目是这样的，作者逆解析了知乎的安卓客户端，将其中的 oauth 接口进行了封装，不同于其他的利用模拟登陆和 BeautifuoSoup 解析网页内容的库，zhihu-oauth 能提供更加稳定的接口，也更不容易被封 ip ⊙﹏⊙b

整个项目分为三部分：`oauth` 进行验证，`zhcls` 进行类的描述，`client` 将两者结合起来提供登陆的接口

对 oauth 部分：

* 在 im_android.py 中定义了 imZhihuAndroidClient 类，继承了 requests.authbase 。在 `__init__` 中定义了 api_version/app_version/zpp_za/ua 等在构建参数时会用到的方法。同时用 self._api_version=api_version or API_VERSION(来自 setting.py) 的方法来允许用户自定义一些参数。之后的 `__call__(self,r)` 则是 authbase 的机制，会在 requests 时自动调用。

* 在 before_login_auth.py 中则定义了 BeforeLoginAuth 类，继承了上面的 imZhihuAndroidClient 类，在 imZhihuAndroidClient 的基础上增加了 client_id,用 self._client_id=client_id 来进行登陆之前的基础验证。而 `__call__` 的实现如下：

{% highlight Python %}
def __call__(self,r):
    r = super(BeforeLoginAuth,self).__call__()
    r.headers['Authorization'] = 'oauth{0}'.format(str(self._client_id))
    return r
{% endhighlight %}

* 在 setting.py 中则定义了一些会用到的参数，如 ZHIHU_API_ROOT,LOGIN_URL=ZHIHU_API_ROOT+'/signin',全部用大写

* 在 token.py 中则定义了 ZhihuToken 类，访问知乎后所产生的 token。所以很显然根据 OOP 的思想，可以做如下工作：
在 `__init__` 中定义了 self._cretate_at=time.time(),self._expires_in=expires_in 初始化工具，同时还提供了这些：

{% highlight Python %}
class ZhihuToken:

    @staticmethod
    def from_dict(json_dict):
        try:
            return ZhihuToken(**json_dict)
        except TypeError:
            raise ValueError('{} is not a valid zhihu token json'.format(json_dict))

    @staticmethod
    def from_str(json_str):
        try:
            return ZhihuToken.from_dict(json.loads(json_str))
        except TypeError:
            raise ValueError('{} is not a valid zhihu token str'.format(json_str))

    @staticmethod
    def from_file(filename):
        with open(filename,'rb') as f:
            return pickle.load(f) # 本地持久化存储

    def save(self,filename):
        """
        将 token 保存为文件
        """
        with open(filename,'wb') as f:
            pickle.dump(self,f)

    @property
    def user_id(self):
        return self._user_id

{% endhighlight %}

* 在 utils.py 中则定义了 `login_signature(data,secret)` 函数，为经过签名后的 dict 添加了 timestamp 和 signature 两项（这就是业务相关了，将签名和主体的验证函数分开）

* 在 zhihu_oauth.py 中定义了 ZhihuOAuth,相比于 BeforeLoginAuth,这个类同样继承了 imZhihuAndroidClient,所不同的是增加了发送 token 的功能，参见：

{% highlight Python %}
def __call__(self,r):
    r = super(ZhihuOAuth,self).__call__(r)
    r.headers['Authorization'] = '{type} {token}'.format(
        type = str(self._token.type.capitialize()), # self._token 是在 __init__ 里定义的
        token = str(self._token.type) # self._token.type 就再次看到了 OOP 的存在
        )
    return r
{% endhighlight %}

下面进行 zhcls 的分析，在分析之前先看一下 exception.py 的实现。正如前面所说，exception 应该提供一个整个项目的错误。

```
try:
    from json import JSONDecodeError as MyJSONDecodeError
except ImportError:
    MyJSONDecodeError = Exception

# 对 py3 用 JSONDecodeError,而用 py2 每次都用纯 exception 来处理 JSON 格式解析错误也
# 太不 Pythonic 了

```
在实现的各种异常里最有通用性的还是 UnexpectedResponseException:

```
class UnexpectedResponseException(Exception):
    def __init__(self,url,res):
        """
        此处做了适当演绎
        对于所有 JSON 没有符合预期的错误，都可以用该异常来处理
        """
        self.url = url
        self.res = res

    def __repr__(self):
        return "when visit {self.url},get an unexpected response {self.res.text}".
            format(self=self)

    __str__ = __repr__

```

在 zhcls 中，Base.py 定义了基本类，从而可以被各种类来继承：

```
class Base(object):
    def __init__(self,zhihu_obj_id,cache,session):
        """
        Base 中的 cache 类表示已知的属性值，一般由另一个对象的 JSON 数据中的一个属性充当

         比如 :any:`Answer.author` 方法，由于在请求 :any:`Answer` 的数据时，
         原始 JSON 数据中就有关于作者的一些简单信息。比如 name，id，headline。
         在使用此方法时就会将这些不完整的数据传递到 ``answer`` 对象 （类型为
         :any:`People`）的 ``cache`` 中。这样一来，在执行
         ``answer.author.name`` 时，取出名字的操作可以省去一次网络请求。

         在使用 @normal_attr,@other_obj,@streaming 时都会优先使用 cache 中的数据，在获取失败时
         才会调用 _get_data 方法请求数据

         // 这里的 cache 还是挺复杂的,相比之下 session 还是好理解的～
        """
        self._id = zhihu_obj_id
        self._cache = cache
        self._session = session

    def _get_data(self):
        """
        它需要用到 4 个方法，都是类里面的
        """
        if self._data is None:
            url = self._build_url()
            res = self._session.request(
                method = self._method(),
                url = url,
                params = self._build_params,
                data = self._build_data())
            e=GetDataErrorException(
                url,res,'valid zhihu {0} JSON data'.format(self.__class__.__name__))
            try:
                json_dict = res.json()
                if 'error' in json_dict:
                    raise e
                self._data = json_dict
            except JSONDecodedError:
                raise e

    @abc.abstractmethod
    def _build_url(self):
        """
        子类必须重载这一方法
        """
        return ''

        def _build_params(self):
            return None

        def _build_data(self):
            return None

        def _method(self):
            return 'GET'

```

* 对于很多像同一问题下的答案，answers，需要用 generator.py 来定义并生成了一系列的生成器

```
class BaseGenerator(object):
    def __init__(self,url,session):
        self._url = url
        self._session = session
        self._index = 0
        self._data = []
        self._up = 0
        self._next_url = self._url
        self._need_sleep = 0.5
        self._extra_params = {}

    def _fetch_more(self):
        # 这一部分是关于具体的实现，就不多写了
        # 大概就是说要设置一个 wait_time 如果不大于 MAX_WAITTIME 就

    @abc.abstractmethod
    def _build_obj(self,data):
        """
        进行构造对象
        """
        return None

    def __getitem__(self,item):
        """ 对　范围进行迭代 """
        if not isinstance(item,int):
            raise TypeError('{0} must be int'.format(item))

        while item>=self._up:
            if self._next_url is nont None:
                self._fetch_more() # 在 fetch_more 的过程中会使得 self._up 增加
            else:
                raise IndexError('Index out of range')
        # 写代码的时候先写下面的，再写上面的，对异常处理
        return self._build_obj(self._data[item])

    def __iter__(self):
        return self # 默认进行迭代的方式，可以直接用 yield 直接生成

    def __next__(self):
        """ 提供迭代方式访问数据，for xx in obj.xxxs　
        用 self._index 来存储下一次迭代的下标"""
        try:
            obj=self._data[self._index] # 突然意识到它和 obj=self[self._index]
            # 效果是一样的，可以可以，非常 Pythonic
        except IndexError:
            self._idnex=0
            raise StopIteration # 学以致用
        self._index+=1
        return obj

    next=__next__ # 适配 Py2 和 Py3
```

下面以生成答案 AnswerGenerator 为例：

```
class AnswerGenerator(BaseGenerator):
    def __init__(self,url,session):
        super(AnswerGenerator,self).__init__(url,session)
    def _build_obj(self):
        from .answer imoprt Answer # 避免循环引用还有其他
        return Answer(data['id'],data,self._session) # 哪来的 data。。。这个变量是怎么来的
```

下面就是一个装饰器，用来循环生成列表：

```

def generator_of(url_pattern, class_name=None):
    def wrappers_wrapper(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            cls_name = class_name or func.__name__

            if cls_name.endswith('s'):
                cls_name = cls_name[:-1]
            cls_name = cls_name.capitalize()

            gen_cls_name = cls_name + 'Generator'
            try:
                gen_cls = getattr(sys.modules[__name__], gen_cls_name)
            except AttributeError:
                return func(*args, **kwargs)

            self._get_data()

            return gen_cls(url_pattern.format(self.id), self._session)

        return wrapper

    return wrappers_wrapper
```

还用到了一个装饰器是 normal_attr,直接从 data 中提取属性并返回：

```
def normal_attr(name_in_json=None):
    """
    标志这个属性为常规属性，自动从对象的数据中提取对应属性返回
    """
    def wrappers(func):
        @functools.wraps(func)
        def wrapped_func(self,*args,**kwargs):
            def use_data_or_func(name,data):
                if can_get_from(the_name,data):
                    return data[name]
                else:
                    return func(*args,**kwargs)
            name=name_in_json if name_in_json else func.__name__ 
            if self._data:
                return use_data_or_func(name,self._data)
            elif self._cache and can_get_from(name,self._cache):
                return self._cache[name]
            else:
                # 对于 id ,需要特殊对待
                if name=='id':
                    return func(self,*args,**kwargs)
                self._get_data() # 来取得数据

                if self._data:
                    return use_data_or_func(name,self._data)

        return wrapped_func

    return wrappers

```

* 关于 StreamingJSON 数据这里就不详细写了


Java Version

Update：最近又遇到了这个问题。具体的原因就是最近在处理的程序用了一个自建的 redis pool。
它在 getInstance() 方法这里用了 synchronized 关键字来加锁。

但我们看一下 redis 是怎么实现这一点的。它继承了 Apache.commons.pool ，里面调用了
`super.getResource()` 方法，而它又调用了 pool 里面的 `borrowObject` 方法。
在 `borrowObject` 方法里，它已经实现了对多线程的考虑：

long starttime = System.currentTimeMillis();
Latch<T> latch = new Latch<T>();
byte whenExhaustedAction;
long maxWait;
synchronized (this) {
            // Get local copy of current config. Can't sync when used // later as it can result in a deadlock. Has the added // advantage that config is consistent for entire execution
whenExhaustedAction = _whenExhaustedAction;
maxWait = _maxWait;

// activate & validate the object
try {
    _factory.activateObject(latch.getPair().value);
    if(_testOnBorrow &&
            !_factory.validateObject(latch.getPair().value)) {
        throw new Exception("ValidateObject failed");
    }
    synchronized(this) {
        _numInternalProcessing--;
        _numActive++;
    }
    return latch.getPair().value;
}
catch (Throwable e) {
}