$gitRepositoryRoot = $PWD
echo "gitRepositoryRoot: $gitRepositoryRoot"


[string[]]$Paths = @($gitRepositoryRoot)
[string[]]$Excludes = @('bin', 'obj')
$gitHooksFolderName = ".git-ps-hooks"

$directories = Get-ChildItem $Paths -Directory -Recurse -Filter $gitHooksFolderName

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
            cd $directory.parent.FullName
            iex $preCommitFile
            if ($LASTEXITCODE -ne 0)
            {
	            Write-Host "The pre-commit script $preCommitFile failed with error code $LASTEXITCODE." -ForegroundColor Red;
	            Write-Host "Press any key to exit...";
	            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	            exit  $LASTEXITCODE
            }
        }
    }
}
cd $gitRepositoryRoot
