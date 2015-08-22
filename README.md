# kubernetes-glusterfs-server
GlusterFS Server with peer-discovery.


Features
========
* Compatible with the Service Discovery (SkyDNS) feature of Kubernetes.
* Each added container increases the replica count


Environment Variables
=====================
| Name               | Description                                |
|:------------------ |:------------------------------------------ |
| ROOT_PASSWORD      | SSH login                                  |
| SERVICE_NAME       | DNS name to query = discover peers         |
| SSH_USER           | SSH login to peers                         |
| SSH_PORT           | SSH port to listen on for peers to connect |
| SSH_OPTS           | SSH options                                |
| GLUSTER_VOL        | name of the gluster volume to expose       |
| GLUSTER_BRICK_PATH | Path of the local brick (mount)            |
| DEBUG=1            | Verbose mode                               |


Examples
========
See examples dir.


Author
======
Forked from: nixel/rancher-glusterfs-server <Manel Martinez>
Additional : Samuel Terburg @ Hoolia


