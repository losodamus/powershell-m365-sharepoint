<#
    Get-SPOSiteCountByTemplate.ps1
    ------------------------------


    Examples of template types:
    + TEAMCHANNEL#1  - Private Channel
    + SPSPERS#10     - OneDrive Site
#>
cls


##  Variable(s)
[System.String] $tenant = "<tenant_name>"
[System.String] $Login = "<email_address>"
[System.Security.SecureString] $PWord = ConvertTo-SecureString -String "<password>" -AsPlainText -Force
[System.Collections.Hashtable] $listOf = @{}


try {
    Connect-SPOService `
        -Url "https://$($tenant)-admin.sharepoint.com" `
        -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $PWord) `
        -ErrorAction Stop


    ##  Include OneDrive
    Get-SPOSite -IncludePersonalSite $true -Limit ALL `
        | Select Title, Template `
        | Sort-Object Title | % {


        [System.String] $tName = "$($_.Template)"
        if (-not($listOf.ContainsKey("$tName"))) {
            $listOf.Add("$tName", 0)
        }
        $listOf["$tName"]++
    }
    $listOf
    $listOf = @{}
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