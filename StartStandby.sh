#! /bin/bash

##########################################################################################################
#   Designed to run as a daemon
#   Puts failed-over Multi-Instance QMgrs - with status - "Running Elsewhere" into Standby Mode.
#   Tested on rpm based Linux 6 and 7 [RHEL and CentOS]
#   Please go through README.md to understand more.
#   
#   by -
#
#   Raman Kathpalia
#   IBM MQ SME
###########################################################################################################

Polling_Interval_Value=''
TIMESTAMP=''
Polling_Interval_Value=20
TIMESTAMP=`date "+%Y%h%d_%H_%M_%S"`

if [[ -z grep "mqm" /etc/group | grep "$USER" ]]

        echo "

	$USER must be in mqm group

        "
           exit 10

 fi

Set_MQ_Variable() {					# Instantiate these variables

Activity_Logs=$HOME/Failed_Over_MQ_Instance

export FILE_Lock=${Activity_Logs}/FILE_Lock.txt

ACTIVITY_FILE=${Activity_Logs}/Activity_trail.txt

MQ_INSTANCE_ELSEW=$(dspmq -o all | \
        sed '/(Running elsewhere)/!d' | \
        awk -F '[()]' '{print $2}')

}

Set_MQ_Variable				# Source MQ Variables


mkdir -p ${Activity_Logs}		# Create dir if it doesn't exits



if [[ ! -f $FILE_Lock ]]; then		# Create an empty lock file during process initiation if one doesn't exits

 	touch $FILE_Lock
fi


Start_Standby() {

Set_MQ_Variable						# Source MQ Variable defined above

if [[ -n ${MQ_INSTANCE_ELSEW[@]} ]]; then		# If failed over Queue-Manager are found with status - (Running elsewhere), start them in standby mode

  for QMgr in ${MQ_INSTANCE_ELSEW[@]}; do
	
    echo " 

*********************************************************************
$TIMESTAMP : Initiating $QMgr in Standby.
*********************************************************************
     " >> $ACTIVITY_FILE				#CAPTURE ANY ACTIVITY PERFORMED WITH TIMESTAMP

	strmqm -x $QMgr	>> $ACTIVITY_FILE 2>&1		
  done

fi

}

	while [ -e $FILE_Lock ]; 
		do Start_Standby; sleep $Polling_Interval_Value; done &	# Keep Checking
