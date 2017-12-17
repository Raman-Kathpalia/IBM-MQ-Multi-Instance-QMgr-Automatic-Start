# Readme.txt By Raman Kathpalia 
# [IBM MQ SME](www.linkedin.com/in/ramankathpalia10)
# This is a high level solution. You're allowed to use as is or customize it based upon your needs.

# Introduction:

This bash solution can be deployed on IBM MQ nodes where [Multi-Instance Queue Managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_8.0.0/com.ibm.mq.con.doc/q018140_.htm) are configured.

Solution is tested on RHEL/CentOS 6 and 7 with MQ 7.5.X.X and 8.XXX

# What does this process/daemon do?

-	Puts QMgr with status “Running elsewhere” to "Running as Standby". Thus secondary QMgr is Ready to takeover if a fail back occurs. 
-	Audits every activity performed
-	CPU consumption is low (< 0.01%) as observed in 2 CPU Intel Zeon machine with aggressive polling. (few seconds)


*Variables used in original script (Just for reference)

```python
Activity_Logs=$HOME/Failed_Over_MQ_Instance
FILE_Lock=$Activity_Logs/FILE_Lock.txt
ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt
Polling_Interval_Value=20
```

*Note You can change location $HOME dir  or Polling_Interval_Value.

# Question: How to Start or Stop this Process?

--> TO STOP:

 To gracefully Stop this process, simply delete $FILE_Lock

   `rm $FILE_Lock`   

 Process would take few seconds to stop after `$FILE_Lock` is deleted depending upon on `Polling_Interval_Value set`. By default, `Polling_Interval_Value = 20 sec`

 `kill` is a valid and can be used to stop this daemon for instant gratification. 

---> TO START:

  `nohup /Path/to/script/StartStandby.bash > $Activity_Logs/nohup.out &`
	
--> Process Status CHECK:

   `ps -fu mqm | grep [S]tartStandby`
	
   `ps -fu $LOGNAME | grep [S]tartStandby`       	# if started under $LOGNAME. $LOGNAME must be in mqm group
	

# What does this daemon do?


1.	Put the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $Activity_Logs (if it doesn't exits)  

3. 	--- (deprecated feature)

4. 	--- (deprecated feature)

5.	Logs all Failover activity on node with time stamp for later review.
	

6. 	If you have to stop MQ activity using [endmqm](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.ref.adm.doc/q083320_.htm); this process wouldn't interfere. StartStandby.bash acts only on QMgr with STATUS(Running elsewhere). But it's a good idea to stop this process as well.

7.	StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value 	    variable.



[How to failover Multi-Instance QMgr manually](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.5.0/com.ibm.mq.con.doc/q018330_.htm)

	Failover MI QMgr		[endmqm -s QMgrName]

	Stop Orphaned MI QMgr     	[endmqm -x QMgrName]

	Stop SI QMgr			[endmqm -i QMgrName]
	
More extra info:

* 	Python version coming soon...
