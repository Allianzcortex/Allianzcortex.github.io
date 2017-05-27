---
layout: post
title: DP 解题思路
date: 2015-03-11 13:22:10
categories: DP
tags: [DP,Algorithm,Leetcode]
comments: true
---
动态规划例题及 Leetcode 题解
<!-- more -->

#### 关于 DP

* 动态规划是一门非常重要的算法，对它的掌握应该是计算机科学专业学生的基本功

* 下面来把对这类算法的理解进行尽可能多的解释

* 关键是 **状态定义** 和 **状态转移方程**

---

#### 最长递增子序列

> 给定K个整数的序列{ N1, N2, ..., NK }，其任意连续子序列可表示为{ Ni, Ni+1, ..., Nj }，其中 1 <= i <= j <= K。最大连续子序列是所有连续子序中元素和最大的一个， 例如给定序列{ -2, 11, -4, 13, -5, -2 }，其最大连续子序列为{ 11, -4, 13 }，最大和为20。


* 定义`sum[i]`为'以A[i]作为最后一个结尾的连续子序列的最大值'

* 状态转移方程为：sum[i]=max(sum[i-1]+a[i],a[i])

* 实际求解的时候则是，只要sum>0，那么加上之后的a[i]都还是有可能使max增大的；但如果sum<0，则应该立即抛弃，从0开始计算下一个

{% highlight Python %}
a = {4, 8, -12, 3, 7, 9}
n = len(a)
sum = 0
max = 0
for i in range(n):
    sum += a[i]
    if sum > max:
        max = sum
    if sum < 0:
        sum = a[i]
return sum
{% endhighlight %}

{% highlight Java %}

public int LIS(int[] arr) {
        int i, j, max = 0;
        int n = arr.length;
        int[] list = new int[n]; // 存储长度
        Arrays.fill(list, 1);
        int[] index = new int[n]; // 存储距离
        Arrays.fill(index, -1);


        for (i = 1; i < n; i++)
            for (j = 0; j < i; j++) {
                if (arr[i] > arr[j] && list[i] < list[j] + 1) {
                    list[i] = list[j] + 1;
                    index[i] = j;
                }
            }

        // 选择出最大的
        int max_index = 0;

        for (i = 0; i < n; i++)
            if (list[i] > max) {
                max = list[i];
                max_index = i;
            }


        StringBuilder builder = new StringBuilder();
        builder.insert(0, arr[max_index]);
        int next_index = index[max_index];
        while (next_index != -1) {
            builder.insert(0, arr[next_index] + " ");
            next_index = index[next_index];
        }
        System.out.println(builder.toString()); // 输出子序列
        return max;
{% endhighlight %}

---

#### 数塔问题
![img](/images/hdu-2084.jpg)

> 要求从顶层到底层，每一层只能走到相邻节点，求经过的数字之和是多少

* 定义状态方程：max[i,j] 表示以 [i,j] 作为起始点，所经过的最大的数字之和。则 max[1,1] 是我们要求的目标

* 定义状态转移方程：max[i,j]=num[i,j]+max(max(i+1,j),max(i+1,j+1))

* 接下来可以自底向上，也可以自顶向下，具体参见之前所写的关于[hdu2084](http://acm.hdu.edu.cn/showproblem.php?pid=2084)的[博文](http://blog.csdn.net/allianzcortex/article/details/41620503)

{% highlight C %}
#include<iostream>  
#include<cstring>  
using namespace std;  
#define maxnum 1000  
int num[maxnum][maxnum];  
int d[maxnum][maxnum];  
int main(void)  
{  
    int i,j,k;  
    int n,m;  
    cin>>n;  
    while(n--){  
        cin>>m;  
        for(i=1;i<=m;i++)  
            for(j=1;j<=i;j++)  
            cin>>num[i][j];  
        for(j=1;j<=m;j++) d[m][j]=num[m][j];  
  
        for(i=m-1;i>=1;i--)  
            for(j=1;j<=i;j++)  
            d[i][j]=num[i][j]+max(d[i+1][j+1],d[i+1][j]);  
        cout<<d[1][1]<<endl;  
        memset(d,0,sizeof(d));  
    }  
}  
{% endhighlight %}

---

#### 背包问题

* 有著名的背包问题九讲，这里自己先写最基本的

* `有N件物品和一个容量为V的背包。第i件物品的费用是c[i]，价值是w[i]。求解将哪些物品装入背包可使价值总和最大`

* 如果单纯使用递归来求解 DP 的话有两种思路

{% highlight Java %}
public int Knapsack1(int[] value, int[] weight, int capacity, int number) {
        if (capacity <= 0 || number == 0)
            return 0;
        if (weight[number - 1] > capacity)
            return Knapsack1(value, weight, capacity, number - 1);
        else
            return max(value[number - 1] + Knapsack1(value, weight, capacity - weight[number - 1], number - 1),
                    Knapsack1(value, weight, capacity, number - 1));

    }

    public int Knapsack2(int[] value, int[] weight, int capacity, int index) {
        if (capacity <= 0 || index >= value.length)
            return 0;
        if (weight[index] > capacity)
            return Knapsack2(value, weight, capacity, index + 1);
        else
            return max(value[index] + Knapsack2(value, weight, capacity - weight[index], index + 1),
                    Knapsack2(value, weight, capacity, index + 1));
    }

        // KnapSack 问题，两种调用
        int[] value = {60, 100, 120};
        int[] weight = {10, 20, 30};
        int capacity = 50;
        int number = value.length;
        System.out.println(dp.Knapsack1(value, weight, capacity, number)); // 220
        int index = 0;
        System.out.println(dp.Knapsack2(value, weight, capacity, index));  // 220

{% endhighlight %}

---

#### Leetcode 上相关题目

##### 303 Range Sum Quwey - Immutable

* [链接](https://leetcode.com/problems/range-sum-query-immutable/)

* 大意：给出一个数组，要求返回任意两个区间范围的的值

* 思路：题目中说到`many calls to function`，所以多次遍历求解肯定会TLE；而sum[i,j]=sum[j]-sum[i-1]，所以一次遍历求出所有的sum值之后做减法就可以。注意要用全局变量

* 代码：

{% highlight C %}
// c++版
//用vector<int> 来存储状态会更好
class NumArray {
    int dp[100000];
public:
    NumArray(vector<int> &nums) {
        if (nums.empty())
            return ;
        int length=nums.size();
        memset(dp,0,sizeof(dp));
        dp[0]=nums[0];
        for(int i=1;i<length;i++)
            dp[i]=dp[i-1]+nums[i];
    }

    int sumRange(int i, int j) {
        if (i==0)
            return dp[j];
        else
            return dp[j]-dp[i-1];    
    }
};
{% endhighlight %}

python版：

{% highlight Python %}
class NumArray(object):
    def __init__(self, nums):
        
        self.dp = nums
        for i in range(1,len(nums)):
            self.dp[i] += self.dp[i-1]

    def sumRange(self, i, j):
        return self.dp[j] - (self.dp[i-1] if i > 0 else 0)
{% endhighlight %}

---

##### 70 climbStatirs

* [链接](https://leetcode.com/problems/climbing-stairs/)

* 大意：登上一个楼梯，可以走1步，可以走两步，问走到n步有几种解法

* 思路：用dp[n]来表示走到n步的方法数。对dp[n-1],只能选择走1步；对dp[n-2]，
如果选择1+1，就会和dp[n-1]有重叠，只能选择2步

* 代码：
C++版：

{% highlight C %}
class Solution {
public:
    int climbStairs(int n) {
        int dp[n]={0};
        dp[0]=0;
        dp[1]=1;
        dp[2]=2;
        for(int i=3;i<=n;i++)
            dp[i]=(dp[i-1]+dp[i-2]);
        return dp[n];
    }
};
{% endhighlight %}

python版：
{% highlight Python %}
class Solution(object):
    def __init__(self):
        self.dp={}
        
    def climbStairs(self, n):
        self.dp[1]=1
        self.dp[2]=2
        for i in range(3,n+1):
            self.dp[i]=self.dp[i-1]+self.dp[i-2]
        return self.dp[n]  
{% endhighlight %}

---

##### 64 Minimum Path Sum

* [链接](https://leetcode.com/problems/minimum-path-sum/)

* 大意：m*n的全为正数的矩阵，可以向右向下移动，求从左上到右下经过的距离之和最小值

* 思路：动态规划，用dp[i][j]表示以i,j作为最后一个方块所经过的最短步数
则 dp[i][j]=max(dp[i-1][j]+grid[i][j],dp[i][j-1]+gird[i][j]

* 代码：
C++ 版：

{% highlight C %}
class Solution {
public:
    int minPathSum(vector<vector<int>>& grid) {
        if (grid.empty()) return 0;
        int m=grid.size();
        int n=grid[0].size();
        int dp[m][n]={0};
        int i,j,k;
        dp[0][0]=grid[0][0];
        for(i=1;i<m;i++)
            dp[i][0]=(dp[i-1][0]+grid[i][0]);
        for(i=1;i<n;i++)
            dp[0][i]=(dp[0][i-1]+grid[0][i]);
        for(i=1;i<m;i++)
            for(j=1;j<n;j++)
                dp[i][j]=min(dp[i-1][j]+grid[i][j],dp[i][j-1]+grid[i][j]);
        return dp[m-1][n-1];
    }
};
{% endhighlight %}

