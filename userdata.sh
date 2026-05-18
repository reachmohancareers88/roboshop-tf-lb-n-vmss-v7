#!/usr/bin/bash

sudo dnf install python3-pip.noarch -y
sudo pip3.12 install ansible

ansible-pull -i localhost, -U https://github.com/raghudevopsb89/roboshop-ansible-v4.git roboshop.yml -e component_name=${component_name} -e env=${env}

