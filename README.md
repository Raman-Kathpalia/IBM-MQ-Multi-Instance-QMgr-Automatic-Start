# Readme.txt By Raman Kathpalia 
# IBM MQ SME

Question: How to Start or Stop this Process?

- TO STOP:

        To Stop this process, simply delete $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt

        Removing or Deleting $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt file will stop $HOME/tools/StartStandby.sh

        Stopping $HOME/tools/StartStandby.sh means that Automatic start of Orphaned QMgrs in Standby Mode will cease.

        Process would take few seconds to stop after $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt is deleted

        Code to Stop :       [   rm $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt    ]

- TO START:

       To start again, Initiate StartStandby.sh

       Code to Start:       [ nohup $HOME/tools/StartStandby.sh > $HOME/Failed_Over_MQ_Instance/nohup.out & ]


       **NOTE:	If this is very first time you are starting this process on this server, do execute command underneath before regular start

	[ mkdir -p $HOME/Failed_Over_MQ_Instance ]		# Creates a directory  $HOME/Failed_Over_MQ_Instance if does not exits.
	

- TO CHECK:

	ps -fu mqm | grep [S]tartOrphanQMgr
	ps -fu $USER | grep [S]tartOrphanQMgr	# if you started under $USER. $USER must be in mqm group
	

Please go through $HOME/Failed_Over_MQ_Instance/readme.txt to learn a bit more about for Start / Stop operation.




Upon Start, StartStandby.sh will:


1.	Put the Multi Instance Orphan QMgr with Status - "RUNNING ELSEWHERE" to STANDY MODE

2.	Creates a directory $HOME/Failed_Over_MQ_Instance (if It doesn't exits)  

3. 	Creates a $HOME/Failed_Over_MQ_Instance/readme.txt (Overwrite if already exists)

4. 	Creates an empty Lock File - $HOME/Failed_Over_MQ_Instance/FILE_Lock.txt

5.	Logs the all activity {Failover activity on this server} with time stamp into a file for
	later review.
	
	FileName - $HOME/Failed_Over_MQ_Instance/Activity_trail.txt

6. 	If you have to stop MQ for any reason, stop this process first. Code underneath
	
	After process - StartStandby.sh is stopped,

	Failover all MI QMgrs 		[endmqm -s QMgrName]

	Stop All Orphaned MI QMgrs      [endmqm -x QMgrName]

	Stop SI QMgrs 			[endmqm -i QMgrName]

	Check process running under user - mqm (Ideally, there shouldn't be any)

7.	StartStandby.sh acts only on QMgr with STATUS(Running elsewhere).
	It will not touch QMgr with any other status

8.	StartStandby.sh polls/checks every 20 seconds. You can edit that in script by altering the Polling_Interval_Value variable value
