
$rootFolderPath = $PWD
echo "rootFolderPath $rootFolderPath"


[string[]]$Paths = @($rootFolderPath)
[string[]]$Excludes = @('bin', 'obj', 'build')
$folderName = @('git-ps-hooks')

$directories = Get-ChildItem $Paths -Directory -Recurse -Filter $folderNam

foreach ($directory in $directories) {
    $included = $true
    foreach ($exclude in $Excludes) { 
        if ($directory.FullName -ilike "*\$exclude\*" -or $directory.Name -eq $exclude) { 
            $included = $false
            break
        }
    }
    if ($included) {

        $preCommitFile = Join-Path -Path $directory.FullName -ChildPath "pre-commit.ps1"
        if(Test-Path -path $preCommitFile -PathType Leaf){
            iex $preCommitFile
            if ($LASTEXITCODE -ne 0)
            {
	            Write-Host -NoNewLine 'Press any key to continue...';
	            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	            exit  $LASTEXITCODE
            }
        }
    }
}

#exit 1
