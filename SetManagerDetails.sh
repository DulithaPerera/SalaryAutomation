#!/bin/bash

#bash script to add a new manager to the salary slip automation service

#main location of files
MAIN_DIR_LOCATION=~/Desktop/linux_exercises/scripting/SalaryAutomation

#function to update manager name and email
function updateManager {
	
	echo -n "enter the Manager name:"
				read -e managerName
				managerEmail=
				until [[ $managerEmail =~ .*@.+ ]]; do
					echo -n "enter manager email address:"
					read -e managerEmail
					echo "Please enter a valid email address"
				done
				
	echo "$managerName:$managerEmail" > $MAIN_DIR_LOCATION/ManagerDetails.txt

	#loggin
	if [[ $? != 0 ]]; then
		echo "$(date +'%d-%m-%Y %H:%M:%S')	Successfully updated Manager failed" | tee -a $MAIN_DIR_LOCATION/error.log
	fi
	echo "$(date +'%d-%m-%Y %H:%M:%S')	Successfully updated Manager Details" | tee -a $MAIN_DIR_LOCATION/Activity.log
	echo "Manager Name: $managerName"
	echo "Manager Email: $managerEmail"
}


#check if a record is available already
currentDetails=$(grep ".*:.*" $MAIN_DIR_LOCATION/ManagerDetails.txt)

if [[ -n "$currentDetails" ]]; then 
	IFS=":" read managerName managerEmail <<< $currentDetails 
	echo "current Manager Details:"
	echo "Manager name: $managerName"
	echo "Manager Email: $managerEmail"
else
	echo "currently no manager name or email is set"
fi 

echo -n "do you wish to update Manager name and email :(y/n)"
read -e answer
case $answer in
	y|Y)	updateManager #execute function
			;;
			
	n|N)	exit
			;;
			
	*)		echo "invalid input. Please Try again"
			exit
			;;
esac




















