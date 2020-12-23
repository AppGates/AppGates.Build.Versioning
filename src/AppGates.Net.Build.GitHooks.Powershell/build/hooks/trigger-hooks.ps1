param (
    [string]
    $hookName = "pre-commit",

    [bool]
    $invokeDirect = $false

 )

$gitRepositoryRoot = $PWD

echo "hookName: $hookName"
echo "gitRepositoryRoot: $gitRepositoryRoot"
echo "invokeDirect": $invokeDirect

[string[]]$Paths = @($gitRepositoryRoot)
[string[]]$Excludes = @('bin', 'obj')
$gitHooksFolderName = ".git-ps-hooks"

$directories = Get-ChildItem $Paths -Directory -Recurse -Filter $gitHooksFolderName

$scriptList = New-Object Collections.Generic.List[string]

foreach ($directory in $directories) {
    $included = $true
    foreach ($exclude in $Excludes) { 
        if ($directory.FullName -ilike "*\$exclude\*" -or $directory.Name -eq $exclude) { 
            $included = $false
            break
        }
    }
    if ($included) {

        $hookScript = Join-Path -Path $directory.FullName -ChildPath "$hookName.ps1"
   
        if(Test-Path -path $hookScript -PathType Leaf){
            $scriptList.Add($hookScript)
        }
    }
}

if($scriptList.Count -gt 0)
{
    if($invokeDirect)
    {
        iex $PSScriptRoot\RunHookScripts.ps1 $hookName $scriptList       
    }
    else
    {
        $scriptsAsArgument =  """$($scriptList -join """,""")""" 
        $arguments = "$PSScriptRoot\run-hooks.ps1 $gitRepositoryRoot  $hookName $scriptsAsArgument"
        echo $arguments
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "pwsh.exe"
        $pinfo.RedirectStandardError = $false
        $pinfo.RedirectStandardOutput = $false
        $pinfo.UseShellExecute = $true
        $pinfo.Arguments = $arguments
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

    }
}