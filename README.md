#### Readme.txt By [Raman Kathpalia](https://www.linkedin.com/in/ramankathpalia10)
##### IBM MQ SME and Automation Enthusiast.
##### This is a high level solution. You're allowed to use as is or customize it based upon your needs.

#### Introduction: 

For organisations who operate Multi-Instance QMgrs as a [HA solution for IBM MQ](https://www.ibm.com/support/knowledgecenter/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q017830_.htm) often notice that once MQ failover occurs, it leaves behind a defunct QMgr not capable to takeover should a fail back reoccurs. Autostart feature of defunct QMgr is not available in IBM MQ. This is by design as one should manually introspect the reason of failover, fix it and start the defunct QMgr to standby mode. 

So far so good. 

However, there are few cases where the problem is transitory and goes away with MQ restart/failover.

Let's observe few use cases - 

	1. Underlying NAS storage is being serviced and causes Active QMgr instance to failover
	2. Application bug causes MQ to be non-reponsive, but MQ restart/failover fixes the problem
	3. Please feel free to add more cases that you've witnessed

These few cases coupled with hundreds of Multi-Instance QMgrs, managing them quickly becomes a challenge.

So for all those scenarios, this solution could be used. 

This shell/bash solution is designed to run as a process. This solution should be deployed and run on IBM MQ server nodes where [Multi-Instance Queue Managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_8.0.0/com.ibm.mq.con.doc/q018140_.htm) are configured. 
Same process should run on both Active and Standby nodes.

Solution is tested on Linux - RHEL(6,7) and CentOS with MQ 7.5.X.X and 8.XXX

##### Having this piece of code with multi-Instance MQ, One can bring HA for MQ closer to a Vendor based [traditional HA](https://en.wikipedia.org/wiki/High-availability_cluster#/media/File:2nodeHAcluster.png) solutions - [RHCS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-rhcs-intro-cso) or [VCS](https://symwisedownload.symantec.com/resources/sites/SYMWISE/content/live/SOLUTIONS/26000/TECH26832/en_US/260419.pdf?__gda__=1515048753_ffed058e8081bdeb51b7cc85fd1d6c00) etc.

##### What does this process/daemon do? (High level) 

	-	Puts QMgr with status “Running elsewhere” to "Running as Standby". Thus secondary QMgr is Ready to takeover should  a fail back reoccurs. 
	-	Audits every MQ failover activity performed by this solution
	-	CPU consumption by this process is low (< 0.01%) as observed in 2 CPU Intel Zeon machine with aggressive polling. (10 seconds)


#### Question: How to Start or Stop this Process?

##### *TO START:*

	touch $FILE_Lock
  	nohup /Path/to/script/StartStandby.bash > $Activity_Logs/nohup.out &
	
#####     Note: Process won't start unless lock file is present. This is a safety measure against inadvertent start.
#####     Any attempt to start (with or without nohup) without `$FILE_LOCK` being present is reported in `$ACTIVITY_FILE` with timestamp
	
##### *TO STOP:*

 To gracefully Stop this process, simply delete `$FILE_Lock`

   	rm $FILE_Lock

 For Process to stop, it would take few seconds to upto `Polling_Interval_Value` after`$FILE_Lock` is deleted.
 By  default, `Polling_Interval_Value = 20 seconds`

 `kill` is valid and can be used to stop this daemon for instant gratification. 
 
##### *To CHECK:*

   	ps -fu mqm | grep [S]tartStandby
	
   	ps -fu $LOGNAME | grep [S]tartStandby       	#if started under user: $LOGNAME. $LOGNAME must be in mqm group
	



#### What does this process do? - Step by Step


1.	Puts the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory `$Activity_Logs` and file - `$ACTIVITY_FILE` (if they don't already exits)

3. 	--- (deprecated feature)

4. 	--- (deprecated feature)

5.	Logs all Failover MQ activity on both nodes with timestamp for review later.
	
6. 	If you have to stop MQ normally/immediately using [endmqm](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.ref.adm.doc/q083320_.htm); this process wouldn't interfere. QMgrs (Active and Standby) would end normally on both nodes. StartStandby.bash acts only on QMgr with STATUS(Running elsewhere). But it may be a a good idea to stop this process as well if you're servicing IBM MQ

7. StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value 	      variable.

8. Single Instance QMgrs are not affected. 

9. To Check CPU/Memory usage in realtime by process; do `top -p PID` where `PID` == process ID of StartStandby.bash. 
	
##### 10. No code change necessary from one node to another irrespective of Queue Managers running on individual boxes. 
#####     No hard-coding of QMgrNames needed anywhere.
#####     No configuration file(s) need be supplied.



###### *Variables used in original script that could be tuned*

```javascript
Activity_Logs=$HOME/Failed_Over_MQ_Instance
FILE_Lock=$Activity_Logs/FILE_Lock.txt
ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt
Polling_Interval_Value=20
```

	$HOME is where MQ Activity logs will be collected for review later
	Polling_Interval_Value is how frequently you want this solution to poll and look for defunct QMgr.
	
###### 	Note You can change location `$HOME` or `Polling_Interval_Value` in actual script




#### *NOTES:*
##### To learn more on IBM MQ HA, visit [here](http://www.redbooks.ibm.com/redbooks/pdfs/sg247839.pdf)

##### For curious minds: [VCS Vs. Oracle RAC](https://www.quora.com/HA-Veritas-Cluster-Service-VCS-Vs-Oracle-RAC)

###### [How to manually failover Multi-Instance Queue Manager](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q018330_.htm)

	Failover MI QMgr			[endmqm -s QMgrName]

	Stop defunct MI QMgr     		[endmqm -x QMgrName]

	Stop Single Instance QMgr		[endmqm QMgrName]
	
##### *Python version coming soon...*
