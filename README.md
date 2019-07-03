# SysAdmin
Sysadmin stuff  



I will upload here some scripts that helped me on some projects. Any doubts just contact me.

The number of the script matches the assumption's number and the Instructions' number as well. 


### Script:
1. test_conectivity.sh
2. ansible_conectivity.sh
3. check_filesystem.pl
4. email.pl

## Assumptions:
1. You have netcat (nc) package installed and you are running linux or a linux emulator like cygwin
2. You have netcat installed. You have ansible installed and you already know how to use it.
3. You have Perl installed on your server
4. Just a function to send emails on Perl scripts

## Instructions:
1. Change the IP and ports you want to test but keep them separated by spaces and between double quotes.  
   Execute this script: sh test_conectivity.sh and you will get the results immediately.  
2. Exectute the script "sh ansible_conectivity.sh $inventory_path" replacing $inventory_path with the hosts file of your ansible inventory.
3. Execute it with "perl check_filesystem.pl"



