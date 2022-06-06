
# Yum Repo

```
/etc/yum.repos.d/elasticsearch.repo
```

```
[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
```

# Package installation
```sh
dnf install --enablerepo=elasticsearch elasticsearch
yum install --enablerepo=elasticsearch elasticsearch
```

# Configuration
```conf
cluster.name: "somename"
node.name: "thishost"
node.master: true
node.data: true

index.number_of_shards: 4
index.number_of_replicas: 1

path.data: /var/lib/elasticsearch
# path.logs: /path/to/logs

network.host: 0.0.0.0

# transport.tcp.port: 9300
# transport.tcp.compress: true
# http.port: 9200
# http.max_content_length: 100mb
# http.enabled: true
# http.jsonp.enable: true

discovery.zen.minimum_master_nodes: 3
# discovery.zen.ping.timeout: 5s
# discovery.zen.ping.multicast.enabled: true
discovery.zen.ping.unicast.hosts: [10.0.10.5, 10.0.10.6, 10.0.10.7]
```

# Service
```
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
```
