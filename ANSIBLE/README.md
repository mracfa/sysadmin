# ansible

Playbooks and Roles for ansible


I will upload here some playbooks or roles that helped me on some projects. Any doubts just contact me.

The number of the playbook matches the assumption's number and the Instructions' number as well. 



### Playbook:
1. upload_ssh_keys.yml

## Assumptions:
1. You have already installed Ansible and you know how to run playbooks  
1. You already have exchanged SSH keys from ansible to the servers where you will run this playbook

## Instructions:
1. Change the vars to the ones you need: user_set_pubkey, inventory_home, and create a list of public keys 
1. Upload the user's .pub keys to {{ inventory_home }}/files
1. Check the list of hosts on the task "create list of hosts". On my case i used the /etc/hosts file of ansible servers, but if you wish just create a list of hosts on the vars section and comment the first task
1. Execute the playbook: "ansible-playbook upload_ssh_keys.yml", it will send the public keys you configured to the defined user's authorized_keys file  



