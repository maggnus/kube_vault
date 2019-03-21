Cryptogen KMS service
======================
Deploy simple webapp with upload functionality on Docker and Apache Mesos.



Prerequisites
--------------------------

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for setup virtual environment.
2. Install [Vagrant](https://www.vagrantup.com/downloads.html) tool for deploy virtual servers.
3. Install [Ansible](http://docs.ansible.com/ansible/intro_installation.html) for configure system.



Deploy virtual servers
--------------------------

Clone project repository:
```console
git clone https://github.com/maggnus/cryptogen.git
cd marathon_cluster_vagrant
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
vagrant up
```
Check if servers up and running:

```
# vagrant status
Current machine states:

kube-master01             running (virtualbox)
kube-node01               running (virtualbox)
kube-node02               running (virtualbox)
```

