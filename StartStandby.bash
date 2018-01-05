#!/bin/bash

##########################################################################################################
#   Designed to run as a daemon|process
#   Puts failed-over Multi-Instance QMgrs - with status - "Running Elsewhere" into Standby Mode.
#   Tested on rpm based Linux 6 and 7 [RHEL and CentOS]
#   Please go through README.md for more information.
#   
#   by -
#
#   Raman Kathpalia
#   IBM MQ SME
###########################################################################################################

if [[ -z $(grep "mqm" /etc/group | grep "$LOGNAME") ]]; then

        echo "

	Cannot start 

	$LOGNAME must be in mqm group

ヽ
　 ＼＼ Λ＿Λ
　　 ＼(˘ω˘)
　　　 >　⌒ヽ
　　　/ 　 へ＼
　　 /　　/　＼＼
　　 ﾚ　ノ　　 ヽ_つ
　　/　/
　 /　/|
　(　(ヽ
　|　|、＼
　| 丿 ＼ ⌒)
　| |　　) /
  ノ)    Lﾉ
(_／
	
    Else you continue to see a bashing cat in a weird pose!                                                 
        "
           exit 10

 fi


Set_MQ_Variable() {					# Box all variables in this module

POLLING_INTERVAL=''
TIMESTAMP=''
#
POLLING_INTERVAL=20
TIMESTAMP=`date "+%Y%h%d_%H_%M_%S"`
FAILOVER_ACTIVITY_DIR=$HOME/MI
export LOCK_FILE=${FAILOVER_ACTIVITY_DIR}/LOCK_FILE.txt
ACTIVITY_FILE=${FAILOVER_ACTIVITY_DIR}/Activity_trail.txt

DEFUNCT_QMgr=$(dspmq -o all | \
        sed '/(Running elsewhere)/!d' | \
        awk -F '[()]' '{print $2}')

}

Set_MQ_Variable						# Instantiate Variables

mkdir -p ${FAILOVER_ACTIVITY_DIR}		

Start_Standby() {

Set_MQ_Variable						# Source MQ Variable defined above

if [[ -n ${DEFUNCT_QMgr[@]} ]]; then			# If failed over Queue-Manager are found with status - (Running elsewhere), start them in standby mode

  for QMgr in ${DEFUNCT_QMgr[@]}; do
	
    echo " 

*********************************************************************
$TIMESTAMP : Initiating $QMgr in Standby.
*********************************************************************
     " >> $ACTIVITY_FILE					#CAPTURE ACTIVITY PERFORMED; WITH TIMESTAMP

	strmqm -x $QMgr	>> $ACTIVITY_FILE 2>&1		


	if [[ $(sed -n '$=' $ACTIVITY_FILE) -gt 3000 ]];then	# Keep a check on Activity log. Roll off very old entries

        sed -i '1,100d' $ACTIVITY_FILE
	
	fi


  done

fi



}

	while [ -e $LOCK_FILE ]; 

		do Start_Standby; sleep $POLLING_INTERVAL; done &	            # Keep polling
