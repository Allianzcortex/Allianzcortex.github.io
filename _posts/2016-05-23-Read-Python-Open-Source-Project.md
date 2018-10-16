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

Pythonic code is to implement code in a pythonic way.Having a summary:

1. `OOP` considers code reuse and extension. Many can use a basic class / ABC to provide an interface, other sub-class inherit from it just needs to implement the necessary function.

2. Customize BaseException, such as `class ProjectBasedException(Exception)`, and then use the code of the various inheritance exception classes to handle the specific exception, so that the prompt information can be reported more specifically.

3. Define some small and common functions in utils, abstract the multiplexed code into @decorators; define the configuration files that will be used in settings, such as url, to avoid hard-coded.

4. Defensive programming. Although _prefix can be used to define the private attribute to some extent, the parameters passed to the API must be type tested. Use a reasonable data structure or other tools (redis/celery) to limit the use of resources.

5. meta-programming implements the `User-defined behaviour`.

6. Standard comments for `docstring` and writing unit tests, logging important actions to files.

7. On the basis of the above, some details, like replacing the string splicing with `''.join[]`, replacing the loop with `list-comprehension` also should be noticed.

---

### Projects List

Not all high-star projects on Github are useful. For example, the code style of a `1000+ star` project is not good, and a lot of code does not meet the principle of `DRY(Don't Repeat Yourself)` . There are still many projects that directly hack Python itself(so many variables and functions begin with `__`, it's hard to understand what the logic behind it is) 

---

##### [june](https://github.com/pythoncn/june)

Although the project has been deprecated in the description, it can still run smoothly. A forum project that includes the `Node/Topic/Reply`.

a. The implementation of OOP is very thorough, the following is an example:

{% highlight Python %}
# Define saving method in Topic model
class Topic(db.Model):
    #...
    def save(self,user=None,node=None):
        if self.id:
            db.session.add(self)
            db.session.commit()
            return self

# Form uses save method of Topic Model
class TopicForm(BaseForm):
    #...
    topic = Topic(**self.data)
    return Topic.save(user=user,node=node)

# Views uses method of Form
@bp.route('/create/<int:id>',methods=['GET','POST'])
@require_user
def create(url_name):
    #...
    form = TopicForm()
    if form.validate_on_submit():
        topic = form.save(g.user,node)
        return redirect(url_for('.view',uid=topic.id))
    return render_template('topic/create.html', node=node, form=form)

# So avoiding the hassle of calling the model and db.session.add(topic) in views.
{% endhighlight %}

---

b.  there is a decorator `@require_user`, which is the permission management for the user. A user may have multiple roles. If you define a decorator for each of these roles, there will be too many repetitions. In this case let's see what the author did:

{% highlight Python %}
# Define a base class

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

# Then define different permission limits for different roles

require_login = require_role(None)
require_user = require_role('user')
require_staff = require_role('staff')
require_admin = require_role('admin')
{% endhighlight %}

---

##### [zhihu-oauth](https://github.com/7sDream/zhihu-oauth) by @7sDream

The second project is [zhihu-oauth](https://github.com/7sDream/zhihu-oauth) written by @7sDream. The overall structure is very beautiful, and the meta-programming is also very good. Especially considering that the author and I are peers, it is especially amazing. BTW, I also provide two PRs: 
[pull-27](https://github.com/7sDream/zhihu-oauth/pull/27) and 
[pull-28](https://github.com/7sDream/zhihu- Oauth/pull/28)

The author reversely parses the zhihu Android client and encapsulates the oauth interface. Unlike other libraries that use simulated login and Beautifuoup to parse web content, zhihu-oauth can provide a more stable API. And it is also less likely to be blocked by ip.

The whole project is divided into three parts: `oauth` for verification, `zhcls` for class description, and `client` for combining the two to provide a login API.

For `oauth`:

- The `imZhihuAndroidClient class` is defined in im_android.py, inheriting requests.authbase. The methods that are used in building parameters such as api_version/app_version/zpp_za/ua are defined in `__init__`. Also use the method self._api_version=api_version or API_VERSION (from setting.py) to allow the user to customize some parameters. The following `__call__(self,r)` is the mechanism of authbase and will be called automatically when posting a request.

- Before_login_auth.py defines the BeforeLoginAuth class, inherits the imZhihuAndroidClient class above, adds client_id to imZhihuAndroidClient, and uses self._client_id=client_id to execute validation before login. The implementation of `__call__` is as follows:

{% highlight Python %}
def __call__(self,r):
    r = super(BeforeLoginAuth,self).__call__()
    r.headers['Authorization'] = 'oauth{0}'.format(str(self._client_id))
    return r
{% endhighlight %}

- In setting.py, some parameters are used, such as `ZHIHU_API_ROOT`, `LOGIN_URL=ZHIHU_API_ROOT+'/signin'`, all in uppercase.

- In token.py, the ZhihuToken class is defined, and the token is generated after the access is known. So obviously, according to OOP's thoughts, the following job can be done:

The `self._cretate_at=time.time(), self._expires_in=expires_in` initialization tool is defined in `__init__` and these are also provided:

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
            return pickle.load(f) # pickle ,long-time storage

    def save(self,filename):
        """
        saving token to file
        """
        with open(filename,'wb') as f:
            pickle.dump(self,f)

    @property
    def user_id(self):
        return self._user_id

{% endhighlight %}

Look again at the implementation of `exception.py`. As mentioned earlier,base exception should be provided for the entire project.

{% highlight Python %}
# deal python2 and python3 respectively.
# Also you can use `if py2:import ..;else import ..`,but it's against the   
# principle of `easier to ask for forgiveness than permission`
try:
    from json import JSONDecodeError as MyJSONDecodeError
except ImportError:
    MyJSONDecodeError = Exception
{% endhighlight %}


{% highlight Python %}
class UnexpectedResponseException(Exception):
    def __init__(self,url,res):
        """
        For all situations that json cannot be decoded,this exception will be used.
        """
        self.url = url
        self.res = res

    def __repr__(self):
        return "when visit {self.url},get an unexpected response {self.res.text}".
            format(self=self)

    __str__ = __repr__

{% endhighlight %}

---

Java 代码

Based on requirements,I ever investigaed the use of `jedis` to see how it handlers multi-thread situation.

It inherits `Apache.commons.pool` and it is called
The `super.getResource()` method, which in turn calls the `borrowObject` method in the pool.In the `borrowObject` method, it has implemented the consideration of multithreading:

{% highlight Java %}
long starttime = System.currentTimeMillis();
Latch<T> latch = new Latch<T>();
byte whenExhaustedAction;
long maxWait;
synchronized (this) {
/* 
Get local copy of current config. Can't sync when used 
later as it can result in a deadlock. Has the added 
advantage that config is consistent for entire execution

*/
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
        // only one thread can execute at the moment
        _numInternalProcessing--;
        _numActive++;
    }
    return latch.getPair().value;
}
catch (Throwable e) {
}
{% endhighlight %}