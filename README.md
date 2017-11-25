# Readme.txt By Raman Kathpalia 
# IBM MQ SME

# Introduction:

This bash solution can be deployed on IBM MQ nodes where Multi-Instance Queue Managers are configured.

Solution is tested on RHEL/CentOS 6 and 7 with MQ 7.5.X.X and 8.XXX

This daemon runs 24/7/365 and puts “failed over MI QMgr” which has a status - "Running elsewhere" to "Running as Standby"  thus making it  - Ready to takeover, should a fail back occurs. 

Each and Every activity by daemon is logged thus giving an audit trail

CPU consumption is very low (< 0.00001%) as observed in 2 CPU Intel Zeon machine with aggressive polling(10 seconds)


# Variables used in original script (for reference here)

Activity_Logs=$HOME/Failed_Over_MQ_Instance

FILE_Lock=$Activity_Logs/FILE_Lock.txt

ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt

Polling_Interval_Value=20

*Note You can change $HOME dir or Polling_Interval_Value.

# Question: How to Start or Stop this Process?

--> TO STOP:

        To gracefully Stop this process, simply delete $FILE_Lock

	Code :       [   rm $FILE_Lock    ]

        Process would take few seconds to stop after $FILE_Lock is deleted depending upon on Polling_Interval_Value set. 
	By default, Polling_Interval_Value = 20 sec

	kill is a valid and can be used to kill this daemon for instant gratification. 

---> TO START:

        Code to Start:  [ nohup /Path/to/script/StartStandby.bash > $Activity_Logs/nohup.out & ]

	

--> Process Status CHECK:

	ps -fu mqm | grep [S]tartStandby
	
	ps -fu $LOGNAME | grep [S]tartStandby	# if you started under $LOGNAME. $LOGNAME must be in mqm group
	

# What does this daemon do?


1.	Put the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $Activity_Logs (if It doesn't exits)  

3. 	--- (deprecated feature)

4. 	Creates an empty Lock File - $FILE_Lock

5.	Logs the all activity {Failover activity on this server} with time stamp into a file for
	later review.
	
	FileName - $ACTIVITY_FILE

6. 	If you have to stop MQ activity using [endmqm]; this process wouldn't interfere. StartStandby.bash acts only on 	QMgr with STATUS(Running elsewhere). But it's a good idea to stop this process as well.

7.	StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value 	    variable.


Extra info(from IBM) : How to failover/stop MI QMgr - 

	Failover all MI QMgrs 		[endmqm -s QMgrName]

	Stop All Orphaned MI QMgrs      [endmqm -x QMgrName]

	Stop SI QMgrs 			[endmqm -i QMgrName]
	
More extra info:

* 	Python version coming soon...
