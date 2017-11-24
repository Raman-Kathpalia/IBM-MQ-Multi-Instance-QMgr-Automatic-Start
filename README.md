# Readme.txt By Raman Kathpalia 
# IBM MQ SME

# Introduction:

This bash solution can be deployed on IBM MQ nodes where Multi-Instance Queue Managers are configured to run. 

This daemon runs 24/7/365 and puts “failed over MI QMgr” which has a status - "Running elsewhere" to "Running as Standby"  thus making it  - Ready to takeover, should a fail back occurs. 

Every activity by daemon is logged thus giving an audit trail

CPU consumption is very low (< 0.00001% with 2 CPU Intel Zeon) with aggressive polling(10 sec). This solution is tested on RHEL/CentOS.

# Variables used in original script (for reference here)

Activity_Logs=$HOME/Failed_Over_MQ_Instance

FILE_Lock=$Activity_Logs/FILE_Lock.txt

ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt

*Note You can change $HOME dir to somewhere else.

# Question: How to Start or Stop this Process?

--> TO STOP:

        To gracefully Stop this process, simply delete $FILE_Lock

	Code :       [   rm $FILE_Lock    ]

        Process would take few seconds to stop after $FILE_Lock is deleted depending upon on Polling_Interval_Value set by 	   you. By default, Polling_Interval_Value = 20 sec

	kill is a valid and can be used to kill this daemon for instant gratification. 

---> TO START:

        Code to Start:  [ nohup /Path/to/script/StartStandby.bash > $Activity_Logs/nohup.out & ]

       **NOTE:	If this is very first time you are starting this process, you may need to create a dir.

	[ mkdir -p $Activity_Logs ]		
	

--> Process Status CHECK:

	ps -fu mqm | grep [S]tartStandby
	
	ps -fu $USER | grep [S]tartStandby	# if you started under $USER. $USER must be in mqm group
	

# What does this daemon do?


1.	Put the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $Activity_Logs (if It doesn't exits)  

3. 	--- (deprecated feature)

4. 	Creates an empty Lock File - $FILE_Lock

5.	Logs the all activity {Failover activity on this server} with time stamp into a file for
	later review.
	
	FileName - $ACTIVITY_FILE

6. 	If you have to stop MQ activity using [endmqm]; this process wouldn't interfere. StartStandby.bash acts only on 	QMgr with STATUS(Running elsewhere). But it's a good idea to stop this process as well.

8.	StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value 	    variable.


Extra info : How to failover/stop MI QMgr - 

	Failover all MI QMgrs 		[endmqm -s QMgrName]

	Stop All Orphaned MI QMgrs      [endmqm -x QMgrName]

	Stop SI QMgrs 			[endmqm -i QMgrName]
	
More extra info:

* 	Python version coming soon...
