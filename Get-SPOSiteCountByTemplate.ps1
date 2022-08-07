<#
    Get-SPOSiteCountByTemplate.ps1
    ------------------------------


    Query SharePoint Online sites and 
    audit site templates. 
#>
cls


try {


    ##  Variable(s)
    [System.String] $Login = "<email_address>"
    [System.Security.SecureString] $PWord = ConvertTo-SecureString -String "<password>" -AsPlainText -Force
    [System.Collections.Hashtable] $listOf = @{}


    Connect-SPOService `
        -Url https://theiilakesgroup-admin.sharepoint.com `
        -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $PWord)


    Get-SPOSite -IncludePersonalSite $true -Limit ALL | Select Template | % {
        [System.String] $templateName = "$($_.Template)"


        if ($listOf.ContainsKey("$templateName") -eq $false) {
            $listOf.Add("$templateName", 0)
        }
        $listOf["$templateName"]++
    }
    $listOf
}
catch [Exception] {
    Write-Host -F Red $_.Exception.Message
}
finally {
    try {
        Disconnect-SPOService
    }
    catch [Exception] { }
}
