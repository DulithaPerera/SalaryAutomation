#!/bin/bash

# this script contains the code and functions related to the following tasks
# 		1. readSalary details from the copied files
# 		2. create salary slips
# 		3. store the salary information in the db 'Salary_Details'
#		4. send SalarySlips via email to individuals
#		5. create Salary Report for the month

#function reads data from each file
function readSalaryData {
	
	for i in "${salaryInfofileLocations[@]}"; do
		IFS="," read empId name email basicSalary otHrs otRate transportAllowance deductions < "$i"
			storeInDb		  #execute function
			  
	done
}

#function to store details in a mysql db
function storeInDb {
	id=$(mysql -h 127.0.0.1 -u root -ss -e "select EmpId from Salary_Details.Employees where EmpName='$name'")
	if [[ "$empId" != "$id" ]]; then
		echo "$(date +'%d-%m-%Y %H:%M:%S')	Saving data in database Failed: $empId and $name are not the correct pair in $i" >> ${MAIN_DIR_LOCATION}/error.log
		return 1
	fi
	Date=$(date +'%Y-%m-%d')
	error=$(mysql -h 127.0.0.1 -u root -ss -e	"insert into Salary_Details.Salaries values(null, '$empId', '$basicSalary', '$otHrs', '$otRate', '$transportAllowance', '$deductions', '$Date', '$email')" 2>&1 > /dev/null)

	
	if [[ $? != 0 ]]; then
		echo  "$(date +'%d-%m-%Y %H:%M:%S')	Saving data in database Failed: for $i : $error" >> ${MAIN_DIR_LOCATION}/error.log
		return 1
	fi
	echo "$(date +'%d-%m-%Y %H:%M:%S')	info of $i was successfully saved in the database" >> ${MAIN_DIR_LOCATION}/Activity.log
	
	createSalarySlip #execute the function
	
}

#individual salary slip generation
function createSalarySlip {
	#salary calculations
	otPayment="$(bc -l <<< $otHrs*$otRate)"
	total="$(bc -l <<< $basicSalary+$otPayment+$transportAllowance-$deductions)"
	
	#creating a directory by the date to store the salary slips relevant to that date
	mkdir -p $MAIN_DIR_LOCATION/SalarySlips/$DATE
	echo "
		<html>
			<header>
				<title>Salary Slip - $name - $DATE</title>
			</header>
			<body>
				<h2>Salary Slip - $name - $DATE</h2>
				
				<table border='1'>
				
					<tr style='text-align:center'>
						<td rowspan='3' colspan='4' style='background-color:#6B8E23'></td>
						<td rowspan='2' colspan='6' style='vertical-align:center; text-align:center'><h2>SALARY SLIP</h2></td>
						<td rowspan='3' colspan='4' style='background-color:#6B8E23'></td>
					</tr>
					<tr></tr>				
					<tr style='text-align:center'>
						<td colspan='6'>$(date +'%B %Y')</td>
					</tr>
					<tr style='text-align:left'>
						<td colspan='4'>Name</td>
						<td colspan='4'>: $name</td>
						<td colspan='6' rowspan='4' style='background-color:#6B8E23'></td>
					</tr>
					<tr style='text-align:left'>
						<td colspan='4'>Employee ID</td>
						<td colspan='4'>: $empId</td>
					</tr>					
					<tr>
						<td colspan='8' rowspan='2'></td>
					</tr>
					<tr></tr>
					<tr style='background-color:#6B8E23; text-align:center'>
						<td colspan='8'>Description</td>
						<td colspan='3'>Earnings</td>
						<td colspan='3'>Deductions</td>
					</tr>
					<tr>
						<td colspan='8' style='text-align:left'>Basic Salary</td>
						<td colspan='3' style='text-align:right'>$basicSalary</td>
						<td colspan='3'></td>
					</tr>					
					<tr>
						<td colspan='8' style='text-align:left'>OT Payment <br>
							 - OT Hrs x OT Rate	   <br>	
							   $otHrs x $otRate 
						</td>
						<td colspan='3' style='text-align:right'>$otPayment</td>
						<td colspan='3'></td>
					</tr>					
					<tr>
						<td colspan='8' style='text-align:left'>Transport Allowance</td>
						<td colspan='3' style='text-align:right'>$transportAllowance</td>
						<td colspan='3'></td>
					</tr>					
					<tr>
						<td colspan='8' style='text-align:left'>Deductions</td>
						<td colspan='3' style='text-align:right'></td>
						<td colspan='3' style='text-align:right'>$deductions</td>
					</tr>
					<tr>
						<td colspan='8' style='text-align:left'>Total</td>
						<td colspan='6' style='text-align:right'>$total</td>
						
					</tr>
					<tr>
						<td colspan='4'>Payment Date</td>
						<td colspan='4'>: $(date +'%d/%m/%Y')</td>
						<td colspan='6' style='background-color:#6B8E23'></td>
					</tr>
					
				</table>	
			</body>
		
		</html>" > ${MAIN_DIR_LOCATION}/SalarySlips/${DATE}/${name}_${DATE}_SalarySlip.html
		if [[ $? != 0 ]]; then
			echo "$(date +'%d-%m-%Y %H:%M:%S')	${name}_${DATE}_SalarySlip.html creation failed" >> ${MAIN_DIR_LOCATION}/error.log
			return 1
		fi
		echo "$(date +'%d-%m-%Y %H:%M:%S')	${name}_${DATE}_SalarySlip.html successfully created" >> ${MAIN_DIR_LOCATION}/Activity.log

		sendMail #execute function		
}

function sendMail {
	error=$(mail -s "Salary Slip for month ended $(date +'%Y/%m/%d')" --content-type=text/html -A ${MAIN_DIR_LOCATION}/SalarySlips/${DATE}/${name}_${DATE}_SalarySlip.html $email <<< $(printf "Dear $name, /n	Please find the below attached your Salary Slip for the month ended $(date +'%Y/%m/%d') /n Best Regards, /n Management.") 2>&1 /dev/null )
	if [[ "$?" != 0 ]]; then
	echo "$(date +'%d-%m-%Y %H:%M:%S')	mailing ${name}_${DATE}_SalarySlip.html to $email failed : $error" >> ${MAIN_DIR_LOCATION}/error.log
	return 1
fi
echo "$(date +'%d-%m-%Y %H:%M:%S')	${name}_${DATE}_SalarySlip.html successfully mailed to $email" >> ${MAIN_DIR_LOCATION}/Activity.log
}









