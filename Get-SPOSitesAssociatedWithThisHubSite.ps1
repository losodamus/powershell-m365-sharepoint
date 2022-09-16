<#
    Get-SPOSitesAssociatedWithThisHubSite.ps1
    ------------------------------
#>
cls


##  Variable(s)
[System.String] $hubSiteName = "<hub_name>"
[System.String] $hubSiteGuid = ""
[System.String] $tenant = "<tenant_name>"
[System.String] $Login = "<email_address>"
[System.Security.SecureString] $PWord = ConvertTo-SecureString -String "<password>" -AsPlainText -Force


try {
    Connect-SPOService `
        -Url "https://$($tenant)-admin.sharepoint.com" `
        -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $PWord) `
        -ErrorAction Stop


    ##  Get Hub GUID
    Get-SPOHubSite `
        | ? { $_.Title -like "*$($hubSiteName)*" } `
        | Select ID, Title | % {


        $hubSiteGuid = "$($_.ID)"
        Write-Output "Hub:`t$($_.Title)"
        Write-Output "$($hubSiteGuid)"
        Write-Output "-------------------------"
    }


    ##  Ignore OneDrive for Business site
    foreach($site in (Get-SPOSite -Limit All -IncludePersonalSite $false `
        | ? { $_.HubSiteId -eq $hubSiteGuid } `
        | Select Title, Url, Template, HubSiteId, LastContentModifiedDate, StorageUsageCurrent `
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