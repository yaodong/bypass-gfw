GFW BUTTER
==========

这是什么
--------

这是我们正在使用的一个免维护（接近中）的反网络封锁方案。

依赖
----

- 一个可靠的 DNS 服务器。我们使用的是运行 Dnsmasq + DNSCrypt-proxy 的 VPS。
- 一个安装了 RouterOS 系统的路由器。我们使用的是 Mikrotik RB850Gx2 ROS 和 MikroTik RB951G-2HnD。

如何使用
--------

### 1. 创建一个 Dnsmasq 实例

配置 `/etc/dnsmasq.conf`，让上游 DNS 使用国内 DNS 并且添加一个配置目录。可以参考[我们在用的版本](https://gist.github.com/pragbyte/cf499ad301b78689d256)。

然后将 `dnsmasq` 目录下的文件放入 `/etc/dnsmasq.d/` 下（或者你自定义的目录）。

重启 Dnsmasq。

### 2. 在 RouterOS 上设置 VPN

我们使用的是 PPTP VPN，所以 Gateway 名字会自动设置为 `pptp-out1`。如果你使用其他类型的 VPN，那么需要再下一步设置时候修改配置文件。

### 3. 导入配置文件到 RouterOS

上传 `router/router.txt` 到路由器上。然后在路由器的 terminal 上执行 `import file-name=router.txt`。

执行时间在网络良好的情况下大概需要五分钟。

下一步
------

- [ ] Dnsmasq 更新免维护
- [ ] RouterOS 更新免维护


如何参与
--------

问题反馈： [Issue](https://github.com/pragbyte/gfw-butter/issues)

欢迎 Fork && Pull Request。

> 柏林墙是被推倒的，而不是翻过去的。希望有一天我们不再只研究如何翻。
