#=====  FUNCTION  =============================================================
#          NAME:  ALIVE/DEAD PING
#   DESCRIPTION:  Using Linux ping command
#    PARAMETERS:  HOST FILE (contain list of domain/ip into one column format)
#       RETURNS:  RESULT FILE (output on the current directory)
#        AUTHOR:  IVAN
#==============================================================================


#!/bin/bash

clear

touch ./RESULT ; chmod +x ./RESULT

for var in $(cat ./$1)
do
	ping -q -c2 -s8 $var > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo $var "OK" >> ./RESULT
	else
		echo $var "FAIL" >> ./RESULT
	fi
done
