#!/bin/bash

#this script conatins the following functions
#	1. Creating the Overall salary Report 
#	2. Mailing the Report to manager


#function to retrive details from the database
function loadMonthlySalaryDetails {

	#loads salary data for the day from the database
	result=$(mysql -h 127.0.0.1 -P 3306 -u root -ss -e "select Salaries.EmpId, Employees.EmpName, Salaries.BasicSalary, Salaries.OTHrs, Salaries.OTRate, Salaries.TransportAllowance, Salaries.Deductions 
	from Salary_Details.Salaries 
	inner join Salary_Details.Employees on Salaries.EmpId = Employees.EmpId 
	where Date = '2020-11-03';")
	
	#logging
	if [[ "$?" != 0 ]]; then
		echo "$(date +'%d-%m-%Y %H:%M:%S')	Retrieving salary details for the date $(date +'%d-%m-%Y') failed: $result" >> ${MAIN_DIR_LOCATION}/error.log
			return 1
	fi
	echo "$(date +'%d-%m-%Y %H:%M:%S')	Retrieving salary details for the date $(date +'%d-%m-%Y') successful" >> ${MAIN_DIR_LOCATION}/Activity.log
	
	createSalaryReport 		#execute function
}

#creating the salary report structure
function createSalaryReport {
	
	echo "
		<html>
			<head>
				<title>Monthly Salary Report for the month ended on $DATE</title>
			</head>
			<body border='1'>
				<h2>Report on the Monthly Salaries of all Employees for the month ended on $DATE </h2>
				<br>
				<br>
				
				<table>
					<tr>
						<th>Employee ID</th>
						<th>Name</th>
						<th>Basic Salary (Rs)</th>
						<th style='color:red'>OT Hours</th>
						<th style='color:#FFBF00'>Total Allowances (Rs)</th>
						<th>Deductions (Rs)</th>
						<th style='color:green'>Net Pay (Rs)</th>
					</tr>
					" > ${MAIN_DIR_LOCATION}/SalaryReports/${DATE}_SalaryReport.html
					
	#printing the salary details of each employee
	while read empId name basic otHrs otRate transportAllowance deductions; do
		totalAllowances=$(bc  <<< $transportAllowance+$otHrs*$otRate )
		netPay=$(bc -l <<< $basic+$totalAllowances-$deductions)
	echo "<tr>
				<td>$empId</td>
				<td>$name</td>
				<td>$basic</td>
				<td style='color:red'>$otHrs</td>
				<td style='color:#FFBF00'>$totalAllowances</td>
				<td>$deductions</td>
				<td style='color:green'>$netPay</td>
			  </tr>
			" >> ${MAIN_DIR_LOCATION}/SalaryReports/${DATE}_SalaryReport.html
		
	done <<< $result
				
	echo "  	</table>
		 	
			</body>
		</html>
		 " >> ${MAIN_DIR_LOCATION}/SalaryReports/${DATE}_SalaryReport.html
		 
	#logging
	if [[ "$?" != 0 ]]; then
		echo "$(date +'%d-%m-%Y %H:%M:%S')	Creating ${DATE}_SalaryReport.html Report failed" >> ${MAIN_DIR_LOCATION}/error.log
		rm ${MAIN_DIR_LOCATION}/SalaryReports/${DATE}_SalaryReport.html #if the file is build partially the currupted file is removed
			return 1
	fi
	echo "$(date +'%d-%m-%Y %H:%M:%S')	Successfully created ${DATE}_SalaryReport.html" >> ${MAIN_DIR_LOCATION}/Activity.log
	
	mailSalaryReport #execute function
}

function mailSalaryReport {
	#get manager's name and email address 
	IFS=":" read managerName managerEmail < "$MAIN_DIR_LOCATION/ManagerDetails.txt"
	
	error=$(mail -s "Salary Report for the month ended $(date +'%Y/%m/%d')" --content-type=text/html -A ${MAIN_DIR_LOCATION}/SalaryReports/${DATE}_SalaryReport.html $managerEmail <<< $(printf "Dear $managerName, /n Please find the below attachment of the Report on Salaries of employees for the month ended $DATE /n Best Regards") 2>&1 /dev/null )
	
	#logging
	if [[ "$?" != 0 ]]; then
		echo "$(date +'%d-%m-%Y %H:%M:%S')	mailing ${DATE}_SalaryReport.html to Manager at $managerEmail failed : $error" >> ${MAIN_DIR_LOCATION}/error.log
		return 1
 	fi
 	echo "$(date +'%d-%m-%Y %H:%M:%S')	successfully mailed ${DATE}_SalaryReport.html to Manager at $managerEmail." >> ${MAIN_DIR_LOCATION}/Activity.log
}



































