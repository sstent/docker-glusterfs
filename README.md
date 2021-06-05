# GlusterFS for docker

[![Downloads](https://img.shields.io/docker/pulls/angelnu/glusterfs.svg)](https://hub.docker.com/r/angelnu/glusterfs/)
[![Build Status](https://travis-ci.org/angelnu/docker-glusterfs.svg?branch=master)](https://travis-ci.org/angelnu/docker-glusterfs)

**NOTE**: Archiving this since I moved to ceph and the [k8s community](https://github.com/k8s-at-home). I will not delete it since it was used by others
but please notice that I am also dissabling the weekly builds since the trigger docker pull limit errors and I do not want the spam nor have the
interest to upgrade the CI to use the Github container registry. IF there is interest of others please contact me in the k8s-at-home Discord.

GlusterFS Server with peer-discovery for [mutiple archs](https://hub.docker.com/r/angelnu/glusterfs/tags):
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
