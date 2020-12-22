
$rootFolderPath = $PWD
$excludeDirectories = ("bin", "obj", "build");

function Exclude-Directories
{
    process
    {
        $allowThrough = $true
        foreach ($directoryToExclude in $excludeDirectories)
        {
            $directoryText = "*\" + $directoryToExclude
            $childText = "*\" + $directoryToExclude + "\*"
            if (($_.FullName -Like $directoryText -And $_.PsIsContainer) `
                -Or $_.FullName -Like $childText)
            {
                $allowThrough = $false
                break
            }
        }
        if ($allowThrough)
        {
            return $_
        }
    }
}

Clear-Host

Get-ChildItem $rootFolderPath -Recurse | Exclude-Directories | Foreach-Object 
{
    $preCommitFile =$_.FullName

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "pwsh.exe"
    $pinfo.RedirectStandardError = $false
    $pinfo.RedirectStandardOutput = $false
    $pinfo.UseShellExecute = $true
    $pinfo.Arguments = $preCommitFile
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
        exit $exitCode
    }
}
