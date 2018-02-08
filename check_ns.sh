#=====  FUNCTION  =============================================================
#          NAME:  CHECK DOMAIN NS
#   DESCRIPTION:  Using Linux dig command (bind-utils)
#    PARAMETERS:  HOST FILE (contain list of domain within one column formation)
#       RETURNS:  RESULT FILE (output on the current directory)
#         USAGE:  sh script.sh your_input_file
#        AUTHOR:  IVAN
#==============================================================================
#!/bin/bash

touch ./result ; chmod +x ./result      #tao file ket qua rong

for domain in $(cat ./$1)               #doc domain tu file
do
        host -t ns ${domain} > /dev/null 2>&1           #kiem tra co phai la non-existing domain
        if [ $? -eq 0 ]
        then
                echo -e "${domain} has NS as below: \n`host -t ns $domain | awk '{print $4}'`\n" >> ./result
        else
                echo "${domain} is non-existing Internet Domain Name" >> ./result
        fi
done
