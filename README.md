# Cryptogen KMS service



## Background

*Cryptogen* i s a standalone web service with persistent storage. It exposes an API with the following verbs: 

- `POST` by accepting input arguments from the request 
- `GET` by returning: 
  - "202 Async"
  - "200 OK" reference with metadata to retrieve crypto assets by the requestor 

*Cryptogen* communicates with KMS service for storing and obtaining crypto assets by KMS specific protocol. 



## Deployment overview

Deployment of KMS service was build on `VirtualBox` platform which provide ability to run mulitply virtual instances on local machine and create eviroment suitable for testing and experimenting.

For this deployment was using some frameworks and tools:

1. `Vagrant`  is an open-source software product for building and maintaining portable virtual software development environments.
2. `Ansible`  is an open-source software provisioning, configuration management, and application deployment tool.
3. `Kubernetes` is an open-source container orchestration system for automating application deployment, scaling, and management.
4. `Helm` is a package management tool for Kubernetes cluster.
5. `MetalLB` - A network LB implementation for Kubernetes using standard routing protocols.
6. `Rook` - File, Block, and Object Storage Services for your Cloud-Native Environments.
7. `Consul` - Storage backend for `Vault`.
8. `Vault` - A tool for secrets management (KMS), encryption as a service, and privileged access management.

![Deployment](https://github.com/maggnus/cryptogen/blob/master/doc/k8s.png)

`Vault` KMS service require persistent storage backend for store encrypted and sensetive data which should be avaliable in HA mode. For this porpuse was using `Consul` tool which store data to the Kubernetes persistent volumes. Kubernetes support different type of storage classes and for this deployment was using `Rook` project which is based on`Ceph` distributed storage system.



## Prerequisites

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for setup virtual environment.
2. Install [Vagrant](https://www.vagrantup.com/downloads.html) tool for deploy virtual servers.
3. Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html) for configure system (`brew install ansible`).



## Deploy virtual servers

Clone project repository:

```console
git clone https://github.com/maggnus/cryptogen.git
```

Check configuration file `etc/cluster_config.yml`:

```yaml
---
box_name: "centos/7"

providers:
  # VirtualBox
  virtualbox:
    enable: true
  # Amazone EC2 (not implemented)
  ec2:
    enable: false
    access_key_id: EDIT_HERE
    secret_access_key: EDIT_HERE
    region: us-east-1
    security_groups: EDIT_HERE
    instance_type: m1.small
    keypair_name: EDIT_HERE
    ssh_private_key_path: EDIT_HERE

servers:
  - name: "kube-master01"
    box: "centos/7"
    cpu: 2
    ram: 2048
    ip: 172.17.8.100
    role: "master"

  - name: "kube-node01"
    box: "centos/7"
    cpu: 2
    ram: 2048
    ip: 172.17.8.101
    role: "node"

  - name: "kube-node02"
    box: "centos/7"
    cpu: 2
    ram: 2048
    ip: 172.17.8.102
    role: "node"

```

Deploy virtual servers with `Vagrantfile`:

```console
vagrant up --provision
```

Check if servers up and running:

```
# vagrant status
Current machine states:

kube-master01             running (virtualbox)
kube-node01               running (virtualbox)
kube-node02               running (virtualbox)
```



# Kubernetes cluster

Login to controller node:

```
vagrant ssh kube-master01
```

Check if all 3 nodes are in `Ready` status:

```
# kubectl get nodes
NAME            STATUS   ROLES    AGE   VERSION
kube-master01   Ready    master   15h   v1.13.4
kube-node01     Ready    <none>   15h   v1.13.4
kube-node02     Ready    <none>   15h   v1.13.4
```

Check if all pods are up and running:

```
NAMESPACE         NAME                                            READY  STATUS
consul            consul-2khpn                                    1/1    Running
consul            consul-5zpmc                                    1/1    Running
consul            consul-qx8np                                    1/1    Running
consul            consul-server-0                                 1/1    Running
consul            consul-server-1                                 1/1    Running
consul            consul-server-2                                 1/1    Running
consul            consul-sync-catalog-857f88f794-9bqf8            1/1    Running
helm              tiller-deploy-5f4b6784-8n7bk                    1/1    Running
metallb           metallb-controller-586c94bfd-frqw8              1/1    Running
metallb           metallb-speaker-2tdwz                           1/1    Running
metallb           metallb-speaker-6nhh8                           1/1    Running
metallb           metallb-speaker-kb8jh                           1/1    Running
nginx-ingress     nginx-ingress-controller-5fcf5899ff-zn68z       1/1    Running
nginx-ingress     nginx-ingress-default-backend-56d99b86fb-h7gvz  1/1    Running
rook-ceph-system  rook-ceph-agent-cll4j                           1/1    Running
rook-ceph-system  rook-ceph-agent-lzccg                           1/1    Running
rook-ceph-system  rook-ceph-agent-zzxkj                           1/1    Running
rook-ceph-system  rook-ceph-operator-b996864dd-hxzbm              1/1    Running
rook-ceph-system  rook-discover-qv5vh                             1/1    Running
rook-ceph-system  rook-discover-tmf87                             1/1    Running
rook-ceph-system  rook-discover-zl8r8                             1/1    Running
rook-ceph         rook-ceph-mgr-a-55ff8b69d4-bqd6p                1/1    Running
rook-ceph         rook-ceph-mon-a-5db8fdb48d-d9zjp                1/1    Running
rook-ceph         rook-ceph-mon-d-bd7497768-frxw7                 1/1    Running
rook-ceph         rook-ceph-mon-e-fbcff54f9-dt42t                 1/1    Running
rook-ceph         rook-ceph-osd-0-68c7f4f597-chxpq                1/1    Running
rook-ceph         rook-ceph-osd-1-69fd7fcb48-dr5xh                1/1    Running
rook-ceph         rook-ceph-osd-2-675f498c47-dr2v6                1/1    Running
rook-ceph         rook-ceph-osd-prepare-kube-master01-77zjd       0/2    Completed
rook-ceph         rook-ceph-osd-prepare-kube-node01-8xj99         0/2    Completed
rook-ceph         rook-ceph-osd-prepare-kube-node02-jxrxp         0/2    Completed
vault             vault-vault-6975d5d8bb-5kt9n                    1/1    Running
vault             vault-vault-6975d5d8bb-65hbq                    1/1    Running
vault             vault-vault-6975d5d8bb-px6g6                    1/1    Running
```



# Consul UI access

To get access to Vault and Consule UI run command:

```
# kubectl get svc --all-namespaces | grep -E 'consul-ui' | column -t
consul  consul-ui    LoadBalancer  10.107.231.153  172.17.8.151  80:30355/TCP    95m
```

Consul UI: http://172.17.8.151
![Consul](https://github.com/maggnus/cryptogen/blob/master/doc/consul.png)



# Vault initial configuration

Check kubernetes services to get public IP and port for external access to `Vault` UI:

```
# kubectl get svc --all-namespaces | grep -E 'vault-vault' | column -t
vault   vault-vault  LoadBalancer  10.98.214.203   172.17.8.152  8200:30955/TCP  58m
```

1. Open `Vault` UI with url https://172.17.8.152:8200 and fill up the form.

   ![Vault](https://github.com/maggnus/cryptogen/blob/master/doc/vault1.png)

2. Store initial Root Token and Unseal Keys.

   ![Vault](https://github.com/maggnus/cryptogen/blob/master/doc/vault2.png)

3. Unseal `Vault` with master key

   ![Vault](https://github.com/maggnus/cryptogen/blob/master/doc/vault3.png)

4. Sing in to`Vault` with root key

   ![Vault](https://github.com/maggnus/cryptogen/blob/master/doc/vault4.png)

5. Done.

   ![Vault](https://github.com/maggnus/cryptogen/blob/master/doc/vault5.png)



# Vault console access

Check that it works:

```
export VAULT_ADDR=https://172.17.8.152:8200
export VAULT_TOKEN=s.JkV1FIDZWBytSFHySIf4jmBE
vault status -tls-skip-verify

Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.0.1
Cluster Name    vault-cluster-9a3140d3
Cluster ID      2289c9df-f2e8-27e6-31cb-d2b84c74bb1e
HA Enabled      true
HA Cluster      https://10.32.0.9:8201
HA Mode         active
```