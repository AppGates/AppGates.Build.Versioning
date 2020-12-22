
echo $PSScriptRoot

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "pwsh.exe"
$pinfo.RedirectStandardError = $false
$pinfo.RedirectStandardOutput = $false
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "$PSScriptRoot\pre-commit2.ps1"
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
#Do Other Stuff Here....
$p.WaitForExit()
$exitCode = $p.ExitCode






If($exitCode -eq 0){

Write-Host 'Der Exit Code ist wie erwartet 0!' -ForegroundColor Green

} else {

Write-Host 'Der Exit Code ist NICHT 0!' -ForegroundColor Magenta
}

exit $exitCode
