### MQ_Multi_Instance_Monitor.bash is enhanced version of StartStandby.bash
#### (offering same core functionality as StartStandby.bash)

### This is a Readme file for program - MQ_Multi_Instance_Monitor.bash
By - 
### [Raman Kathpalia. IBM MQ SME and Automation Enthusiast](https://www.linkedin.com/in/RamanKathpalia) 
### This is a high-level solution. You're allowed to use as is or customize it. No Warranties.

### *What is new in MQ_Multi_Instance_Monitor.bash (Compared to StartStandby.bash)*

##### 	1. Simple Operation. [start | stop | check] Arguments introduced
#####	2. Ease of putting the program into Maintenance mode 
##### 	3. Single threaded operation. Multi-threaded operation is an overkill. This program doesn't spawns multiple threads
#####	4. Penguin replaces the cow. For lactose intolerant Linux lovers :) 


### Introduction: 

For organisations, who operate Multi-Instance Queue Managers as a [HA solution for IBM MQ](https://www.ibm.com/support/knowledgecenter/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q017830_.htm) often notice that once MQ failover occurs, it leaves behind a defunct QMgr not capable to take over should a failback reoccurs. Autostart feature of defunct QMgr is not available in IBM MQ. This is by design as one should manually introspect the reason of failover, fix it and start the defunct QMgr to standby mode. 

So far so good. 

However, there are few cases where the problem is transitory and goes away with MQ restart/fail-over.

Let's observe few use cases - 

1. Underlying NAS storage is being serviced and causes Active QMgr instance to fail-over
2. Application bug causes MQ to be non-responsive, but MQ restart/fail-over fixes the problem
3. Please feel free to add more cases that you've witnessed

These few cases coupled with hundreds of Multi-Instance QMgrs, managing them quickly becomes a challenge.

So for all those scenarios, this solution could be used. 

This shell/bash solution is designed to run as a process. This solution should be deployed and run on IBM MQ server nodes where [Multi-Instance Queue Managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_8.0.0/com.ibm.mq.con.doc/q018140_.htm) are configured. 
The same process should run on both Active and Standby nodes.

The solution is tested on Linux - RedHat Enterprise Linux and CentOS versions - (6.x and 7.x) with MQ version 7.5.X.X and 8.XXX

#### Having this piece of code with multi-Instance MQ, One can bring HA for MQ closer to a Vendor based [traditional HA](https://en.wikipedia.org/wiki/High-availability_cluster#/media/File:2nodeHAcluster.png) solutions - [RedHat Cluster Suite](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-rhcs-intro-cso) or [VCS with MQ](https://sort.veritas.com/public/documents/sfha/6.0.2/linux/productguides/html/vha_webspheremq_install/ch04s07.htm) to name a few.

### What does this process/daemon do? (High level) 

-	Puts QMgr(s) with status “Running elsewhere” to "Running as Standby". Thus secondary QMgr is Ready to take over should a fail-over reoccurs. 
-	Writes every MQ fail-over activity performed to Log for later review/audit.
-	CPU consumption by this process is low (< 0.01%) as observed in 2 CPU Intel Zeon machine with aggressive polling. (10 seconds)

### What is needed to Install this program:

1. Copy MQ_Multi_Instance_Monitor.bash on both nodes where Multi-Instance Queue manager are running (Active and Standby) at your chosen location
2. Default directory, where all data by this script is gathered, is in `$HOME/MI`. If you are happy with this location, no change needed. Else see below *Variables used in original script that could be altered*
3. By default, this process polls every 20 seconds. If you're happy with this value, no change needed. Else see below *Variables used in original script that could be altered*
4. Start the program on both nodes. 


### Question: How to Start or Stop this Process?

#### *TO START Process:*

	./MQ_Multi_Instance_Monitor.bash start
		
#### *TO STOP Process:*

   	./MQ_Multi_Instance_Monitor.bash stop
	
#### *To CHECK Process:*
	
   	./MQ_Multi_Instance_Monitor.bash CHECK
	
### Note: Case of Argument [start|stop|check] does Not matter. You can specify however you want. 	

#### *EXAMPLE: DRY-RUN*

```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash 
  
Specify only one argument: 

USAGE: ./MQ_Multi_Instance_Monitor.bash START | STOP | CHECK
```

#### *EXAMPLE: START*

```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash start

------------------------------------------------------------------------------------------------------------
Sat Feb 17 17:17:54 EST 2018: 

Manual start attempted but Maintenance mode detected.
	
./MQ_Multi_Instance_Monitor.bash process not started

[touch /home/mqm/MI/LOCK_FILE.txt] to take it out of maintenance mode and Retry.

------------------------------------------------------------------------------------------------------------
```	
####     Note: This process runs on the concept of lock file monitoring. The process won't start *unless* lock file is present. This is a safety measure against inadvertent start. Any attempt to start without lock file being present is reported in Activity Log along with timestamp	
```
[mqm@joker7 ~]$ touch /home/mqm/MI/LOCK_FILE.txt		

[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash Start
 
------------------------------------------------------------------------------------------------------------
		Started MQ_Multi_Instance_Monitor Process Manually at Sat Feb 17 17:21:07 EST 2018
------------------------------------------------------------------------------------------------------------
```				
####	Program won't start another instance if one is running. Multi-threaded operation is not needed and frankly, is an overkill. 
```					
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash Start

	Process already Running. 
```
#### Process continues to run even after the user logs out.

#### *EXAMPLE: STOP*

```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash stop

------------------------------------------------------------------------------------------------------------
Sat Feb 17 15:59:43 EST 2018: 

Stopped MQ_Multi_Instance_Monitor Process Manually.

This can take up to 20 seconds to stop. 

You may kill it for instant gratification.
------------------------------------------------------------------------------------------------------------
```
#### If Process is already stopped
```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash stop

MQ_Multi_Instance_Monitor Process Already in Stopped status
 
[mqm@joker7 ~]$ 
```
 
### *EXAMPLE: CHECK*
```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash check
UID  PID    STIME
mqm  19598  12:50
```
##### UID - User ID. This must be a part of mqm group if ID other than mqm is being used.
##### PID - Process ID.
##### STIME - Start time. Indicates how long the program has been running. 

##### If Process is already stopped:
```
[mqm@joker7 ~]$ ./MQ_Multi_Instance_Monitor.bash check
 
	PROCESS MQ_Multi_Instance_Monitor NOT RUNNING
	
[mqm@joker7 ~]$ 
```


### What does this process do? - Step by Step


1.	Puts the Multi-Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory `$FAILOVER_ACTIVITY_DIR` and file - `$ACTIVITY_FILE` (if they don't already exist)

3. 	Keeps a check on `$ACTIVITY_FILE` from expanding beyond 150KB

4. 	--- (deprecated feature)

5.	Logs all Failover MQ activity on both nodes with the timestamp for review later.
	
6. 	If you have to stop MQ normally/immediately using [endmqm](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.ref.adm.doc/q083320_.htm); this process wouldn't interfere. QMgrs (Active and Standby) would end normally on both nodes. StartStandby.bash acts only on QMgr with STATUS(Running elsewhere). But it may be a good idea to stop this process as well if you're servicing IBM MQ

7. StartStandby.bash polls/checks every 20 seconds. You can edit that in the script by altering the `POLLING_INTERVAL` variable.

8. Single Instance QMgrs are not affected. 

9. To Check CPU/Memory usage in real-time by process; do `top -p PID` where `PID` == process ID of StartStandby.bash. 
	
#### 10. No code change necessary from one node to another irrespective of Queue Managers Names on individual boxes. 
####     No hard-coding of QMgrNames needed anywhere in solution.
####     No configuration file(s) need be supplied.



##### *Variables used in original script*

```
FAILOVER_ACTIVITY_DIR=$HOME/MI
LOCK_FILE=$FAILOVER_ACTIVITY_DIR/LOCK_FILE.txt
ACTIVITY_FILE=${FAILOVER_ACTIVITY_DIR}/Activity_trail.txt
POLLING_INTERVAL=20
```

#### *Variables used in original script that could be altered*

##### You can change POLLING_INTERVAL value. Default is 20 seconds
`POLLING_INTERVAL=20`                          

##### You an choose where you want to put data generated by MQ_Multi_Instance_Monitor.bash
`FAILOVER_ACTIVITY_DIR=$HOME/MI`        			
##### You don't have to create this directory though. It will be automatically created.




#### *NOTES:*
##### To learn more on IBM MQ High Availability, visit [here](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q017830_.htm)

##### For curious minds: [VCS Vs. Oracle RAC](https://www.quora.com/HA-Veritas-Cluster-Service-VCS-Vs-Oracle-RAC)

###### [How to manually failover Multi-Instance Queue Manager](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q018330_.htm)

	Failover MI QMgr			[endmqm -s QMgrName]

	Stop defunct MI QMgr     		[endmqm -x QMgrName]

	Stop Single Instance QMgr		[endmqm QMgrName]


