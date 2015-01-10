GFW BUTTER
==========

这是什么
--------

这是我们正在使用的一个免维护（接近中）的反网络封锁方案。

依赖
----

- 一个可靠的 DNS 服务器。我们使用的是运行 Dnsmasq 的 VPS。
- 一个安装了 RouterOS 系统的路由器。我们使用的是 Mikrotik RB850Gx2 ROS 和 MikroTik RB951G-2HnD。


文件结构
--------

- `data/`，抓取的数据，主要是 IP 段。
- `dnsmasq/`，Dnsmasq 的配置文件。
- `router/`，RouterOS 的配置文件。
- `blocked.json`，被封资源列表。
- `update_data.rb`，抓取最新的数据的脚本。
- `update_dnsmasq.rb`，更新 Dnsmasq 配置文件的脚本。
- `update_router.rb`，更新 RouterOS 配置文件的脚本。

被封资源列表
------------

被封资源列表放在 `blocked.json` 中。

- `networks` 存储的是 ASN 号。
- `ip_ranges` 存储的是公开的 IP Ranges API。比 ASN 更好，所以 AWS 等是使用的此项而不是 ASN。
- `domains` 存储的是被封的域名且不包含在以上两项中。
- `resolves` 存储的是被 DSN 污染的域名。

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

如何更新
--------

### 更新数据

如果更新了被封资源列表，需要执行 `bundle exec ./update_data.rb` 来重新抓取数据。这个命令也可以用来更新数据，但是根据目前使用情况，后者很少出现。

### 更新配置文件

数据更新完毕之后，需要执行 `./update_dnsmasq.rb` 和 `./update_router.rb` 来更新配置文件。然后重新导入到 Dnsmasq 和 RouterOS 中。

下一步
------

- [ ] Dnsmasq 更新免维护
- [ ] RouterOS 更新免维护


如何参与
--------

问题反馈： [Issue](https://github.com/pragbyte/gfw-butter/issues)

欢迎 Fork && Pull Request。

> 柏林墙是被推倒的，而不是翻过去的。希望有一天我们不再只研究如何翻。
