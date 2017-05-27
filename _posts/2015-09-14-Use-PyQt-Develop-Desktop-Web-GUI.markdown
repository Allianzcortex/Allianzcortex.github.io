---
layout: post
title: 使用 PyQT 来开发一个桌面客户端
date: 2015-09-14 19:46:30
categories: Python
comments: true
---
Python 的动态机制结合 Qt 的信号槽；读取数据库并展示
<!-- more -->

写了一个能检测网络连接的程序。界面截图如下：

![PyQt](/images/pyqt-example.png)

以后写客户端的机会还是挺少的...就不过多地追求最佳实践了，只需要能做出一个“能戳戳点点的 GUI ”就够了⊙﹏⊙b

#### ui 和界面对应

 PyQt 本身和 Qt 的信号槽机制是类似的。点击一个按钮后会发送出一个信号，需要定义该信号的处理机制。

 设计界面直接用 designer 来设计。拖动 button/listview/model，然后自定义名称。

 生成 .ui 文件后，用 `pyuic4 –x ping_ui.ui –o ping_ui.py` 就可以看到 ping_ui.py 文件里包含了 `class Ui_Form(object)`,里面已经定义好了各种长度/位置，比手写方便多了。

 再自定义一个 `pyqt_example2.py` ，里面包含了如下文件：

{% highlight Python %}
class CalculateForm(QWidget):
    def __init__(self, parent=None):
        super(CalculateForm, self).__init__(parent)

        self.ui = Ui_Form()
        self.ui.setupUi(self)

{% endhighlight %}

再定义执行函数：

{% highlight Python %}
if __name__ == '__main__':
    app = QApplication(sys.argv)
    calculator = CalculateForm()
    calculator.show()
    sys.exit(app.exec_())

{% endhighlight %}

执行后就可以看到界面已经成功显示。

接下来就是要建立信号槽机制，比如在当初定义 ui 的 button 时有一个 button 的名称为 add_url 。我们希望将它与 add_url 的函数对应在一起，只需定义如下（最好在 __init__ 里）：

{% highlight Python %}
self.ui.add_url.clicked.connect(self.add_url_func) # 点击函数
{% endhighlight %}

#### 数据库的增删改查以及显示

在 PyQt 中定义的　model 的是 QSqlTableModel,定义显示 table 的是　listview。
比如说定义 initialize_model() 的方法：

{% highlight Python %}
db = QtSql.QSqlDatabase.addDatabase('QSQLITE')
db.setDatabaseName('test_ping.db')

def initialize_model(model):
    model.setTable('url_ping')
    model.setEditStrategy(QtSql.QSqlTableModel.OnManualSubmit)
    model.select()
    model.setHeaderData(0, QtCore.Qt.Horizontal, u"网址") # 对应的 url 链接
{% endhighlight %}

而要进行显示，只需要将 listview 和对应的 model 连接起来:

{% highlight Python %}
def show_view(self):
    model = QSqlTableModel()
    initialize_model(model)
    self.ui.url_list.setModel(model) # self.ui.url_list 是一个 listview
    self.ui.url_list.show()
{% endhighlight %}
每次在进行增删改查之后只要调用 self.show_view() 方法，就能看到最新的数据库，等效于刷新～

##### 如何执行查询

比如要查找包含 'test'的内容：

{% highlight Python %}
query = QtSql.QSqlQuery()
query.exec_("select * from test where value like '%test%'")
{% endhighlight %}

而如果要展示，更好的方法是重新定义 QSqlQueryModel

{% highlight Python %}
sqlQueryModel.setQuery("select * from test where value like '%test%' ")
self.ui.url_list.setModel(sqlQueryModel)
self.ui.url_list.show()
{% endhighlight %}

定义弹出框：使用最简单的如下函数就可以了：

{% highlight Python %}
def show_messagebox(self):
    msg = QMessageBox()
    msg.setText(u'检测成功')
    msg.setStandardButtons(QMessageBox.Ok)
    msg.exec_()
{% endhighlight %}

#### ui 和执行线程分离

如何设置 ui 和执行任务线程分离，使得界面不会阻塞卡死：

这个有很多方法来去做，我选择的是如下方法：

{% highlight Python %}
from PyQt4.QtCore import QThread

class PingThread(QThread):
    """ 定义 PingThread """
    def __init__(self, url):
        QThread.__init__(self)
        self._url = url

    def run(self):
        ping_url(self._url)
        self.emit(SIGNAL('ping url'))
        return

""" 接下来在主线程中调用即可 """

self.pingThread = PingThread(target_url)
# self.connect(self.pingThread, SIGNAL('ping url'), self.show_messagebox) 可选
self.pingThread.start()

{% endhighlight %}

#### 进度条


PyQt 中进度条使用 QProgressBar 来展现。在 ui 中设置时会有最小值（默认为 0 ）和最大值（默认为 100 ）。
在更新时只要设置 

{% highlight Python %}
self.ui.click_progrress.setValue(30) # 进度条进展到 30% 程度
# click_progress 是 ui 里对应的 ProgressBar
{% endhighlight %}


####  其他


ping 调用的是系统自带的 ping 接口

tracert 则调用的是 windows 里的 tracert 接口（Linux 下对应的是 traceroute）

telnet 是检测端口是否打开。然后直接调用系统命令的话有两个弊端：

① Windows 需要用户手动开启配置 

② telnet 采用的是光标是否闪烁去判断端口状况，没有返回值，不方便程序处理。

所以最后采用 socket 来连接：

{% highlight Python %}
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
result = sock.connect_ex((url_name, 80))
port_open = True if result == 0 else False
{% endhighlight %}

PyQt 自带的在 site-packages 里的好多 demo 都非常好，直接要用的话看代码比文档会更快～
在学的时候写了一个增正版的计算器 demo，当输入的数字或者选择的计算符号发生变化时，会自动改变计算结果（嗯，用的就是 eval()～），用的是 Python 的 装饰器特性。