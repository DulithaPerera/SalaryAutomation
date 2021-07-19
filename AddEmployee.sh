#!/bin/bash

#bash script to add a new employee to the salary slip automation service

#main location of files
MAIN_DIR_LOCATION=~/Desktop/linux_exercises/scripting/SalaryAutomation

#obtaining username and ipaddress of employee
echo -n "Please enter the username: "
read -e username
echo -n "Please enter the ip address: "
read -e ipAddress
echo -n "Please enter the Employee Id: "
read -e empId


duplicate=$(grep "$username:$ipAddress" $MAIN_DIR_LOCATION/UserConnections.txt)

#checking if username, ipaddress pair already exists
if [[ ! -z $duplicate ]]; then
	echo "$(date +'%d-%m-%Y %H:%M:%S')	This username: $username and ip address: $ipAddress pair already exists." | tee -a $MAIN_DIR_LOCATION/Activity.log 
else
	$(echo "$username:$ipAddress" >> $MAIN_DIR_LOCATION/UserConnections.txt) && mkdir -p $MAIN_DIR_LOCATION/SalaryInfo/$username
	mysql -h 127.0.0.1 -u root Salary_Details <<- EOF
	insert into Employees values("$empId", "$username");
	EOF
	echo "$(date +'%d-%m-%Y %H:%M:%S')	Successfully added new connection $username:$ipAddress" | tee -a $MAIN_DIR_LOCATION/Activity.log
fi

