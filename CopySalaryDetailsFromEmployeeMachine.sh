#!/bin/bash

#script to copy the necessary file from client machines to admin machine 

DATE=$(date +'%d_%m_%Y')
MAIN_DIR_LOCATION=~/Desktop/linux_exercises/scripting/SalaryAutomation
declare -a salaryInfofileLocations  #an array to store location where copied files are saved 

#reading each line of user info( username, ipaddress ) and copying the  salary info file located in remote machine to admin machine.
while IFS=":" read username ipAddress ; do
	#copying the file and saving the error to $error variable
	error=$(scp -q $username@$ipAddress:~/data/salary/${username}_${DATE}.csv $MAIN_DIR_LOCATION/SalaryInfo/$username/ 2>&1 > /dev/null)
	
	#checking if scp command executed successfully
	if [[ $? == 0 ]]; then
		salaryInfofileLocations+=("$MAIN_DIR_LOCATION/SalaryInfo/$username/${username}_${DATE}.csv")
		echo "$(date +'%d-%m-%Y %H:%M:%S')	${username}_${DATE}.csv file of $username@$ipAddress successfully copied to admin" >> $MAIN_DIR_LOCATION/Activity.log
	else 
		echo "$(date +'%d-%m-%Y %H:%M:%S')	attempt to copy monthly salary file from $username@$ipAddress was unsuccessful: $error" >> $MAIN_DIR_LOCATION/error.log
	ssh -n $username@$ipAddress 'notify-send "Error copying salary details" " ~/data/salary/${username}_${DATE}.csv file is not available.Please check into this ASAP and inform the status to the payroll manager"'	
	fi
	
done < "$MAIN_DIR_LOCATION/UserConnections.txt"


#reading data from copied files and storing in db and creating salary scripts and salary report
if [[ "${#salaryInfofileLocations[@]}" == "0" ]]; then
	echo "$(date +'%d-%m-%Y %H:%M:%S')	program stopped creating salary slips due to the unavailability of any successful salary info file copies" >> $MAIN_DIR_LOCATION/error.log
	exit 1
fi
source $MAIN_DIR_LOCATION/Read_store_data.sh 
readSalaryData		#execute function

source  $MAIN_DIR_LOCATION/Salary_Report.sh
loadMonthlySalaryDetails 	#execute function









