<#
    Set-OneDriveSharingCapability.ps1
    ------------------------------


    Toggle the sharing capabilities of 
    user OneDrive sites. Allow anonymous
    sharing, guest sharing, or no guest 
    sharing.
#>
cls


function Toggle-SharingCapability () {
    param(
        [Parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()] 
        [System.String] $OneDriveSiteUrl,


        [Parameter(Mandatory)] 
        [ValidateNotNullOrEmpty()] 
        [ValidateSet('NoGuests', 'ExistingGuests', 'NewAndExistingGuests','AnyPerson')] 
        [System.String] $PermitSharingWith
    )


    Write-Output "$OneDriveSiteUrl"
    Write-Output "`t- permit sharing w/ $PermitSharingWith"


    switch ($PermitSharingWith) {
        "NoGuests" {
            Set-SPOSite `
                -Identity $OneDriveSiteUrl `
                -SharingCapability Disabled
        }
        "ExistingGuests" {
            Set-SPOSite `
                -Identity $OneDriveSiteUrl `
                -SharingCapability ExistingExternalUserSharingOnly
        }
        "NewAndExistingGuests" {
            Set-SPOSite `
                -Identity $OneDriveSiteUrl `
                -SharingCapability ExternalUserSharingOnly
        }
        "AnyPerson" {
            Set-SPOSite `
                -Identity $OneDriveSiteUrl `
                -SharingCapability ExternalUserAndGuestSharing
        }
    }
}


try {


    ##  Variable(s)
    [System.String] $Login = "<email_address>"
    [System.Security.SecureString] $PWord = ConvertTo-SecureString -String "<password>" -AsPlainText -Force


    Connect-SPOService `
        -Url https://theiilakesgroup-admin.sharepoint.com `
        -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $PWord)


    Get-SPOSite -IncludePersonalSite $true -Limit ALL `
        | ? { $_.Url -like "*/personal/*" } `
        | Select Title, Url, SharingCapability `
        | % {


        ##  https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/set-sposite?view=sharepoint-ps
        Toggle-SharingCapability `
            -OneDriveSiteUrl "$($_.Url)" `
            -PermitSharingWith AnyPerson
    }
}
catch [Exception] {
    Write-Error $_.Exception.Message
}
finally {
    try {
        Disconnect-SPOService
    }
    catch [Exception] { }
}