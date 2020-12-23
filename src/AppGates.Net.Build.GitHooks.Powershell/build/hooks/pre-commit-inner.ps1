iex $PWD\hooks\pre-commit.ps1
if ($LASTEXITCODE -eq 0)
{
	exit 0
}
else
{
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	exit  $LASTEXITCODE
}