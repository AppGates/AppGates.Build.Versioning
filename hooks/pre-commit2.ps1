#!/bin/sh

cd src
echo "$PWD"
$solution = Resolve-Path  "$PWD\*.sln" | Select -ExpandProperty Path

echo $solution
dotnet test $solution
echo $LASTEXITCODE 
#echo "Hello 1 from powershell commit"
#sleep 1 
#echo "Hello 2 from pre commit"
#sleep 1 
#echo "Hello 3 from pre commit"

-if ($LASTEXITCODE -eq 0)
{
	exit 0
}
else
{
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	exit  1
}