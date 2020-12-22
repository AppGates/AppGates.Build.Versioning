
$rootFolderPath = $PWD
echo "rootFolderPath $rootFolderPath"

$excludeDirectories = ("bin", "obj", "build");

[string[]]$Paths = @($rootFolderPath)
[string[]]$Excludes = @('*\bin\*', '*\obj\*', '*\build\*')

$files = Get-ChildItem $Paths -Directory -Recurse -Exclude $Excludes | %{ 
    $allowed = $true
    foreach ($exclude in $Excludes) { 
        if ((Split-Path $_.FullName -Parent) -ilike $exclude) { 
            $allowed = $false
            break
        }
    }
    if ($allowed) {
        $_
    }
}
foreach ($file in $files) {
 echo    $file

}

exit 1
