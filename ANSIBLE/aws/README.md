# Ansible AWS Api

Ansible module for AWS instructions


# Assumptions  
1. You already have Ansible installed on your server and you know how to run playbooks
2. You have priviledged access to install packages 

# Credentials: IAM user Access keys  
You should use the aws_access_key_id and aws_secret_access_key that were provided when your AWS user was created. You cannot use your username and password.  
If you don't have these 2 keys, please ask to the AWS administrator to generate a new pair for you.

1. You need to install 3 additional packages to use aws module on ansible: boto boto3  botocore  
    Use pip to do it with the following command: **pip install boto boto3 botocore**  
2. Create a file on your home user (**~/.aws/credentials**) with the following content:  

```
[default]  
aws_access_key_id: XXXXXXXXXXXXXXXXX  
aws_secret_access_key: YYYYYYYYYYYYYYYYYYYY
```  

3. Create a file on your home user (**~/test-boto.py**) with the following content:
```
#!/usr/bin/python3
# A simple program to test boto and print s3 bucket names
import boto3
t = boto3.resource('s3')
for b in t.buckets.all():
    print(b.name)
```  
    
4. Execute this simple script just to test if the connection to AWS is successfull: **python test-boto.py**  
   If your key is invalid or if you dont reach AWS, you will get an exception like below:  
```  
[mabreu@ansible ~]$ python test-boto.py 
Traceback (most recent call last):
  File "test-boto.py", line 5, in <module>
    for b in t.buckets.all():
  File "/home/mabreu/.local/lib/python2.7/site-packages/boto3/resources/collection.py", line 83, in __iter__
    for page in self.pages():
  File "/home/mabreu/.local/lib/python2.7/site-packages/boto3/resources/collection.py", line 161, in pages
    pages = [getattr(client, self._py_operation_name)(**params)]
  File "/home/mabreu/.local/lib/python2.7/site-packages/botocore/client.py", line 357, in _api_call
    return self._make_api_call(operation_name, kwargs)
  File "/home/mabreu/.local/lib/python2.7/site-packages/botocore/client.py", line 661, in _make_api_call
    raise error_class(parsed_response, operation_name)
botocore.exceptions.ClientError: An error occurred (InvalidAccessKeyId) when calling the ListBuckets operation: The AWS Access Key Id you provided does not exist in our records.  
```  

   If your connection is successfull, you might not get any result from the previous command execution and you are now able to run playbooks.  
   

# Ansible Playbook to Create EC2 instances on AWS

This playbook creates EC2 instances and security groups on AWS  

## Role Variables

This playbook expects the following variables to be defined:

| Name                                                                                                                                                               | Required                                        | Description |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|-|
| `security_groups`                                                                                                                                                  | &nbsp;                                          | List of Security Groups to create or change. Each item on this list is composed of the following variables: |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`name`                                                                                                             | Yes                                             | Security Group Name. (ex.: `ansible`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`description`                                                                                                          | Yes                                             | Short description of security group (ex.: `Ansible Security Group`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`aws_region`                                                                                                    | Yes                                             | AWS region where you will create or change the group (ex.: `eu-central-1`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`vpc_id`                                                                                                      | Yes                                             | VPC ID (ex.: `vpc-17ccc67c`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`firewall`                                                                                                             | &nbsp;                                          | &nbsp;  | 
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`inbound`                                                          | Yes                                             | 	  List of Inbound rules. Each rule is composed by the following variables: | 
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`proto`                                                   | Yes                                             | Protocol (ex.: `tcp`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`from_port`                                                | Yes                                              | Port Range (ex.: `22`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`to_port`                                                | Yes                                              | Port Range (ex.: `22`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`cidr_ip`                                                | When  `group_name` not defined                                             | Source Network  (ex.: `0.0.0.0/0`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`group_name`                                                | When `cidr_ip` not defined                                              | Group Name to apply rule  (ex.: `ansible`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`rule_desc`                                                | Yes                                              | Rule description (ex.: `All Networks`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`outbound`                                                          | Yes                                             | 	  List of Outbound rules. Each rule is composed by the following variables: | 
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`proto`                                                   | Yes                                             | Protocol (ex.: `tcp`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`from_port`                                                | Yes                                              | Port Range (ex.: `0`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`to_port`                                                | Yes                                              | Port Range (ex.: `65000`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`cidr_ip`                                                | Yes                                             | Source Network  (ex.: `213.30.18.1/32`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`rule_desc`                                                | Yes                                              | Rule description (ex.: `Test Rule`) |
| `ec2_instances`                                                                                                                                                  | &nbsp;                                          | List of Security Groups to create or change. Each item on this list is composed of the following variables: |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`name`                                                                                                             | Yes                                             | Security Group Name. (ex.: `ansible`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`security_group`                                                                                                                                                           | Yes          | Item of Security Groups list `security_groups` on which to create this instance. (ex.: `{{ security_groups[0] }}`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`key_name`                                                                                                          | Yes                                             | SSH Publick Key that will be added to authorized_keys on default user of this instance. This key needs to exist already (ex.: `mfa2`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`aws_region`                                                                                                    | Yes                                             | AWS region where you will create or change the group (ex.: `eu-central-1`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`vpc_subnet_id`                                                                                                      | Yes                                             | VPC Subnet ID (ex.: `subnet-572e111a`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`vpc_id`                                                                                                      | Yes                                             | VPC ID (ex.: `vpc-17ccc67c`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`ami_id`                                                                                                      | Yes                                             | Ami ID - Image ID that will be deployed (ex.: `ami-0cc293023f983ed53`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`instance_type`                                                                                                      | Yes                                             | Instance Type (ex.: `t2.micro`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`sec_group`                                                                                                      | Yes                                             | Security Group to apply to ec2 instance  (ex.: `ansible`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`public_ip`                                                                                                      | Yes                                             | Assign public IP? (`Yes/No`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`count`                                                                                                      | Yes                                             | Number of exact instances to create (ex.: `1`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`wait`                                                                                                      | Yes                                             | Wait for the instance to reach its desired state before continuing? (`Yes/No`) |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`environment`                                                                                                      | Yes                                             | Environment tag or Group to add Tags (ex.: `osb-test`) |


	


