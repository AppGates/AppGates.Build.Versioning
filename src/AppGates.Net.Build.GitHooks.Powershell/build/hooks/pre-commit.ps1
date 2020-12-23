param (
    [Parameter(Mandatory=$true)][string]$hookName,
    #[Parameter(Mandatory=$true)][string]$username,
    #[string]$password = $( Read-Host "Input password, please" )
 )

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "pwsh.exe"
$pinfo.RedirectStandardError = $false
$pinfo.RedirectStandardOutput = $false
$pinfo.UseShellExecute = $true
$pinfo.Arguments = "$PSScriptRoot\pre-commit-inner.ps1 $hookName"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$started = $p.Start()
if($started -eq $false){
		Write-Host 'Pre Commit failed. Inner process start failed.' -ForegroundColor Red
}
#Do Other Stuff Here....
$p.WaitForExit()
$exitCode = $p.ExitCode

If($exitCode -eq 0)
{
	Write-Host 'Pre Commit successful!' -ForegroundColor Green
} 
else 
{
	Write-Host 'Pre Commit failed.' -ForegroundColor Red
}

exit $exitCode
