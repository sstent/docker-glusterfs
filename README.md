# GlusterFS for docker

[![Downloads](https://img.shields.io/docker/pulls/angelnu/gluster.svg)](https://hub.docker.com/r/angelnu/gluster/)
[![Build Status](https://travis-ci.org/angelnu/docker-gluster.svg?branch=master)](https://travis-ci.org/angelnu/docker-gluster)

GlusterFS Server with peer-discovery for [mutiple archs](https://hub.docker.com/r/angelnu/gluster/tags):
- arm
- arm64
- amd64


Compatible
==========
* Works on Kubernetes + SkyDNS
* Works on OpenShift
* Works on Rancher

Features
========
* Will discover peers based on same name DNS records.
* Will auto-peer with peers to form a cluster.
* Will auto-create a shared volume or will join in an existing volume if name matches. (increasing the replica count)


Environment Variables
=====================
| Name               | Description                                | Default         | Example                                     |
|:------------------ |:------------------------------------------ |:--------------- |:------------------------------------------- |
| ROOT_PASSWORD      | SSH login                                  | [required]      | blabla9!                                    |
| SERVICE_NAME       | DNS name to query = discover peers         | gluster         | glusterfs-storage.default.svc.cluster.local |
| SSH_USER           | SSH login to peers                         | root            | glusterfs                                   |
| SSH_PORT           | SSH port to listen on for peers to connect | 2222            | 22                                          |
| SSH_OPTS           | SSH options                                | -p 2222 -o ConnectTimeout=20 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no |                                             |
| GLUSTER_VOL        | name of the gluster volume to expose       | vol0            | myvol0                                      |
| GLUSTER_BRICK_PATH | Path of the local brick (mount)            | /gluster_volume | /bricks/brick0                              |
| DEBUG=1            | Verbose mode                               | 0               |                                             |


Examples
========
See examples dir.


Author
======
* Manel Martinez:
  * For his work on the original nixel/rancher-glusterfs-server
* Samuel Terburg @ Hoolia
  * Kubernetes compatibility
  * Documentation
  * Examples
