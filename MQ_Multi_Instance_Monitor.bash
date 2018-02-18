#!/bin/bash

##########################################################################################################
#   MQ_Multi_Instance_Monitor.bash is an advanced version of StartStandby.bash. This program is designed to run as a daemon|process
#
#   What does this process do?
#   Puts failed-over Multi-Instance QMgrs - with status - "Running Elsewhere" into Standby Mode.
#   Tested on rpm based Linux 6 and 7 [RHEL and CentOS]
#   Please go through MQ_Multi_Instance_Monitor.readme.md for more information.
#   
#   by -
#
#   Raman Kathpalia
#   IBM MQ SME
#
# Enhancements: Mon Feb 17 2018. 
#
# What is New OR What are the changes from the previous program - StartStandby.bash:
#
# 	1.		Simple start | stop | check Operation. [start | stop | check] Arguments introduced. 
#	2. 		Ease of putting the program to Maintenance mode 
# 	3. 		Single threaded operation. Multi-threaded operation is an overkill. This program doesn't spawns multi-thread
#	4. 		Penguin replaces the cow. This is for lactose intolerant Linux lovers. 
#
###########################################################################################################

# Let's begin:

if [[ -z $(grep "mqm" /etc/group | grep "$LOGNAME") ]]; then		#Check if user is in mqm group

        echo "

	Cannot start 

	$LOGNAME must be in mqm group

        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /o\_   _/o\
    \___)=(___/
	
	Hi there, I'm penguin and you're not in mqm group. 
	
	I know it doesn't rhyme  but that doesn't change the fact!!!
                                             
	Gotta be in mqm group...exiting!!
	
        "
           exit 10

 fi


if [ $# != 1 ]; then							# Only one Argument accepted

  echo "  

  Specify only one argument: 

  USAGE: $0 START | STOP | CHECK

      "

exit 20

fi

Set_MQ_Variable() {								# Box all variables in this module

POLLING_INTERVAL=''								#Unset previous values
TIMESTAMP=''
POLLING_INTERVAL=20                             # <--- This value can be changed. Not advisable to decrease below 10.
FAILOVER_ACTIVITY_DIR=$HOME/MI       		        # <--- This location can be changed
#
TIMESTAMP=`date "+%Y%h%d_%H_%M_%S"`
#
export LOCK_FILE=${FAILOVER_ACTIVITY_DIR}/LOCK_FILE.txt
#
ACTIVITY_FILE=${FAILOVER_ACTIVITY_DIR}/Activity_trail.txt
#
DEFUNCT_QMgr=$(dspmq -o all | \
        sed '/(Running elsewhere)/!d' | \
        awk -F '[()]' '{print $2}')
}

MQ_Multi_Instance_Monitor() {

Set_MQ_Variable									

if [[ -n ${DEFUNCT_QMgr[@]} ]]; then			# If failed over Queue-Manager are found with status - (Running elsewhere), start them in standby mode

  for QMgr in ${DEFUNCT_QMgr[@]}; do
	
    echo " 

*********************************************************************
$TIMESTAMP : Initiating $QMgr in Standby.
*********************************************************************
     " >> $ACTIVITY_FILE						#CAPTURE ACTIVITY PERFORMED; WITH TIMESTAMP

	strmqm -x $QMgr >> $ACTIVITY_FILE 2>&1		

	if [[ $(sed -n '$=' $ACTIVITY_FILE) -gt 3000 ]];then	# Keep a check on Activity log. Roll off very old entries

        sed -i '1,100d' $ACTIVITY_FILE
	
	fi

  done

fi


}


Pollit() {

if [[ -e $LOCK_FILE ]]; then 
	while [ -e $LOCK_FILE ]; 
		do MQ_Multi_Instance_Monitor; sleep $POLLING_INTERVAL; done &	            # Keep polling
else 
	echo "$LOCK_FILE not detected, Exiting without start."
fi

}
#export -f Pollit 


startit(){

Set_MQ_Variable																		# Instantiate variables

mkdir -p ${FAILOVER_ACTIVITY_DIR}										

Run_Status=$(ps -efj | \
	sed '/[M]Q_Multi_Instance_Monitor/!d' | sed -n '$=')

if [[ $Run_Status -gt 2 ]]; then

 	echo "
	Process already Running. 
		 " 																# If Process MQ_Multi_Instance_Monitor is Running, REPORT & exit
	  
    exit 0

elif  [[ $Run_Status == 2 ]]; then 

		if [[ -e $LOCK_FILE ]]; then									#Check if maintenance mode is on

	
			while [[ -e $LOCK_FILE ]];	do MQ_Multi_Instance_Monitor
			sleep $POLLING_INTERVAL; done &
		
				if [[ $? == 0 ]];then

				echo " 
------------------------------------------------------------------------------------------------------------
		Started MQ_Multi_Instance_Monitor Process Manually at `date`
------------------------------------------------------------------------------------------------------------
				
						" | tee -a $ACTIVITY_FILE
				fi


		else

			echo "

------------------------------------------------------------------------------------------------------------
`date`: 

Manual start attempted but Maintenance mode detected.
	
$0 process not started

[touch $LOCK_FILE] to take it out of maintenance mode and Retry.

------------------------------------------------------------------------------------------------------------
						" | tee -a $ACTIVITY_FILE

  		fi
		
fi


}

stopit() {

Set_MQ_Variable

Run_Status=$(ps -efj | \
	grep -iv stop | sed '/[M]Q_Multi_Instance_Monitor/!d')

if [[ -n $Run_Status ]]; then

	rm -f $LOCK_FILE
        echo "
------------------------------------------------------------------------------------------------------------
`date`: 

Stopped MQ_Multi_Instance_Monitor Process Manually.

This can take up to $POLLING_INTERVAL seconds to stop. 

You may kill it for instant gratification.
------------------------------------------------------------------------------------------------------------
						" | tee -a $ACTIVITY_FILE

else 

	echo " MQ_Multi_Instance_Monitor Process Already in Stopped status"

fi

}

checkit(){

Run_Status=$(ps -efj | \
	grep -iv check | sed '/[M]Q_Multi_Instance_Monitor/!d')

if [[ -n $Run_Status ]]; then

	ps -efj | grep -ivE 'check|grep' | \
	grep -E 'MQ_Multi_Instance_Monitor|STIME' | \
	awk '{print $1,$2,$7}' | column -t

elif [[ -z $Run_Status ]]; then
        
		echo " 

		PROCESS MQ_Multi_Instance_Monitor NOT RUNNING

			"

fi

}

##-->ARG=$(echo "$1" | awk '{print tolower($0)}')
ARG=$(echo "${1,,}")

if   [[ $ARG == start ]]; then
	startit
elif [[ $ARG == stop ]]; then
	stopit
elif [[ $ARG == check ]]; then
	checkit
else 

	echo "
	
	Only one valid argument accepted: START | STOP | CHECK

	"
fi
