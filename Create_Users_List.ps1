
#This script creates a user account and puts it in the correct OU. 

Import-Module activedirectory #This allows you to work with the activedirectory module.

$temp_password = Read-Host 'Enter the temp password for the user account(s)' #This gets the temp password.
 
#'ConvertTo-SecureString', Converts plain text or encrypted strings to secure strings.
#'-AsPlainText', Specifies a plain text string to convert to a secure string.The text is encrypted for privacy 
#and is deleted from computer memory after it is used. 
#'-Force', Confirms that you understand the implications of using the AsPlainText parameter and still want to use it.
$password = ConvertTo-SecureString $temp_password -AsPlainText -Force 
Echo " "

#Get the file path of the list with the names.
#Put the text file in the same directory as script
echo 'Example .\names.text'
$file_path = Read-Host 'Enter the name of the file'
echo " "

$user_on_list = Get-Content $file_path #Gets the contents of the text file. 

$get_ou = Read-Host 'Enter the OU the user(s) will be stored in' #Gets user input about which ou users will be stored in. 
echo " "

#If a username is already in use. If it is, then return the number that should be appended 
# the end of the name. Else, return an empty string (example: phill, phill1, phill2 etc...)

function verifyUsername($userName){
	$i = 1
	
	#Check if the username is taken.
	if(userNameTaken($userName) -eq $True){
		while(userNameTaken($userName + $i) -eq $True){
			$i++
		}
	} else {
		return ""
	}
	return $i
}  

# Check to see if username already exists
function userNameTaken($userName) {
    $test1 = Get-ADUser -Filter { userPrincipalName -eq $userName } 
    $test2 = Get-ADUser -Filter { samAccountName -eq $userName }

    if($test1 -eq $Null -and $test2 -eq $Null) {
        return $False
    } else {
        return $True
    }
}

#'ForEach', reads an entire collection of items and foreach item, runs some kind of code.
foreach($n in $user_on_list){

#'Split', operator splits one or more strings into substrings. It splits them in the " ". 
#'ToLower', converts a string into all lowercase. 
#'Substring.()', Return part of a longer string.

    $firstName = $n.Split(" ")[0].ToLower()
	$initial = $firstName.Substring(0, 1)
	$lastName = $n.Split(" ")[1].ToLower()
	$accountNumber = verifyUsername($initial + $lastName)
	
	$userName = ($initial + $lastName + $accountNumber)
	
	New-AdUser -Name $userName  `
	           -GivenName $firstName `
			   -Surname $lastName `
			   -UserPrincipalName $userName `
			   -Path "ou=$get_ou,$(([ADSI]`"").distinguishedName)" `
			   -AccountPassword $password `
               -Enabled $True `
               -ChangePasswordAtLogon $True		   
}










