# List the companies/vendors you don't want to show up. 
$Companies = "Microsoft Corporation", "Intel Corporation", "Python Software Foundation", "Microsoft", "Oracle Corporation", "Microsoft Corporations", "NVIDIA Corporation", "Intel", "CPUID, Inc.", "Docker Inc.", "Mozilla", "Nord Security", "Samsung Electronics Co., Ltd.", "RealVNC Ltd", "VideoLAN"
$Links = "https://help.steampowered.com/", "http://support.steampowered.com/"

# Create the array
$FilteredReg = @()

# Search the registry
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

ForEach ($obj in $InstalledSoftware) {
    # Set variables for later
    $Displayname = $obj.GetValue('DisplayName')
    $Vendor = $obj.GetValue('Publisher')
    $HelpLink = $obj.GetValue('HelpLink')

    if ($Vendor -notin $Companies) {

        if ($HelpLink -notin $Links) {

            # Using this because some of the registries were empty.
            if ([bool]$Vendor -ne $False) {

                # Add those new values into an Array
                $FilteredReg += New-Object -Type PSObject -Property @{
                    Name   = $Displayname
                    Vendor = $Vendor
                }
            }
        }
    }
}

# Display information and sort
$FilteredReg | Select-Object Name, Vendor | Sort-Object Name