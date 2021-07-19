#!/bin/bash

MAIN_DIR_LOCATION=~/Desktop/linux_exercises/scripting/SalaryAutomation

#obtain the month and year of the desired report
answer=true
while $answer; do
	echo -n "enter the month and year of the requesting report: ex 2020 10>"
	read year month

	report=$(ls "$MAIN_DIR_LOCATION/SalaryReports" | grep "$year-$month") 

	if [[ -n $report ]]; then
		google-chrome ~/Desktop/linux_exercises/scripting/SalaryAutomation/SalaryReports/$report &
		#exit
	else
		echo "there is no report for the reauired month and year"
	fi
	
	echo -n "do you wish to try again (y/n)"
		read -e selection
		
		case $selection in
			y|Y)	answer=true
					;;
			n|N)	answer=false
					;;
			*)		echo "invalid option"
		esac
done
