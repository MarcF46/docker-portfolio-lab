PS C:\Docker Übung> docker inspect dockerbung-redis-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
>> docker inspect dockerbung-prometheus-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
>> docker inspect dockerbung-grafana-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
volume | dockerbung_redis_data_prod | /var/lib/docker/volumes/dockerbung_redis_data_prod/_data | /data
bind |  | C:\Docker Übung\secrets\redis_password.txt | /run/secrets/redis_password

bind |  | C:\Docker Übung\monitoring\prometheus\prometheus.yml | /etc/prometheus/prometheus.yml
volume | dockerbung_prometheus_data | /var/lib/docker/volumes/dockerbung_prometheus_data/_data | /prometheus

bind |  | C:\Docker Übung\secrets\grafana_admin_password.txt | /run/secrets/grafana_admin_password
volume | dockerbung_grafana_data | /var/lib/docker/volumes/dockerbung_grafana_data/_data | /var/lib/grafana
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/dashboards | /var/lib/grafana/dashboards
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/provisioning/dashboards | /etc/grafana/provisioning/dashboards
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/provisioning/datasources | /etc/grafana/provisioning/datasources

PS C:\Docker Übung> docker compose -f .\compose.prod.yml config --volumes
>> docker compose -f .\compose.dev.yml config --volumes
redis_data_prod
redis_data_dev
PS C:\Docker Übung> docker compose -f .\compose.dev.yml config --volumes
redis_data_dev
PS C:\Docker Übung> docker inspect dockerbung-redis-1
[
    {
        "Id": "6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58",
        "Created": "2026-05-17T15:00:01.811478043Z",
        "Path": "docker-entrypoint.sh",
        "Args": [
            "sh",
            "-c",
            "exec redis-server --appendonly yes --requirepass \"$(cat /run/secrets/redis_password)\""
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 509,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-05-24T08:57:19.092080237Z",
            "FinishedAt": "2026-05-24T08:45:20.587909473Z",
            "Health": {
                "Status": "healthy",
                "FailingStreak": 0,
                "Log": [
                    {
                        "Start": "2026-05-24T11:40:01.297860703Z",
                        "End": "2026-05-24T11:40:01.369463416Z",
                        "ExitCode": 0,
                        "Output": "PONG\n"
                    },
                    {
                        "Start": "2026-05-24T11:40:11.369866852Z",
                        "End": "2026-05-24T11:40:11.498758481Z",
                        "ExitCode": 0,
                        "Output": "PONG\n"
                    },
                    {
                        "Start": "2026-05-24T11:40:21.497786196Z",
                        "End": "2026-05-24T11:40:21.577899558Z",
                        "ExitCode": 0,
                        "Output": "PONG\n"
                    },
                    {
                        "Start": "2026-05-24T11:40:31.578571408Z",
                        "End": "2026-05-24T11:40:31.633901796Z",
                        "ExitCode": 0,
                        "Output": "PONG\n"
                    },
                    {
                        "Start": "2026-05-24T11:40:41.631842284Z",
                        "End": "2026-05-24T11:40:41.70943895Z",
                        "ExitCode": 0,
                        "Output": "PONG\n"
                    }
                ]
            }
        },
        "Image": "sha256:c5e375abb885e6b2021c0377879e4890bf76f9065b8922ffc113f2b226b9fc17",
        "ResolvConfPath": "/var/lib/docker/containers/6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58/hostname",
        "HostsPath": "/var/lib/docker/containers/6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58/hosts",
        "LogPath": "/var/lib/docker/containers/6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58/6f3dc2194ea1001ea1c4096b9f72f8fe309d0c4c3f7a082d02280ab5452e6d58-json.log",
        "Name": "/dockerbung-redis-1",
        "RestartCount": 0,
        "Driver": "overlayfs",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": [
                "dockerbung_redis_data_prod:/data:rw"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "dockerbung_default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "unless-stopped",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": [],
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "Mounts": [
                {
                    "Type": "bind",
                    "Source": "C:\\Docker Übung\\secrets\\redis_password.txt",
                    "Target": "/run/secrets/redis_password",
                    "ReadOnly": true,
                    "BindOptions": {}
                }
            ],
            "MaskedPaths": [
                "/proc/acpi",
                "/proc/asound",
                "/proc/interrupts",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/sys/devices/virtual/powercap",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "Storage": {
            "RootFS": {
                "Snapshot": {
                    "Name": "overlayfs"
                }
            }
        },
        "Mounts": [
            {
                "Type": "volume",
                "Name": "dockerbung_redis_data_prod",
                "Source": "/var/lib/docker/volumes/dockerbung_redis_data_prod/_data",
                "Destination": "/data",
                "Driver": "local",
                "Mode": "rw",
                "RW": true,
                "Propagation": ""
            },
            {
                "Type": "bind",
                "Source": "C:\\Docker Übung\\secrets\\redis_password.txt",
                "Destination": "/run/secrets/redis_password",
                "Mode": "",
                "RW": false,
                "Propagation": "rprivate"
            }
        ],
        "Config": {
            "Hostname": "6f3dc2194ea1",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "ExposedPorts": {
                "6379/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "sh",
                "-c",
                "exec redis-server --appendonly yes --requirepass \"$(cat /run/secrets/redis_password)\""
            ],
            "Healthcheck": {
                "Test": [
                    "CMD-SHELL",
                    "REDISCLI_AUTH=\"$(cat /run/secrets/redis_password)\" redis-cli ping"
                ],
                "Interval": 10000000000,
                "Timeout": 3000000000,
                "StartPeriod": 10000000000,
                "Retries": 5
            },
            "Image": "redis:alpine",
            "Volumes": null,
            "WorkingDir": "/data",
            "Entrypoint": [
                "docker-entrypoint.sh"
            ],
            "Labels": {
                "com.docker.compose.config-hash": "974ea8109f574bad226e0fd4a99699a2f2d4c0a8abb31a37c3bbae99f8e87cbc",
                "com.docker.compose.container-number": "1",
                "com.docker.compose.depends_on": "",
                "com.docker.compose.image": "sha256:c5e375abb885e6b2021c0377879e4890bf76f9065b8922ffc113f2b226b9fc17",
                "com.docker.compose.oneoff": "False",
                "com.docker.compose.project": "dockerbung",
                "com.docker.compose.project.config_files": "C:\\Docker Übung\\compose.prod.yml",
                "com.docker.compose.project.working_dir": "C:\\Docker Übung",
                "com.docker.compose.replace": "redis-1",
                "com.docker.compose.service": "redis",
                "com.docker.compose.version": "5.1.3"
            },
            "StopTimeout": 1
        },
        "NetworkSettings": {
            "SandboxID": "704e380ef954a81d790715c9516c3590f8509a4022aa28ee4f97b9fe10da89a5",
            "SandboxKey": "/var/run/docker/netns/704e380ef954",
            "Ports": {
                "6379/tcp": null
            },
            "Networks": {
                "dockerbung_default": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": [
                        "dockerbung-redis-1",
                        "redis"
                    ],
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "a0bc341830ddd816092a47a33dbebb95efd8add48a1d65cf146ba491b04e53c3",
                    "EndpointID": "1f178e42540870687e86d6b4b273f8fc6b39d97c4b259679bccb7ea3427b4b91",
                    "Gateway": "172.18.0.1",
                    "IPAddress": "172.18.0.3",
                    "MacAddress": "d2:cf:c5:b4:0f:8b",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "DNSNames": [
                        "dockerbung-redis-1",
                        "redis",
                        "6f3dc2194ea1"
                    ]
                }
            }
        },
        "ImageManifestDescriptor": {
            "mediaType": "application/vnd.oci.image.manifest.v1+json",
            "digest": "sha256:fa40c1366358040d51a42e40113e78b19dfdd6e0acaae3fa3e9395a173fab2bd",
            "size": 2288,
            "annotations": {
                "com.docker.official-images.bashbrew.arch": "amd64",
                "org.opencontainers.image.base.digest": "sha256:4d889c14e7d5a73929ab00be2ef8ff22437e7cbc545931e52554a7b00e123d8b",
                "org.opencontainers.image.base.name": "alpine:3.23",
                "org.opencontainers.image.created": "2026-04-15T20:21:50Z",
                "org.opencontainers.image.revision": "8c81e2a44cae9258294718d767ce594e5cbbf20e",
                "org.opencontainers.image.source": "https://github.com/redis/docker-library-redis.git#8c81e2a44cae9258294718d767ce594e5cbbf20e:alpine",
                "org.opencontainers.image.url": "https://hub.docker.com/_/redis",
                "org.opencontainers.image.version": "8.6.2-alpine"
            },
            "platform": {
                "architecture": "amd64",
                "os": "linux"
            }
        }
    }
]
PS C:\Docker Übung> docker inspect dockerbung-redis-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
volume | dockerbung_redis_data_prod | /var/lib/docker/volumes/dockerbung_redis_data_prod/_data | /data
bind |  | C:\Docker Übung\secrets\redis_password.txt | /run/secrets/redis_password

PS C:\Docker Übung> docker inspect dockerbung-prometheus-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
bind |  | C:\Docker Übung\monitoring\prometheus\prometheus.yml | /etc/prometheus/prometheus.yml
volume | dockerbung_prometheus_data | /var/lib/docker/volumes/dockerbung_prometheus_data/_data | /prometheus

PS C:\Docker Übung> docker inspect dockerbung-grafana-1 --format '{{range .Mounts}}{{println .Type "|" .Name "|" .Source "|" .Destination}}{{end}}'
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/provisioning/dashboards | /etc/grafana/provisioning/dashboards
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/provisioning/datasources | /etc/grafana/provisioning/datasources
bind |  | C:\Docker Übung\secrets\grafana_admin_password.txt | /run/secrets/grafana_admin_password
volume | dockerbung_grafana_data | /var/lib/docker/volumes/dockerbung_grafana_data/_data | /var/lib/grafana
bind |  | /run/desktop/mnt/host/c/Docker Übung/monitoring/grafana/dashboards | /var/lib/grafana/dashboards

PS C:\Docker Übung> 
PS C:\Docker Übung> docker compose -f .\compose.prod.yml config --volumes
redis_data_prod
PS C:\Docker Übung> docker compose -f .\compose.dev.yml config --volumes
redis_data_dev
PS C:\Docker Übung>

- [Reverse Proxy mit NGINX](reverse-proxy-nginx.md)
