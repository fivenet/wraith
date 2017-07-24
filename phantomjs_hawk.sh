#!/bin/bash
### Watch for running phantomjs processes, and kill any that are too old (hung)

IntervalTime=60
### Initial process snapshot
PrevPIDList=`ps -e | grep phantomjs | grep -v $$ | cut -c1-6`

while true
do
    echo "Sleeping for ${IntervalTime} seconds...."
    sleep ${IntervalTime}
    ### Capture a fresh process list (exclude ourself)
    PIDList=`ps -e | grep phantomjs | grep -v $$ | cut -c1-6`

    KillCount=0
    RunCount=0
    for PID in ${PIDList};
    do
        if [ `echo ${PrevPIDList} | grep ${PID} | wc -l` -gt 0 ]
        then
            ### First process being killed gets a nice label
            [ ${KillCount} -eq 0 ] && echo -n "  Killing stale phantomjs PIDs: "
            ### But first and subsequent processes just print the PID without a newline
            echo -n "${PID} "

            KillCount=`expr ${KillCount} + 1`
            kill ${PID}
        else
            ### If its still running, then count that so we know when we can exit
            [ "`ps -e | grep ${PID}`" != "" ] && RunCount=`expr ${RunCount} + 1`
        fi
    done
    PrevPIDList=${PIDList}

    ### Print a summary line of counts so you can keep an eye on it
    [ ${KillCount} -gt 0 ] && echo " "
    echo "  Killed ${KillCount} stale phantomjs processes, ${RunCount} still running."
    ### DEBUG echo "${PIDList}"
    echo " "

    ### If nothing was killed and nothing is still running, then we can exit
    if [ `expr ${RunCount} + ${KillCount}` -eq 0 ] 
    then
        echo "All phantomjs proccesses have exited.  Terminating monitor."
        break
    fi
done

