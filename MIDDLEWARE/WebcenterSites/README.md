# WebCenter Sites

I will upload here some scripts that helped me on some projects. Any doubts just contact me.

The number of the script matches the assumption's number and the Instructions' number as well. 


### Script:
1. visitors_cluster.sh  
   This Script is related to the following note from Oracle: How to Cluster WebCenter Sites Visitor Services 12c? (Doc ID 2120761.1)

## Assumptions:
1. You have installed a clustered WCS environment and migrated the Shared Filesystem to Database (with the product script). 

## Instructions:
1. After creating the clustered Visitors WCS domain, with Admin Server running, just execute this script: sh visitors_cluster.sh and it should make all the needed changes in the JMS Servers, JDBC, Deployments, etc.

