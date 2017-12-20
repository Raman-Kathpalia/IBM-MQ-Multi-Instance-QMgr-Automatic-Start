#### Readme.txt By [Raman Kathpalia](https://www.linkedin.com/in/ramankathpalia10)
#### IBM MQ SME and Automation Enthusiast.
#### This is a high level solution. You're allowed to use as is or customize/improvise it based upon your needs.

### Introduction: 

This bash solution can be deployed on IBM MQ server nodes where [Multi-Instance Queue Managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_8.0.0/com.ibm.mq.con.doc/q018140_.htm) are configured. 
Solution is tested on RHEL/CentOS 6 and 7 with MQ 7.5.X.X and 8.XXX

#### What does this process/daemon do? (High level) 

-	Puts QMgr with status “Running elsewhere” to "Running as Standby". Thus secondary QMgr is Ready to takeover should  a fail back reoccurs. 
-	Audits every activity performed
-	CPU consumption by this process is low (< 0.01%) as observed in 2 CPU Intel Zeon machine with aggressive polling. (10 seconds)


*Variables used in original script (Just for reference)*

```javascript
Activity_Logs=$HOME/Failed_Over_MQ_Instance
FILE_Lock=$Activity_Logs/FILE_Lock.txt
ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt
Polling_Interval_Value=20
```

*Note You can change location `$HOME` dir  or `Polling_Interval_Value`*

#### Question: How to Start or Stop this Process?

##### TO STOP:

 To gracefully Stop this process, simply delete `$FILE_Lock`

   	rm $FILE_Lock

 For Process to stop, it would take few seconds to upto `Polling_Interval_Value` after`$FILE_Lock` is deleted.
 By  default, `Polling_Interval_Value = 20 seconds`

 `kill` is valid and can be used to stop this daemon for instant gratification. 

##### TO START:

	touch $FILE_Lock
  	nohup /Path/to/script/StartStandby.bash > $Activity_Logs/nohup.out &
	
#####     Note: Process won't start unless lock file is present. This is a safety measure against inadvertent start.
#####     Any attempt to start (with or without nohup) without `$FILE_LOCK` being present is reported in `$ACTIVITY_FILE` with timestamp
	
##### To CHECK:

   	ps -fu mqm | grep [S]tartStandby
	
   	ps -fu $LOGNAME | grep [S]tartStandby       	#if started under user: $LOGNAME. $LOGNAME must be in mqm group
	

#### What does this process do? - Step by Step


1.	Puts the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory `$Activity_Logs` and file - `$ACTIVITY_FILE` is created(if it doesn't exits)

3. 	--- (deprecated feature)

4. 	--- (deprecated feature)

5.	Logs all Failover MQ activity on a node with timestamp for review later.
	
6. 	If you have to stop MQ normally/immediately using [endmqm](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.ref.adm.doc/q083320_.htm); this process wouldn't interfere. QMgrs (Active and Standby) would end normally on both nodes. StartStandby.bash acts only on QMgr with STATUS(Running elsewhere). But it may be a a good idea to stop this process as well if you're servicing [IBM MQ](http://www-03.ibm.com/software/products/en/ibm-mq) 

7. StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value 	      variable.

8. Single Instance QMgrs are not affected. 

9. To Check CPU/Memory usage in realtime by process; do `top -p PID` where `PID` == process ID of StartStandby.bash. 

10. No code change necessary from one node to another irrespective of Queue Managers running on individual boxes. 
    No hard-coding of QMgrNames needed anywhere.



#### *Side note:  [How to manually failover Multi-Instance Queue Manager](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q018330_.htm)*

	Failover MI QMgr		[endmqm -s QMgrName]

	Stop Orphaned MI QMgr     	[endmqm -x QMgrName]

	Stop SI QMgr			[endmqm -i QMgrName]
	
##### *Python version coming soon...*
