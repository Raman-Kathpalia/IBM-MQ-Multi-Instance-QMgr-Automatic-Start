# Readme.txt By Raman Kathpalia 
# IBM MQ SME

Question: How to Start or Stop this Process?

# TO STOP:

        To Stop this process, simply delete $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt

        Removing or Deleting $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt file will stop $HOME/tools/StartStandby.sh

        Stopping $HOME/tools/StartStandby.bash means that Automatic start of Failed Over QMgrs in Standby Mode will cease.

        Process would take few seconds to stop after $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt is deleted

        Code to Stop :       [   rm $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt    ]

# TO START:

       To start again, Initiate StartStandby.bash

       Code to Start:       [ nohup $HOME/tools/StartStandby.bash > $HOME/Failed_Over_MQ_Instance/nohup.out & ]


       **NOTE:	If this is very first time you are starting this process on this server, do execute command underneath before regular start

	[ mkdir -p $HOME/Failed_Over_MQ_Instance ]		# Creates a directory  if does not exits.
	

# TO CHECK:

	ps -fu mqm | grep [S]tartStandby
	
	ps -fu $USER | grep [S]tartStandby	# if you started under $USER. $USER must be in mqm group
	

# Upon Start, StartStandby.bash will:


1.	Put the Multi Instance Failed over QMgr(s) with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $HOME/Failed_Over_MQ_Instance (if It doesn't exits)  

3. 	--- (depracated feature)

4. 	Creates an empty Lock File - $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt

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
