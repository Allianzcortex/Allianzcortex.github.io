---
layout: post
title: Develop a desktop client with PyQT
date: 2015-09-14 19:46:30
categories: Python
comments: true
---

[这篇文章对应的中文版](/../translation/2015-09-14-Use-PyQt-Develop-Desktop-Web-GUI.html)

---
In this novel,I'll demonstrate how to read the database and display it , with Python's dynamic mechanism and Qt's signal slot.

<!-- more -->

This is a program that can detect network connections. The screenshot of the interface is as follows

![PyQt](/images/pyqt-example.png)

There will be very few opportunities to write the client in the future(I mean many professional clients are mainly developed by C#/.net,although actually dropbox developed its' client with PyQT)... So I won't pursue the best practices. I just need to make a **poke-marked GUI** .⊙﹏⊙b

#### UI and interface corresponding

 PyQt itself is similar to Qt's signal slot mechanism. When a button is clicked, a signal is sent and the processing mechanism of the signal needs to be defined.

 The design interface is designed directly with the **designer**. Drag `button/listview/model` and customize the name.

After generating the .ui file, use `pyuic4 –x ping_ui.ui –o ping_ui.py` to see that the ping_ui.py file contains `class Ui_Form(object)`, which has various lengths/locations defined. It's More convenient than handwriting

 Then define a `pyqt_example2.py` which contains the following files:

{% highlight Python %}
class CalculateForm(QWidget):
    def __init__(self, parent=None):
        super(CalculateForm, self).__init__(parent)

        self.ui = Ui_Form()
        self.ui.setupUi(self)

{% endhighlight %}

then define the execution function：

{% highlight Python %}
if __name__ == '__main__':
    app = QApplication(sys.argv)
    calculator = CalculateForm()
    calculator.show()
    sys.exit(app.exec_())

{% endhighlight %}

After execution, you can see that the interface has been successfully displayed.

The next step is to establish a signal slot mechanism. For example, when the button of the ui was originally defined, there is a button named `add_url` . We want to associate it with the function of `add_url` , just define it as follows (preferably in __init__ ):


{% highlight Python %}
self.ui.add_url.clicked.connect(self.add_url_func) # click function
{% endhighlight %}

#### CRUD and Display

The model defined in PyQt is `QSqlTableModel`, and the definition of table is `listview`.
For example, define the method of initialize_model() :

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