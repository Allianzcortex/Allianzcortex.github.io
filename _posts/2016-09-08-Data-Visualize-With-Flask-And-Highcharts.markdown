---
layout: post
title: 记录一次用 Flask 和 Highcharts 实现的数据可视化
date: 2016-09-08 14:30:05
comment: true
categories: 数据可视化
tags: [Flask,Highcharts,数据可视化]
---
数据可视化。后端：Flask，前端：Highcharts，可以做的更好的啊......
<!-- more -->

#### What Happened

我司采用的是阿里巴巴开源的 `zeus` ，结合脚本来进行业务系统的调度。有过一段时间突然晚上调度业务连续崩的现象(预警短信连发)，只能白天重新洗数据。经过研究发现是在某段时间内任务运行过多造成并行压力过大造成的，需要合理分布 `ods/mds/ads` 表的时间。但 zeus 系统本身没有提供查询调度任务的时间分布功能，所以需要来实现一个任务分布的可视化。

##### Flask 后端框架

虽然用 `Django` 用的多，但 `Django` 作为一个 `Full-Stack Framework` 实在太重了，里面的注册、登陆功能都不会用到。所以换为 Flask ，实时从 MySQL 中查询，将查询的结果用自带的 `jsonify` 转化后返回给前端页面。

Zeus 的调度时间格式类似 crontab，所以为了能在后端直接生成需要的数据，就决定将时间统一折合为 `int` 值。比如：

```
原始时间    对应展示
0 10 1（表示 1:10） 110
0 16 0 （表示 12:16）   16
0 30 23（表示晚上 11:30） 2330
```

在看的时候如果不满足四位，需要补全前导零来去看。

时间的核心计算如下：

{% highlight python %}
for row in cur.fetchall():
    key = row[1].split()
    if key[2]!='0' and key[1]=='0':
        key=10*int(key[2]+key[1])
    else:
        key = int(key[2] + key[1])
{% endhighlight %}

配置 post 数据

{% highlight Python %}
@app.route('/timeserialize', methods=['GET', 'POST'])
def get_json():
    # calculate some data
    return jsonify(result)
{% endhighlight %}

##### Highcharts 前端框架

在前端框架里比较出名的就是百度的 `Echarts` 和 Google 的 `HighCharts`(还有 `D3.js`，但怎么都用不到啊...)。就选择后者啦。

首先加入资源文件。

```
<script src="http://cdn.bootcss.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>
    <link rel="stylesheet" type="text/css" href="{{ url_for('static', filename='styles.css') }}">
    <!-- jquery.min.js 顺序应该在 highcharts.js 之前 -->
    <script src="{{ url_for('static', filename='jquery.min.js') }}"></script>
    <script src="{{ url_for('static', filename='highcharts.js') }}"></script>

```

之后用 `jquery` 来配置 POST 格式的 JSON 数据。

```
<script>
$(function () {
    $.getJSON('/timeserialize', function (data) {
    /*$.getJSON('/configure', function (data) {*/
        $('#container').highcharts({
            // legend,option 等数据
        });
    });
});
</script>


```

#### 第一个版本

做完第一个版本后的显示效果如下所示：

![figure-1](/images/figure-1.png)

![figure-2](/images/figure-2.png)

点的数量指代了在当前时间点运行的 job 数量。拖拽放大能看到更细的时间维度内的变化。

#### 第二个版本


第二个版本要感谢 [@吴波](https://www.zhihu.com/people/wu-bo-72-98/activities) 同学的贡献。自己当时实现的还是有些太粗糙了。实际上将得到的时间格式和具体的秒数进行字符串组合后是
可以得到任务的具体执行时间，转为 unixtime 后传给前端，再转为具体时间，可视化的效果会更好。

其中的关键就是在 `$function()` 里再添加一个对 JSON 格式处理的函数。

```
var jsonData = data;
var jsonDataSuccess = new Array();
var jsonDataFailed = new Array();
# ...
tempArray.push(parseInt(jsonData[i].startTime) + 28800000,parseInt(jsonData[i].spendTime));
# ...
```

在 `series` 里分别用两种类型来标注：

```
    series:[{
            name:'success',
            color:'rgb(119,152,191)',
            data:jsonDataSuccess,
            },{
            name:'failed',
            color:'rgb(255,0,0)',
            data:jsonDataFailed
            }
                    ]
```

在 `tooltip` 里用 formatter() 选项来返回更友好的表达式：

```
tooltip:{
    formatter: function() {
        //...
        return 'jobid :' + jobId + '<br>' + "jobName:" + jobName + '<br>'  + 'starttime :' + startTime
    }
}
```

最后得到的可视化结果如下所示：

![figure-3](/images/figure-3.png)

感觉好漂亮(捂脸)

在一开始做到时候有些太追求开发速度了...可以慢一点来让可视化效果更好:-D。同时学一下 js 的语法，有很多功能是不能用 jquery 代替的～～

