# Author: Mike Karenke - Shaker Heights City Schools


# Both Functions below Courtesy of Steve Konig (https://activedirectoryfaq.com/2017/08/creating-individual-random-passwords/)

function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

# Set credentials variable needed for email auth
$credentials = New-Object Management.Automation.PSCredential "EmailUserNameHere”), (“PasswordForEmailHere” | ConvertTo-SecureString -AsPlainText -Force)

# Import AD Module 
import-module ActiveDirectory -ErrorAction SilentlyContinue

# Name CSV Variable. Prevents additional typing
$Imported_csv = import-csv -ErrorAction SilentlyContinue "CSVPathHere"

#Remove Prior Night AccountCreation.csv File
Remove-Item C:\Scripts\NewEmployeeAccounts.csv
Remove-Item C:\Scripts\GAPS_Reset.csv

#Create CSV File and Establish Column Headers for Nightly GAPS Password Reset for New Employee Accounts
New-Item C:\Scripts\GAPS_Rest.csv -ItemType "file"
Write-Output Username","Password | Out-File C:\Scripts\GAPS_Reset.csv

#Begin Import Loop  
Try {
$Imported_csv | ForEach-Object {

#-----------------------------------------------
# Name All Variables
#-----------------------------------------------
#Basic variables for minimal account info. Feel free to add as many as you want. In our example, the username is "lastname_firstinitial". If it finds a duplicate account, it will append the next letter in firstname to the username.
#This is not one size fits all. You will need to play around with the variables to fit your environment. SorF is to designate between staff of faculty in our environment
$FirstName = $_.FirstName 
$LastName = $_.LastName
$StaffName = $LastName + ", " + $Firstname
$Building = $_.Building
$Title = $_.Title
$SorF = $_.SorF


#Generate Username and Perform Validity Checks. Once Username is found; Set to lowercase
$Username = $LastName +"_" + $Firstname.Substring(0,1)
if (dsquery user -samid $Username) {$Username = $LastName +"_" + $Firstname.Substring(0,2)}
if (dsquery user -samid $Username) {$Username = $LastName +"_" + $Firstname.Substring(0,3)}
$Username = $Username.ToLower()

#Generate Random Password Based on Provided Data. You can edit the data here to remove or add certain characters
$password = Get-RandomCharacters -length 5 -characters 'abcdefghikmnoprstuvwxyz'
$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 1 -characters '1234567890'
$password = Scramble-String $password

# Assign Server Variable based on Building (this is if you have a user path defined in AD for a personal network drive)
If ($Building -eq "Building 1") {$Server = "Building 1 server path"}
ElseIf($Building -eq "High School")  {$Server = "HSSERVER"}
ElseIf($Building -eq "Middle School") {$Server = "MSSERVER"}
Else {$Server = $Building}

# Set BuildingCode. Useful for Description and Dist. Lists
If ($Building -eq "Administration") {$BuildingCode = "ADM"}
ElseIf($Building -eq "High School") {$BuildingCode = "HS"}
ElseIf($Building -eq "Middle School") {$BuildingCode = "MS"}
# You’ll need to edit this part to suit your environment. We use the first two letters of the building name outside of the use cases above.
Else {$BuildingCode = $Building.Substring(0,2)}
$BuildingCode = $BuildingCode.ToUpper()

#-----------------------------------------------
# Account Creation
#-----------------------------------------------

# Account Creation with Username Check
if (dsquery user -samid $Username) {"User " + $Username + " Already Exists"}
Else {New-ADUser -Name $StaffName -SamAccountName $Username -UserPrincipalName ($Username + "@domainsuffix") -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -ChangePasswordAtLogon $true -Description "$BuildingCode - $Title" -Enabled 1 -GivenName $Firstname -Surname $Lastname -DisplayName $StaffName -EMailAddress ($Username + "@emaildomain") -Department $Building -Title $Title -HomeDrive "Z" -HomeDirectory ("\\" + $Server + "\PATHHERE\" + $Username)
      Write-Output $Username","$Password | Out-File C:\Scripts\GAPS_Reset.csv -Append
     }

#-----------------------------------------------
# Account Created. Now Add to Appropriate Groups
#-----------------------------------------------

# Add User to Everyone Dist. List     
Add-ADGroupMember -Identity "ALL EMPLOYEES DIST LIST" -Members $Username

# Add User to Building Specific Dist. List
If ($Building -eq "Administration") {Add-ADGroupMember -Identity "Admin-Building Dist List" -Members $Username}
ElseIf ($Building -eq "Learning Center") {Add-ADGroupMember -Identity "HS-$SorF Dist List" -Members $Username}
ElseIf ($Building -eq "Transportation") {Add-ADGroupMember -Identity "District-Transportation Department Dist List" -Members $Username}
Else {Add-ADGroupMember -Identity "DL-$BuildingCode-$SorF" -Members $Username}

# **WARNING** Ugly Area Ahead. Add Users to AD Groups Based on Title

If (($Title -eq "Administrative Assistant") -or ($Title -eq "Accounting Specialist") -or ($Title -eq "Senior Administrative Assistant")) {Add-ADGroupMember -Identity "ADGroupNameHere" -Members $Username}

If ($Title -eq "Head Custodian") {Add-ADGroupMember -Identity "Head Custodians" -Members $Username}
#ETC, ETC, You may add any other groups as you please for your environment



#-----------------------------------------------
# Move User to Appropriate OU. THIS AREA WILL NEED TO BE MODIFIED TO SUIT YOUR AD STRUCTURE.
#-----------------------------------------------

# Retrieve DN of User. Need this to move user account.
$UserDN = Get-ADUser $Username -Properties DistinguishedName | Select-Object -ExpandProperty DistinguishedName

# Specify Target OU Based on Building and SorF Variable
$TargetOU = "OU=" + "$Building $SorF" + "," + "OU=" + $Building + "," + "DN OF DESIRED OU" 

# Move User to Specified Target OU. These are for a few special use cases in our environment.
If ($Building -eq "Administration") {Move-ADObject -Identity $UserDN -TargetPath "DN OF DESIRED OU"}
ElseIf (($Building -eq "Transportation") -or ($Building -eq "Service Center") -or ($Building -eq "Grounds")) {Move-ADObject -Identity $UserDN -TargetPath "FQDN OF DESIRED OU"}
Else {Try {Move-ADObject -Identity $UserDN -TargetPath $TargetOU} Catch {Write-Output "[ERROR] Unable to Move User $Username to $TargetOU as it does not exist"}}
#etc etc. You may add as many as you'd like

#-----------------------------------------------
# Output to Text File
#-----------------------------------------------

# Write Data to File
Write-Output ("Name: " + $Firstname + " $Lastname")
Write-Output ("Title: " + $Title)
Write-Output ("UN: " + $Username)
Write-Output ("PW: " + $Password)
Write-Output ("Email: " + $Username + "@EMAILDOMAIN")
Write-Output " "

# Three Second Delay to Allow AD to Propagate to Prevent Account Errors. Needed If Multiple Employees with Same Last Name in File
Start-Sleep -Seconds 3

# End Loop and Write all Output to Specified Log Location
} | Out-File C:\Scripts\Logs\EmployeeCreationErrorLog.txt  -append

# Send Email to Specified Users with Creation Log Attached
Send-MailMessage -To "Admin <admin@emaildomain>" -Cc "Jim Smith <smith_j@emaildomain.org>" -From "No Reply <no-reply@emaildomain>" -SmtpServer "smtp server address" -Credential ($credentials) -Subject "New Employee Accounts" -Body "Attached is a file containing all newly created accounts. `n `n Please keep in mind that while these users will be able to log into Google services if they wish to change their password they will need to do so on a District Windows based computer. `n `n Thank You, `n  IT DEPT " -Attachments "C:\Scripts\Logs\EmployeeCreationErrorLog.txt"

# Account Creation Complete. Remove CSV to prevent duplicate accounts.
Remove-Item C:\Scripts\NewEmployeeAccounts.csv

# Error Checking to Verify that CSV Exists before attempting to run.

} Catch {

$Date = Get-Date -Format "dddd MM/dd/yyyy"
Write-Output "$Date - CSV Not Found" | Out-File C:\Scripts\Logs\EmployeeCreationErrorLog.txt -Append}
