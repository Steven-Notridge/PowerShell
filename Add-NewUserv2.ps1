# Script created by @Steven-Notridge - https://github.com/Steven-Notridge
Import-Module ActiveDirectory
# $ErrorActionPreference = "SilentlyContinue"

# Prompt for user template, or user that's being targetted for the required information.
$Template = Read-Host -Prompt "What is the name of the user being used as a template? i.e John.Smith"

# Creating Variable for checking user details later.
$SeekTemplate = Get-ADUser $Template -Properties City, Company, Department, Distinguishedname, Manager, Memberof, ScriptPath, Title, UserPrincipalName

# Prompt for new users name and assign it to variable for easier referencing.
$NewUserFirst = Read-Host -Prompt "What is the First name of the NEW user?"
$NewUserLast = Read-Host -Prompt "What is the Last name of the NEW user?"

# Set password for new user, required before the actual creation.
$Password = Read-Host -Prompt "Please type in the password you would like to set for the new user." -AsSecureString

# Ask for the domain alias, I'd like to automate this in the future but I think it's too specific to do that and can vary too much.
# You could always just change the entry where $Alias is used, and remove these three lines.
$Alias = Read-Host -Prompt "What is Alias for the user? e.g yuri.co.uk"

# The next section is creating a custom powershell object for it to collect all the information we're going to need in a minute.
# Another thing to note, is the $SeekTemplate.City for example, is only because we specified it in the command above. (Line 9)

$Attributes = [pscustomobject]@{
    Enabled = 1
    ChangePasswordAtLogon = $false
    Department = $SeekTemplate.Department
    City = $SeekTemplate.City
    DisplayName = "$NewUserFirst $NewUserLast"
    GivenName = "$NewUserFirst"
    Manager = $SeekTemplate.Manager
    MemberOf = $SeekTemplate.MemberOf
    Surname = "$NewUserLast"
    Title = $SeekTemplate.Title
    Name = "$NewUserFirst $NewUserLast"
    AccountPassword = $Password
    SamAccountName = "$NewUserFirst.$NewUserLast"
    UserPrincipalName = "$NewUserFirst.$NewUserLast@$Alias"
}

# The below is required to make the OU location easier to copy. It deletes the first part of the DN that is associated with the username.
$Path = $SeekTemplate.Distinguishedname.split(",",2)[1]

# The below is just to display the properties, I've preferred to have all the details listed, simply add a hash before it if you do not wish to see it.
$Attributes

# Actual account creation. The below uses the information copied from the commands above, and -Path allows it to copy the OU location.
$Attributes | New-ADUser -Path $Path

# Now we add the Security Groups, because for some reason it's easier to do it this way. Other methods didn't really seem to work. 
Get-ADUser -Identity $Template -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members "$NewUserFirst.$NewUserLast"

# Comments - It is very fussy about the length of the username given and will provide an error. The internet seems to state that it was 20 characters in total. 
