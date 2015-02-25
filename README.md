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

```
> ./butter

Usage: butter [-frpv]

Update IP Ranges
    -f, --fetch-ip-all               Fetch all IP ranges
        --fetch-ip-cf                Fetch IP ranges of CloudFlare
        --fetch-ip-aws               Update IP ranges of AWS
        --fetch-ip-asn               Fetch IP ranges by ASNs list
        --fetch-ip-domains           Fetch IPs by domains

Make Rules Files
    -r, --rules-all                  Update all rules files
        --rules-dns                  Update dns rules files
        --rules-router               Update router rules files

Push Rules Files to Devices and Servers
    -p, --push-all                   Push all rules files
        --push-router                Push rules to router
        --push-dns                   Push rules to dns server

Misc
    -v, --version                    Show version
```

问题反馈
--------

[报告问题](https://github.com/pragbyte/gfw-butter/issues)

欢迎 Fork && Pull Request。
