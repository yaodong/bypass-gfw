GFW BUTTER
==========

这是什么
--------

这是我们正在使用的一个反网络封锁方案。

依赖
----

- 一个可靠的 DNS 服务器。我们使用的是运行 Dnsmasq 和 DNSCrypt-proxy。
- 一个安装了 RouterOS 系统的路由器。我们使用的是 Mikrotik RB850Gx2 ROS / MikroTik RB951G-2HnD。

如何使用
--------

1. 更新 IP 地址
```
./butter -i
```

2. 生成配置文件
```
./butter -g
```

问题反馈
--------

[报告问题](https://github.com/pragbyte/gfw-butter/issues)

欢迎 Fork && Pull Request。
