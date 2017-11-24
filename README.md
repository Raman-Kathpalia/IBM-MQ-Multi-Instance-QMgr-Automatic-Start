# Readme.txt By Raman Kathpalia 
# IBM MQ SME

Activity_Logs=$HOME/Failed_Over_MQ_Instance
export FILE_Lock=${Activity_Logs}/FILE_Lock.txt
ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt

MQ_INSTANCE_ELSEW=$(dspmq -o all | \
        sed '/(Running elsewhere)/!d' | \
        awk -F '[()]' '{print $2}')


Question: How to Start or Stop this Process?

# TO STOP:

        To gracefully Stop this process, simply delete $FILE_Lock

	Code to Stop :       [   rm $FILE_Lock    ]

        Process would take few seconds to stop after $FILE_Lock is deleted. Depending upon Polling_Interval_Value set by you. If left default, process can take upto 20 
	seconds to stop. 

	kill is a valid and can be used to kill this daemon

# TO START:

       To start again, Initiate StartStandby.bash

       Code to Start:  [ nohup $HOME/MQ_Scripts/StartStandby.bash > $HOME/Failed_Over_MQ_Instance/nohup.out & ]

       **NOTE:	If this is very first time you are starting this process on this server, do execute command underneath before regular start

	[ mkdir -p $HOME/Failed_Over_MQ_Instance ]		# Creates a directory  if does not exits.
	

# TO CHECK:

	ps -fu mqm | grep [S]tartStandby
	
	ps -fu $USER | grep [S]tartStandby	# if you started under $USER. $USER must be in mqm group
	

# Upon Start, StartStandby.bash will:


1.	Put the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $HOME/Failed_Over_MQ_Instance (if It doesn't exits)  

3. 	--- (deprecated feature)

4. 	Creates an empty Lock File - $FILE_Lock

5.	Logs the all activity {Failover activity on this server} with time stamp into a file for
	later review.
	
	FileName - $HOME/Failed_Over_MQ_Instance/Activity_trail.txt

6. 	If you have to stop MQ for any reason, stop this process first. Procedure described above
	
	After daemon - StartStandby.bash stops, 

	Failover all MI QMgrs 		[endmqm -s QMgrName]

	Stop All Orphaned MI QMgrs      [endmqm -x QMgrName]

	Stop SI QMgrs 			[endmqm -i QMgrName]

	Check process running under user - mqm (Ideally, there shouldn't be any)

7.	StartStandby.bash acts only on QMgr with STATUS(Running elsewhere).
	It will not touch QMgr with any other status

8.	StartStandby.bash polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value variable.
