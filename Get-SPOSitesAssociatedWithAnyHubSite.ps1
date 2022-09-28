<#
    Get-SPOSitesAssociatedWithAnyHubSite.ps1
    ------------------------------
#>
cls


##  Variable(s)
[System.String] $tenant = "<tenant_name>"
[System.String] $Login = "<email_address>"
[System.Security.SecureString] $PWord = ConvertTo-SecureString -String "<password>" -AsPlainText -Force


try {
    Connect-SPOService `
        -Url "https://$($tenant)-admin.sharepoint.com" `
        -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $PWord) `
        -ErrorAction Stop


    ##  Ignore OneDrive
    foreach($site in (Get-SPOSite -Limit All -IncludePersonalSite $false `
        | ? { $_.HubSiteId -ne "00000000-0000-0000-0000-000000000000" } `
        | Select Title, Url, HubSiteId, StorageUsageCurrent `
        | Sort-Object Title )) {


        Write-Output "$($site.Title)"
        Write-Output "$($site.Url)`n"
    }
}
catch [Exception] {
    Write-Error "$($_.Exception.Message)"
}
finally {
    try {
        Disconnect-SPOService
    }
    catch { }
}
