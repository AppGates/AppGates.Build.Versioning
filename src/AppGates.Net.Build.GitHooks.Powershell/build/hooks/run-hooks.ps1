param (
    [Parameter(Mandatory=$true)]
    [string]
    $gitRepositoryRoot,

    [Parameter(Mandatory=$true)]
    [string]
    $hookName,
     
    [parameter(Mandatory=$true)]
    [String[]]
    [ValidateNotNull()]
    $hookScripts

 )

 echo "Script process started"
 echo "gitRepositoryRoot: $gitRepositoryRoot"
 echo "hookName: $hookName"
 echo "hookScripts: $hookScripts"

foreach($hookScript in $hookScripts)
{
    $hookScriptContext = (get-item $hookScript ).Directory.Parent.FullName;
    echo "hookScriptContext: $hookScriptContext"
    cd $hookScriptContext
    iex $hookScript
    if ($LASTEXITCODE -ne 0)
    {
	    Write-Host "The pre-commit script $hookScript failed with error code $LASTEXITCODE." -ForegroundColor Red;
	    Write-Host "Press any key to exit...";
	    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        exit $LASTEXITCODE
    }
}