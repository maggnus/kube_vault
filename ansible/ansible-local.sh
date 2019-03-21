#!/bin/bash

# Run ansible playbook with generated inventory file
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ../.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory $@

